# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core/client.rb
module Presto
  module Core
    class Client
      attr_reader :provider

      def initialize(provider:, api_key:)
        @provider = create_provider(provider, api_key)
      end

      def generate_text(prompt, model: "meta-llama/llama-3-8b-instruct", **options)
        provider.generate_text(prompt, model: model, **options)
      end

      def available_models
        provider.available_models
      end

      private

      def create_provider(provider_name, api_key)
        case provider_name.to_sym
        when :openrouter
          Providers::OpenRouter.new(api_key: api_key)
        else
          raise ProviderError, "Unsupported provider: #{provider_name}"
        end
      end
    end
  end
end