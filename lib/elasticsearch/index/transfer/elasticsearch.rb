module Elasticsearch
  module Index
    module Transfer

      BATCH_SIZE = 5000

      attr_accessor :host, :port, :index, :type, :batch_size
      
      def self.elasticsearch_extract source_client, source_options, target_client, target_options
        client = Elasticsearch::Client.new(host: @host, port: @port)
        batch_no = 0

        # config setup into the target
        settings = client.get_settings(index: @index)
        mapping = client.get_mapping(index: @index)
        aliases = client.indices.get_alias(index: index)
        send("#{target_client}_write_settings", settings, mapping, aliases, target_options)

        # Transferring the first batch
        response = client.search index: @index, scroll: '5m', body: {sort: ['_doc']}
        total = response["hits"]["total"]
        batch_size = @batch_size
        batch_count = total/batch_size
        data = process_hits(response["hits"]["hits"])
        send("#{target_client}_ingest", target_options, data, batch_no)
        
        puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Total Document count - #{total}"
        puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Batch-(#{batch_no}/#{batch_size}) transfered successfully."
        
        # Transferring the subsequent batches
        batch_no = batch_no + 1
        while response = client.scroll(body: {scroll_id: response['_scroll_id']}, scroll: '5m') and not response['hits']['hits'].empty? do
          data = process_hits(response["hits"]["hits"])
          send("#{target_client}_ingest", target_options, data, batch_no)
          puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Batch-(#{batch_no}/#{batch_size}) transfered successfully."
          batch_no = batch_no + 1
        end
        puts "Elasticsearch Transfer(#{source_client}-to-#{target_client}): Done."
      end

      def self.elasticsearch_ingest

      end

      def self.elasticsearch_write_settings

      end

      private
      def extract_params options
        @host  = options.fetch(:host) rescue (raise "elasticsearch-host is missing from the options")
        @port  = options.fetch(:port) rescue (raise "elasticsearch-port is missing from the options")
        @index = options.fetch(:index) rescue (raise "elasticsearch-index is missing from the options")
        @type  = options.fetch(:type) rescue "" # default all type of index will be transfered
        @batch_size = options.fetch(:batch_size) rescue BATCH_SIZE # default batch size is 5000
      end

      def process_hits hits
        hits.each do |hit|
          hit.delete("_score")
          hit["data"] = hit.delete("_source")
        end
      end

    end
  end
end
