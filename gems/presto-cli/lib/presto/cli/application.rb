# frozen_string_literal: true
# FILE: gems/presto-cli/lib/presto/cli/application.rb

require 'thor'
require 'presto/core'
require 'dotenv/load'
require 'json'

module Presto
  module CLI
    class Application < Thor
      package_name 'Presto'

      def self.exit_on_failure?
        true
      end

      class_option :provider,
                  aliases: '-p',
                  desc: 'Provider to use (defaults to config or openrouter)',
                  type: :string
      class_option :verbose,
                  aliases: '-v',
                  desc: 'Show verbose output',
                  type: :boolean,
                  default: false

      desc 'generate PROMPT', 'Generate text using an AI model'
      method_option :model,
                  aliases: '-m',
                  desc: 'Model to use (defaults to provider default)',
                  type: :string
      method_option :format,
                   aliases: '-f',
                   desc: 'Output format (text, json)',
                   default: 'text'
                   desc 'generate PROMPT', 'Generate text using an AI model'
                   method_option :model,
                               aliases: '-m',
                               desc: 'Model to use (defaults to provider default)',
                               type: :string
                   method_option :format,
                                aliases: '-f',
                                desc: 'Output format (text, json)',
                                default: 'text'
      def generate(prompt)
        provider_name = determine_provider
        validate_provider!(provider_name)
        validate_provider_config!(provider_name)

        client = create_client(provider_name)
        
        # Get the default model from the provider if none specified - moved up
        model = options[:model] || client.provider.default_model

        if options[:verbose]
          say "Using provider: #{provider_name}"
          say "Using model: #{model}"
          say 'Generating response...'
        end

        begin
          response = client.generate_text(
            prompt,
            model: model
          )

          if response['choices'] && !response['choices'].empty?
            content = response.dig('choices', 0, 'message', 'content')
            case options[:format]
            when 'json'
              puts JSON.pretty_generate(response)
            else
              puts "\nResponse:"
              puts content
            end
          else
            handle_error(response)
          end
        rescue Presto::Core::InvalidModelError => e
          raise Thor::Error, "Error: #{e.message}"
        rescue Presto::Core::Error => e
          raise Thor::Error, "Error: Failed to generate response - #{e.message}"
        end
      end

      desc 'models', 'List available models for a provider'
      method_option :format,
                   aliases: '-f',
                   desc: 'Output format (text, json)',
                   default: 'text'
      def models
        provider_name = determine_provider
        validate_provider!(provider_name)
        validate_provider_config!(provider_name)
        
        client = create_client(provider_name)

        begin
          models = client.available_models

          case options[:format]
          when 'json'
            puts JSON.pretty_generate(models)
          else
            say "Available models for #{provider_name}:"
            models.each do |model|
              if options[:verbose]
                display_verbose_model_info(model)
              else
                display_basic_model_info(model)
              end
            end
          end
        rescue Presto::Core::Error => e
          raise Thor::Error, "Error: #{e.message}"
        end
      end

      desc 'providers', 'List available providers'
      method_option :format,
                   aliases: '-f',
                   desc: 'Output format (text, json)',
                   default: 'text'
      def providers
        providers = Config.available_providers
        default = Config.default_provider

        case options[:format]
        when 'json'
          data = {
            providers: providers,
            default_provider: default,
            configured_providers: providers.select { |p| Config.provider_api_key(p) }
          }
          puts JSON.pretty_generate(data)
        else
          say "Available providers:"
          providers.each do |provider|
            status = if Config.provider_api_key(provider)
              "configured"
            else
              "not configured"
            end
            provider_str = provider.to_s
            provider_str += " (default)" if provider == default
            say "  #{provider_str} - #{status}"
          end
        end
      end

      desc 'version', 'Show version information'
      def version
        say "Presto CLI version #{Presto::CLI::VERSION}"
        say "Presto Core version #{Presto::Core::VERSION}"
      end

      private

      def determine_provider
        # Command line option takes precedence
        return options[:provider] if options[:provider]
        
        # Then use configured default
        Config.default_provider
      end

      def validate_provider!(provider_name)
        unless Config.available_providers.include?(provider_name.to_s)
          raise Thor::Error, "Error: Unknown provider '#{provider_name}'. Use 'presto providers' to see available providers."
        end
      end

      def validate_provider_config!(provider_name)
        unless Config.provider_api_key(provider_name)
          message = <<~ERROR
            Provider '#{provider_name}' is not configured.

            You can configure it using either option:

            Option 1: Set the #{provider_name.upcase}_API_KEY environment variable:
                export #{provider_name.upcase}_API_KEY=your-api-key

            Option 2: Add to your configuration file (#{Config::CONFIG_FILE}):
                providers:
                  #{provider_name}:
                    api_key: your-api-key
          ERROR
          raise Thor::Error, message
        end
      end

      def create_client(provider_name)
        begin
          Presto::Core::Client.new(
            provider: provider_name.to_sym,
            api_key: Config.provider_api_key(provider_name)
          )
        rescue Presto::Core::Error => e
          raise Thor::Error, "Configuration error: #{e.message}"
        end
      end      


      def display_basic_model_info(model)
        id = model['id'] || model['model']
        name = model['name'] || id
        say "  - #{id}#{name != id ? " (#{name})" : ''}"
      end

      def display_verbose_model_info(model)
        id = model['id'] || model['model']
        say "  #{id}:"
        
        %w[name description context_length].each do |field|
          say "    #{field}: #{model[field]}" if model[field]
        end
        
        if model['pricing']&.dig('prompt')
          say "    pricing: $#{model['pricing']['prompt']}/1k tokens"
        end
        
        say "" # Empty line for readability between models
      end

      def handle_error(response)
        message = if response.is_a?(Hash) && response['error']
          response['error']['message']
        else
          "Unexpected error occurred"
        end
        raise Thor::Error, "Error: #{message}"
      end
    end
  end
end