# frozen_string_literal: true
# FILE: gems/presto-cli/lib/presto/cli/config.rb
require 'yaml'
require 'fileutils'

module Presto
  module CLI
    class Config
      CONFIG_DIR = File.expand_path('~/.config/presto')
      CONFIG_FILE = File.join(CONFIG_DIR, 'config.yml')

      class << self
        def openrouter_api_key
          # Maintain backwards compatibility with env var
          return ENV['OPENROUTER_API_KEY'] if ENV['OPENROUTER_API_KEY']

          # Then check provider config
          provider_config('openrouter')&.fetch('api_key', nil)
        end

        def provider_api_key(provider)
          # Check environment variable first (e.g., OPENAI_API_KEY)
          env_key = "#{provider.upcase}_API_KEY"
          return ENV[env_key] if ENV[env_key]

          # Then check provider config
          provider_config(provider)&.fetch('api_key', nil)
        end

        def default_provider
            config = load_config
            # Changed from using fetch to handle nil config case explicitly
            return 'openrouter' unless config
            config['default_provider'] || 'openrouter'
        end

        def provider_config(provider)
          config = load_config
          return nil unless config

          config.dig('providers', provider.to_s)
        end

        def available_providers
            # Since we now support both providers by default, return both
            # even if config file doesn't exist or doesn't list them
            ['openrouter', 'openai']
        end

        private

        def load_config
          return unless File.exist?(CONFIG_FILE)
          YAML.load_file(CONFIG_FILE)
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
          instructions << "\n  default_provider: openrouter"
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