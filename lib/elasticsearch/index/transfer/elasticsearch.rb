require 'elasticsearch'

module Elasticsearch
  module Index
    module Transfer

      BATCH_SIZE = 1000

      attr_accessor :host, :port, :index, :batch_size
      
      def self.elasticsearch_extract source_client, source_options, target_client, target_options
        elasticsearch_extract_params(source_options)
        target_options[:index] = target_options[:index] || @index # copyping the source index name
        client = Elasticsearch::Client.new(host: @host, port: @port)
        batch_no = 0

        # config setup into the target
        settings = client.indices.get_settings(index: @index)[@index]
        settings["settings"]["index"] = settings["settings"]["index"].select{|key, value| ["number_of_shards", "number_of_replicas"].include?(key)}
        mapping = client.indices.get_mapping(index: @index)[@index]
        aliases = client.indices.get_alias(index: @index)[@index]

        # Transferring the first batch
        response = client.search index: @index, scroll: '5m', body: {size: @batch_size, sort: ['_doc']}
        total = response["hits"]["total"]
        batch_size = @batch_size
        batch_count = total/batch_size

        _configs = {index: @index, body: mapping.merge(aliases).merge(settings), batch_count: batch_count, total: total}
        send("#{target_client}_write_settings", target_options, _configs)

        data = process_hits(response["hits"]["hits"])
        send("#{target_client}_ingest", target_options, data, batch_no)
        
        puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Total Document count - #{total}"
        puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Batch-(#{batch_no}/#{batch_count}) transfered successfully."
        
        # Transferring the subsequent batches
        batch_no = batch_no + 1
        while response = client.scroll(body: {scroll_id: response['_scroll_id']}, scroll: '5m') and not response['hits']['hits'].empty? do
          data = process_hits(response["hits"]["hits"])
          send("#{target_client}_ingest", target_options, data, batch_no)
          puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Batch-(#{batch_no}/#{batch_count}) transfered successfully."
          batch_no = batch_no + 1
        end
        puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Done."
      end

      def self.elasticsearch_ingest options, data, batch_no
        elasticsearch_extract_params(options)
        client = Elasticsearch::Client.new(host: @host, port: @port)
        data.each do |record|
          record["index"]["_index"] = @index
        end
        client.bulk(body: data)
      end

      def self.elasticsearch_write_settings options, _configs
        elasticsearch_extract_params(options)
        client = Elasticsearch::Client.new(host: @host, port: @port)
        begin
          client.indices.create(index: @index, body: _configs["body"])
        rescue
          raise "Index(#{@index}) is already present on (#{@host})"
        end
      end

      private
      def self.elasticsearch_extract_params options
        @host  = options.fetch(:host) rescue (raise "elasticsearch-host is missing from the options")
        @port  = options.fetch(:port) rescue (raise "elasticsearch-port is missing from the options")
        @index = options.fetch(:index) rescue (raise "elasticsearch-index is missing from the options")
        @batch_size = options.fetch(:batch_size) rescue BATCH_SIZE # default batch size is 5000
      end

      def self.process_hits hits
        docs = []
        hits.each do |hit|
          hit.delete("_score")
          hit.delete("sort")
          hit["data"] = hit.delete("_source")
          doc = {}
          doc["index"] = hit
          docs << doc
        end
        docs
      end

    end
  end
end
