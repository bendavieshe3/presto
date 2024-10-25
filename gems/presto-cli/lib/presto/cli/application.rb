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
                    default: 'gpt-3.5-turbo'
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

        response = client.generate_text(
          prompt,
          model: options[:model]
        )

        unless response['choices'] && !response['choices'].empty?
          raise Error, "No valid response received: #{JSON.pretty_generate(response)}"
        end

        content = response.dig('choices', 0, 'message', 'content')
        case options[:format]
        when 'json'
          puts JSON.pretty_generate(response)
        else
          puts "\nResponse:"
          puts content
        end
      rescue Presto::Core::Error, Error => e
        raise Thor::Error, "Error: #{e.message}"
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
      def models
        say "Available models for #{options[:provider]}:"
        say '  - gpt-3.5-turbo'
        say '  - gpt-4'
        say '  - claude-3-opus-20240229'
        say '  - claude-3-sonnet-20240229'
        # In future versions, this will dynamically fetch from providers
      end

      desc 'version', 'Show version information'
      def version
        say "Presto CLI version #{Presto::CLI::VERSION}"
        say "Presto Core version #{Presto::Core::VERSION}"
      end

      private

      def validate_environment!
        return if ENV['OPENROUTER_API_KEY']

        raise Error, 'OPENROUTER_API_KEY environment variable is required'
      end
    end

    class Error < StandardError; end
  end
end
