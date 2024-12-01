# frozen_string_literal: true
# FILE: lib/presto/core/providers/openai.rb
require 'http'
require 'json'

module Presto
  module Core
    module Providers
      class OpenAI < TextProvider
        API_BASE = "https://api.openai.com/v1".freeze

        def available_parameters(model: nil)
            super.merge(
                presence_penalty: Parameters::Definition.new(
                    name: :presence_penalty,
                    type: :float,
                    description: "Penalty for new tokens based on presence in text",
                    default: 0.0,
                    constraints: { min: -2.0, max: 2.0 }
                ),
                frequency_penalty: Parameters::Definition.new(
                    name: :frequency_penalty,
                    type: :float,
                    description: "Penalty for new tokens based on frequency in text",
                    default: 0.0,
                    constraints: { min: -2.0, max: 2.0 }
                )
            )
        end
    
        def available_models
          response = HTTP
            .headers(accept: "application/json")
            .auth("Bearer #{api_key}")
            .get("#{API_BASE}/models")

          handle_response(response) do |body|
            # Transform OpenAI's model format to match our interface
            body.fetch("data", []).map do |model|
              {
                "id" => model["id"],
                "name" => model["id"], # OpenAI doesn't provide separate names
                "description" => model["description"],
                # Note: OpenAI provides context_window instead of context_length
                "context_length" => model["context_window"],
                # Add pricing if we want to map known model prices
                "pricing" => get_model_pricing(model["id"])
              }
            end
          end
        rescue HTTP::Error => e
          raise ApiError, "Failed to fetch available models: #{e.message}"
        end

        def default_model
          "gpt-3.5-turbo"
        end

        protected


        def perform_generation(model, parameters)
          response = HTTP
            .headers(accept: "application/json")
            .auth("Bearer #{api_key}")
            .post(
              "#{API_BASE}/chat/completions",
              json: {
                model: model,
                messages: [{ role: "user", content: parameters[:text_prompt] }],
                **sanitize_parameters(parameters)
              }
            )

          handle_response(response) do |body|
            # Transform OpenAI's response format to match our interface
            {
              "choices" => body["choices"].map { |choice|
                {
                  "message" => {
                    "content" => choice["message"]["content"],
                    "role" => choice["message"]["role"]
                  },
                  "finish_reason" => choice["finish_reason"]
                }
              },
              "usage" => body["usage"]
            }
          end
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

        def sanitize_parameters(parameters)
          # Only pass through parameters that OpenAI supports
          valid_params = [:temperature, :max_tokens, :top_p, :presence_penalty, :frequency_penalty]
          parameters.select { |k,_| valid_params.include?(k) }
        end

        def get_model_pricing(model_id)
          # This could be expanded with actual pricing data
          case model_id
          when /^gpt-4/
            { "prompt" => 0.03, "completion" => 0.06 }
          when /^gpt-3.5-turbo/
            { "prompt" => 0.002, "completion" => 0.002 }
          else
            nil
          end
        end
      end
    end
  end
end