require "elasticsearch/index/transfer/version"
require "elasticsearch/index/transfer/elasticsearch"
require "elasticsearch/index/transfer/s3"

module Elasticsearch
  module Index
    module Transfer
      
      def self.execute options
        options = options.with_indifferent_access
        source = options.fetch(:source) || raise "key(source) missing in the options"
        target = options.fetch(:target) || raise "key(target) missing in the options"

        source_client = source.keys.first
        target_client = target.keys.first

        send("#{source_client}_extract", source_client, source[source_client], target_client, target[target_client])
      end
    end
  end
end
