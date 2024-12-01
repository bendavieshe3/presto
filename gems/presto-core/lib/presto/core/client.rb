# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core/client.rb
module Presto
  module Core
    class Client
      AVAILABLE_PROVIDERS = [:openrouter, :openai, :anthropic].freeze

      attr_reader :provider

      def initialize(provider:, api_key:)
        @provider = create_provider(provider, api_key)
      end

      def self.available_providers
        AVAILABLE_PROVIDERS.map(&:to_s)
      end

      def generate(model: nil, **parameters)
        model ||= provider.default_model
        provider.generate(model: model, **parameters)
      end      

      def available_models
        provider.available_models
      end

      private

      def create_provider(provider_name, api_key)
        unless AVAILABLE_PROVIDERS.include?(provider_name.to_sym)
          raise ProviderError, "Unsupported provider: #{provider_name}"
        end

        case provider_name.to_sym
        when :openrouter
          Providers::OpenRouter.new(api_key: api_key)
        when :openai
          Providers::OpenAI.new(api_key: api_key)
        when :anthropic
          Providers::Anthropic.new(api_key: api_key)
        end
      end
    end
  end
end