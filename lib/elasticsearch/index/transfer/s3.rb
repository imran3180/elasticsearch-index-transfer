require "aws-sdk-s3"

module Elasticsearch
  module Index
    module Transfer

      attr_accessor :region, :access_key_id, :secret_access_key, :bucket, :prefix
      
      def self.s3_extract source_client, source_options, target_client, target_options
        s3_extract_params(source_options)
        client = Aws::S3::Client.new(access_key_id: @access_key_id, secret_access_key: @secret_access_key, region: @region)
        begin
          client.head_bucket({bucket: @bucket})
        rescue Aws::S3::Errors::NotFound
          raise "Bucket - #{@bucket} not found."
        end
        begin
          response = client.get_object(bucket: @bucket, key: "#{@prefix}_config.json").body.read
        rescue Aws::S3::Errors::NoSuchKey
          raise "_config.json not found. es-backup does not exists at specified location(S3:#{@bucket}/#{prefix})"
        end
        
        # config setup into the target
        _configs = JSON.parse(response)
        target_options[:index] = target_options[:index] || _configs["index"] # if target index is not provided used stored index name
        send("#{target_client}_write_settings", target_options, _configs)
        puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Total Document count - #{_configs['total']}"

        # Transferring the index data
        batch_count = _configs["batch_count"]
        (0..batch_count).each do |batch_no|
          # puts "processing batch_no = #{batch_no}..."
          data = JSON.parse(client.get_object(bucket: @bucket, key: "#{@prefix}batch-#{batch_no}.json").body.read)
          send("#{target_client}_ingest", target_options, data, batch_no)
          puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Batch-(#{batch_no}/#{batch_count}) transfered successfully."
        end
      end

      def self.s3_ingest options, data, batch_no
        s3_extract_params(options)
        client = Aws::S3::Client.new(access_key_id: @access_key_id, secret_access_key: @secret_access_key, region: @region)
        client.put_object(body: data.to_json,
                          bucket: @bucket,
                          key: "#{@prefix}batch-#{batch_no}.json")
      end

      def self.s3_write_settings options, _configs
        s3_extract_params(options)
        client = Aws::S3::Client.new(access_key_id: @access_key_id, secret_access_key: @secret_access_key, region: @region)
        begin
          client.head_bucket({bucket: @bucket})
        rescue Aws::S3::Errors::NotFound
          raise "Bucket - #{@bucket} not found. Please create the bucket if it does not exists"
        end
        client.put_object(body: _configs.to_json,
                          bucket: @bucket,
                          key: "#{@prefix}_config.json")
      end

      private
      def self.s3_extract_params options
        @region = options.fetch(:region)
        @access_key_id = options.fetch(:access_key_id)
        @secret_access_key = options.fetch(:secret_access_key)
        @bucket = options.fetch(:bucket)
        @prefix = options.fetch(:prefix) rescue ""
        @prefix = "#{@prefix}/" if not @prefix.empty? and @prefix[-1] != '/'
      end

    end
  end
end
