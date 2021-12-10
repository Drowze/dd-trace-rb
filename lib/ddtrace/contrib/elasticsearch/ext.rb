# typed: true
module Datadog
  module Contrib
    module Elasticsearch
      # Elasticsearch integration constants
      module Ext
        ENV_ENABLED = 'DD_TRACE_ELASTICSEARCH_ENABLED'.freeze
        ENV_ANALYTICS_ENABLED = 'DD_TRACE_ELASTICSEARCH_ANALYTICS_ENABLED'.freeze
        ENV_ANALYTICS_SAMPLE_RATE = 'DD_TRACE_ELASTICSEARCH_ANALYTICS_SAMPLE_RATE'.freeze
        DEFAULT_PEER_SERVICE_NAME = 'elasticsearch'.freeze
        SPAN_QUERY = 'elasticsearch.query'.freeze
        SPAN_TYPE_QUERY = 'elasticsearch'.freeze
        TAG_BODY = 'elasticsearch.body'.freeze
        TAG_METHOD = 'elasticsearch.method'.freeze
        TAG_PARAMS = 'elasticsearch.params'.freeze
        TAG_URL = 'elasticsearch.url'.freeze
        TAG_COMPONENT = 'elasticsearch'.freeze
        TAG_OPERATION_QUERY = 'query'.freeze
      end
    end
  end
end
