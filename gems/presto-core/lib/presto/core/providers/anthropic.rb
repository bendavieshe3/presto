# frozen_string_literal: true
# FILE: lib/presto/core/providers/anthropic.rb
require 'http'
require 'json'

module Presto
  module Core
    module Providers
      class Anthropic < TextProvider
        API_BASE = "https://api.anthropic.com/v1".freeze
        API_VERSION = "2023-06-01".freeze

        def available_parameters(model: nil)
            params = super
            # Override temperature constraints for Anthropic
            params[:temperature] = Parameters::Definition.new(
              name: :temperature,
              type: :float,
              description: "Controls randomness in the output",
              default: 0.7,
              constraints: { min: 0.0, max: 1.0 }  # Anthropic's specific range
            )
            params
          end

        def available_models
          # Return current Claude models
          [
            {
              "id" => "claude-3-opus-20240229",
              "name" => "Claude 3 Opus",
              "description" => "Most capable Claude model, with improved instruction following",
              "context_length" => 200000
            },
            {
              "id" => "claude-3-sonnet-20240229",
              "name" => "Claude 3 Sonnet",
              "description" => "Balanced model for most tasks",
              "context_length" => 200000
            },
            {
              "id" => "claude-3-haiku-20240307",
              "name" => "Claude 3 Haiku",
              "description" => "Fast, efficient model for simple tasks",
              "context_length" => 200000
            },
            {
              "id" => "claude-3-5-sonnet-20241022",
              "name" => "Claude 3.5 Sonnet",
              "description" => "Latest balanced model with enhanced capabilities",
              "context_length" => 200000
            },
            {
              "id" => "claude-3-5-haiku-20241022",
              "name" => "Claude 3.5 Haiku",
              "description" => "Latest fast model for simple tasks",
              "context_length" => 200000
            }
          ]
        end

        def default_model
          "claude-3-5-sonnet-20241022"
        end

        protected

        def perform_generation(prompt, model, parameters)
          headers = default_headers
          
          response = HTTP
            .headers(headers)
            .post(
              "#{API_BASE}/messages",
              json: {
                model: model,
                messages: [{ role: "user", content: prompt }],
                max_tokens: parameters.fetch(:max_tokens, 1024),  # Ensure max_tokens is always present
                **sanitize_parameters(parameters.reject { |k,_| k == :max_tokens })  # Remove max_tokens from sanitized params since we handle it explicitly
              }
            )

          handle_response(response) do |body|
            transform_response(body)
          end
        rescue HTTP::Error => e
          raise ApiError, "API request failed: #{e.message}"
        end

        private

        def default_headers
          {
            "accept" => "application/json",
            "content-type" => "application/json",
            "x-api-key" => api_key,
            "anthropic-version" => API_VERSION
          }
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
            handle_error_response(response)
          end
        end

        def handle_error_response(response)
          begin
            parsed_response = JSON.parse(response.body.to_s)
            error_message = if parsed_response.is_a?(Hash)
              parsed_response["message"] || 
                parsed_response["error"] || 
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
          # Only pass through parameters that Anthropic supports
          valid_params = [:temperature, :max_tokens, :top_p]
          parameters.select { |k,_| valid_params.include?(k) }
        end

        def transform_response(response)
          # Transform Anthropic's response format to match our standard format
          content = response.dig("content", 0, "text") || ""
          {
            "choices" => [
              {
                "message" => {
                  "content" => content,
                  "role" => "assistant"
                }
              }
            ],
            "usage" => {
              "prompt_tokens" => response.dig("usage", "input_tokens") || 0,
              "completion_tokens" => response.dig("usage", "output_tokens") || 0,
              "total_tokens" => (
                (response.dig("usage", "input_tokens") || 0) +
                (response.dig("usage", "output_tokens") || 0)
              )
            }
          }
        end
      end
    end
  end
end