# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core/providers/openrouter.rb
require 'http'
require 'json'

module Presto
  module Core
    module Providers
      class OpenRouter < TextProvider
        API_BASE = "https://openrouter.ai/api/v1".freeze

        def available_parameters(model: nil)
            super.merge(
              stop: Parameters::Definition.new(
                name: :stop,
                type: :string,
                description: "Sequence where generation should stop",
                default: nil
              )
            )
        end
        
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

        def default_model
            "meta-llama/llama-3-8b-instruct"
        end

        protected

        def perform_generation(prompt, model, parameters)
          response = HTTP
            .headers(accept: "application/json")
            .auth("Bearer #{api_key}")
            .post(
              "#{API_BASE}/chat/completions",
              json: {
                model: model,
                messages: [{ role: "user", content: prompt }],
                **parameters
              }
            )

          handle_response(response)
        rescue HTTP::Error => e
          raise ApiError, "API request failed: #{e.message}"
        end

        private

        def handle_response(response)
          if response.status.success?
            begin
              parsed_response = JSON.parse(response.body.to_s)
              block_given? ? yield(parsed_response) : parsed_response
            rescue JSON::ParserError => e
              raise ApiError, "Invalid success response format: #{e.message}"
            end
          else
            handle_error_response(response)
          end
        end

        def handle_error_response(response)
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
            error_message = response.body.to_s
          end
          
          raise ApiError, error_message
        end
      end
    end
  end
end