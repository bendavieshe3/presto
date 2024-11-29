# frozen_string_literal: true
# FILE: gems/presto-cli/lib/presto/cli/config.rb
require 'yaml'
require 'fileutils'

module Presto
  module CLI
    class Config
        ENV_CONFIG_PATH = 'PRESTO_CONFIG_PATH'
        CONFIG_DIR = ENV.fetch(ENV_CONFIG_PATH) { File.expand_path('~/.config/presto') }
        CONFIG_FILE = File.join(CONFIG_DIR, 'config.yml')
        DEFAULT_PROVIDER = 'openrouter'

      class << self
        def openrouter_api_key
          return ENV['OPENROUTER_API_KEY'] if ENV['OPENROUTER_API_KEY']
          provider_config('openrouter')&.fetch('api_key', nil)
        end

        def provider_api_key(provider)
          env_key = "#{provider.upcase}_API_KEY"
          return ENV[env_key] if ENV[env_key]
          provider_config(provider)&.fetch('api_key', nil)
        end

        def default_provider
          cached_config['default_provider'] || DEFAULT_PROVIDER
        end

        def provider_config(provider)
          cached_config.dig('providers', provider.to_s)
        end

        def available_providers
            Presto::Core::Client.available_providers
        end
  

        def reload_config!
          @config = nil
        end

        private

        def cached_config
          @config ||= load_config
        end

        def load_config
          if File.exist?(CONFIG_FILE)
            YAML.load_file(CONFIG_FILE) || {}
          else
            {}
          end
        rescue => e
          raise Error, "Failed to load config file: #{e.message}"
        end

        def config_instructions
          instructions = []
          instructions << "Configuration can be provided via environment variables or config file."
          instructions << "\nOption 1: Set environment variables:"
          instructions << "  export OPENROUTER_API_KEY=your-api-key"
          instructions << "  export OPENAI_API_KEY=your-openai-key"
          instructions << "\nOption 2: Create a configuration file:"
          instructions << "  mkdir -p #{CONFIG_DIR}"
          instructions << "  Create #{CONFIG_FILE} with the following content:"
          instructions << "\n  default_provider: #{DEFAULT_PROVIDER}"
          instructions << "  providers:"
          instructions << "    openrouter:"
          instructions << "      api_key: your-api-key"
          instructions << "    openai:"
          instructions << "      api_key: your-openai-key"
          instructions.join("\n")
        end
      end
    end
  end
end