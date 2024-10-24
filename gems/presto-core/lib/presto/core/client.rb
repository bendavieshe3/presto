require "http"

module Presto
  module Core
    class Client
      attr_reader :provider, :api_key

      def initialize(provider:, api_key:)
        @provider = provider
        @api_key = api_key
      end

      def generate_text(prompt, model: "gpt-3.5-turbo", **options)
        # Initial implementation will focus on OpenRouter
        response = HTTP
          .headers(accept: "application/json")
          .auth("Bearer #{api_key}")
          .post(
            "https://openrouter.ai/api/v1/chat/completions",
            json: {
              model: model,
              messages: [{ role: "user", content: prompt }],
              **options
            }
          )

        JSON.parse(response.body.to_s)
      rescue HTTP::Error => e
        raise Error, "API request failed: #{e.message}"
      end
    end
  end
end