# frozen_string_literal: true

module Datadog
  module Tracing
    module Contrib
      module Karafka
        # Karafka framework code, used to essentially:
        # - handle configuration entries which are specific to Datadog tracing
        # - instrument parts of the framework when needed
        module Framework
          def self.setup
            karafka_configurations = Datadog.configuration.tracing.fetch_integration(:karafka).configurations
            waterdrop_configurations = Datadog.configuration.tracing.fetch_integration(:waterdrop).configurations

            Datadog.configure do |datadog_config|
              karafka_configurations.each do |name, karafka_config|
                # do not override user configuration
                next if name != :default && waterdrop_configurations.key?(name)
                activate_waterdrop!(datadog_config, karafka_config, name)
              end
            end
          end

          # Apply relevant configuration from Karafka to WaterDrop
          def self.activate_waterdrop!(datadog_config, karafka_config, name)
            datadog_config.tracing.instrument(
              :waterdrop,
              enabled: karafka_config[:enabled],
              service_name: karafka_config[:service_name],
              distributed_tracing: karafka_config[:distributed_tracing],
              describes: name
            )
          end
        end
      end
    end
  end
end
