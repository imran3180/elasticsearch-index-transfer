module Elasticsearch
  module Index
    module Transfer

      attr_accessor :region, :access_key_id, :secret_access_key, :bucket, :prefix
      
      def s3_extract

      end

      def s3_ingest options, data, batch_no
        extract_params(options)
        client = Aws::S3::Client.new(access_key_id: @access_key_id, secret_access_key: @secret_access_key, region: @region)
        client.put_object(body: data.to_json,
                          bucket: @bucket,
                          key: "#{prefix}config.json")
      end

      def s3_write_settings settings, mapping, aliases, options
        extract_params(options)
        client = Aws::S3::Client.new(access_key_id: @access_key_id, secret_access_key: @secret_access_key, region: @region)
        begin
          client.head_bucket({bucket: @bucket})
        rescue Aws::S3::Errors::NotFound
          raise "Bucket - #{@bucket} not found. Please create the bucket if it does not exists"
        end
        client.put_object(body: {settings: settings, mapping: mapping, aliases: aliases}.to_json,
                          bucket: @bucket,
                          key: "#{prefix}config.json")
      end

      private
      def extract_params options
        @region = options.fetch(:region)
        @access_key_id = options.fetch(:access_key_id)
        @secret_access_key = options.fetch(:secret_access_key)
        @bucket = options.fetch(:bucket)
        @prefix = options.fetch(:prefix) rescue ""
        @prefix = "#{@prefix}/" if @prefix.present? and @prefix
      end

    end
  end
end
