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
          # Check environment variable first
          return ENV['OPENROUTER_API_KEY'] if ENV['OPENROUTER_API_KEY']

          # Then check config file
          config = load_config
          config&.dig('openrouter', 'api_key')
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
          instructions << "Option 1: Set the OPENROUTER_API_KEY environment variable:"
          instructions << "  export OPENROUTER_API_KEY=your-api-key"
          instructions << "\nOption 2: Create a configuration file:"
          instructions << "  mkdir -p #{CONFIG_DIR}"
          instructions << "  Then create #{CONFIG_FILE} with the following content:"
          instructions << "\n  openrouter:"
          instructions << "    api_key: your-api-key"
          instructions.join("\n")
        end
      end
    end
  end
end