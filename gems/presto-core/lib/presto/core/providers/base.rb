# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core/providers/base.rb
module Presto
    module Core
      module Providers
        class Base
          attr_reader :api_key
  
          def initialize(api_key:)
            @api_key = api_key
            validate_configuration
          end
  
          # Each provider should return an array of hashes containing model information
          # Required fields:
          # - 'id' or 'model': The model identifier used for API calls
          # Optional fields that will be displayed in verbose mode if present:
          # - 'name': Display name of the model
          # - 'description': Brief description
          # - 'context_length': Maximum context length
          # - 'pricing': Hash containing pricing information
          def available_models
            raise NotImplementedError, "#{self.class} must implement #available_models"
          end
  
          # Each provider must return a hash of parameter name => ParameterDefinition
          # describing what parameters they accept and how to validate them
          def available_parameters(model: nil)
            raise NotImplementedError, "#{self.class} must implement #available_parameters"
          end
  
          def generate_text(prompt, model:, **parameters)
            validate_model(model)
            validate_parameters(parameters, model: model)
            perform_generation(prompt, model, parameters)
          end
  
          def default_model
            raise NotImplementedError, "#{self.class} must implement #default_model"
          end
  
          protected
  
          def validate_parameters(parameters, model: nil)
            available = available_parameters(model: model)
            parameters.each do |name, value|
              unless available.key?(name)
                raise InvalidParameterError.new(
                  "Unknown parameter for #{self.class.name}: #{name}",
                  parameter_name: name
                )
              end
              
              begin
                available[name].validate(value)
              rescue InvalidParameterError => e
                raise InvalidParameterError.new(
                  e.message,
                  parameter_name: e.parameter_name
                )
              end
            end
          end
  
          def perform_generation(prompt, model, parameters)
            raise NotImplementedError, "#{self.class} must implement #perform_generation"
          end
  
          private
  
          def validate_configuration
            raise ConfigurationError, "API key is required" if api_key.nil? || api_key.empty?
          end
  
          def validate_model(model)
            models_list = available_models
            return true if models_list.any? { |m| m["id"] == model }
            raise InvalidModelError, "Model '#{model}' is not available. Use 'presto models' to see available models."
          end
        end
      end
    end
  end