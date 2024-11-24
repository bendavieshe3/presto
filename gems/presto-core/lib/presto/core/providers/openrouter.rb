# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core/providers/openrouter.rb
require 'http'
require 'json'

module Presto
  module Core
    module Providers
      class OpenRouter < Base
        API_BASE = "https://openrouter.ai/api/v1".freeze

        def available_models
          response = HTTP
            .headers(accept: "application/json")
            .auth("Bearer #{api_key}")
            .get("#{API_BASE}/models")

          handle_response(response) do |body|
            body.fetch("data", [])
          end
        rescue HTTP::Error => e
          raise ApiError, "Failed to fetch available models: #{e.message}"
        end

        def generate_text(prompt, model:, **options)
          validate_model(model)
          
          response = HTTP
            .headers(accept: "application/json")
            .auth("Bearer #{api_key}")
            .post(
              "#{API_BASE}/chat/completions",
              json: {
                model: model,
                messages: [{ role: "user", content: prompt }],
                **options
              }
            )

          handle_response(response)
        rescue HTTP::Error => e
          raise ApiError, "API request failed: #{e.message}"
        end

        private

        def validate_model(model)
          models_list = available_models
          return true if models_list.any? { |m| m["id"] == model }
          
          raise InvalidModelError, "Model '#{model}' is not available. Use 'presto models' to see available models."
        end

        def handle_response(response)
          parsed_response = JSON.parse(response.body.to_s)
          
          if response.status.success?
            block_given? ? yield(parsed_response) : parsed_response
          else
            error_message = parsed_response.dig("error", "message") || "Unknown error occurred"
            raise ApiError, error_message
          end
        rescue JSON::ParserError => e
          raise ApiError, "Invalid response format: #{e.message}"
        end
      end
    end
  end
end