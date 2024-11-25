# gems/presto-cli/lib/presto/cli/application.rb
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

      desc 'generate PROMPT', 'Generate text using an AI model'
      method_option :model,
                    aliases: '-m',
                    desc: 'Model to use',
                    default: 'meta-llama/llama-3-8b-instruct'
      method_option :provider,
                    aliases: '-p',
                    desc: 'Provider to use',
                    default: 'openrouter'
      method_option :format,
                    aliases: '-f',
                    desc: 'Output format (text, json)',
                    default: 'text'
      method_option :verbose,
                    aliases: '-v',
                    desc: 'Show verbose output',
                    type: :boolean,
                    default: false

      def generate(prompt)
        validate_environment!

        if options[:verbose]
          say "Using provider: #{options[:provider]}"
          say "Using model: #{options[:model]}"
        end

        client = Presto::Core::Client.new(
          provider: options[:provider].to_sym,
          api_key: ENV['OPENROUTER_API_KEY']
        )

        say 'Generating response...' if options[:verbose]

        begin
          response = client.generate_text(
            prompt,
            model: options[:model]
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

      desc 'providers', 'List available providers'
      def providers
        say 'Available providers:'
        say '  - openrouter'
      end

      desc 'models', 'List available models for a provider'
      method_option :provider,
                    aliases: '-p',
                    desc: 'Provider to list models for',
                    default: 'openrouter'
      method_option :format,
                    aliases: '-f',
                    desc: 'Output format (text, json)',
                    default: 'text'
      method_option :verbose,
                    aliases: '-v',
                    desc: 'Show detailed model information',
                    type: :boolean,
                    default: false
      def models
        validate_environment!
        
        client = Presto::Core::Client.new(
          provider: options[:provider].to_sym,
          api_key: ENV['OPENROUTER_API_KEY']
        )

        models = client.available_models

        case options[:format]
        when 'json'
          puts JSON.pretty_generate(models)
        else
          say "Available models for #{options[:provider]}:"
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


      desc 'version', 'Show version information'
      def version
        say "Presto CLI version #{Presto::CLI::VERSION}"
        say "Presto Core version #{Presto::Core::VERSION}"
      end

      private

      def display_basic_model_info(model)
        # Let the display logic handle missing fields gracefully
        id = model['id'] || model['model']
        name = model['name'] || id
        say "  - #{id}#{name != id ? " (#{name})" : ''}"
      end

      def display_verbose_model_info(model)
        id = model['id'] || model['model']
        say "  #{id}:"
        
        # Display any additional fields that exist
        %w[name description context_length].each do |field|
          say "    #{field}: #{model[field]}" if model[field]
        end
        
        # Handle nested fields if they exist
        if model['pricing']&.dig('prompt')
          say "    pricing: $#{model['pricing']['prompt']}/1k tokens"
        end
        
        say "" # Empty line for readability between models
      end

      def validate_environment!
        return if ENV['OPENROUTER_API_KEY']

        raise Error, 'OPENROUTER_API_KEY environment variable is required'
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

    class Error < StandardError; end
  end
end