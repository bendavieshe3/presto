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

        def default_model
            "meta-llama/llama-3-8b-instruct"
        end

        private

        def validate_model(model)
          models_list = available_models
          return true if models_list.any? { |m| m["id"] == model }
          
          raise InvalidModelError, "Model '#{model}' is not available. Use 'presto models' to see available models."
        end

        def handle_response(response)
            if response.status.success?
              begin
                parsed_response = JSON.parse(response.body.to_s)
                block_given? ? yield(parsed_response) : parsed_response
              rescue JSON::ParserError => e
                raise ApiError, "Invalid success response format: #{e.message}"
              end
            else
              # For error responses, try parsing JSON first but fall back to raw body if needed
              begin
                parsed_response = JSON.parse(response.body.to_s)
                error_message = if parsed_response.is_a?(Hash)
                  # Try simple error first, then nested message
                  parsed_response['error']&.is_a?(String) ? parsed_response['error'] : 
                    parsed_response.dig('error', 'message') || 
                    parsed_response.to_s
                else
                  parsed_response.to_s
                end
              rescue JSON::ParserError
                # If JSON parsing fails, use the raw response body
                error_message = response.body.to_s
              end
              
              raise ApiError, error_message
            end
          end

      end
    end
  end
end