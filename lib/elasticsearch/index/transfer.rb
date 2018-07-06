require "elasticsearch/index/transfer/version"

module Elasticsearch
  module Index
    module Transfer
      
      def self.execute options
        options = options.with_indifferent_access
        source = options.fetch(:source)
        target = options.fetch(:target)

        source_client = source.keys.first
        target_client = target.keys.first

      end
    end
  end
end
