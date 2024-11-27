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
  
          def generate_text(prompt, model:, **options)
            raise NotImplementedError, "#{self.class} must implement #generate_text"
          end
  
          def validate_model(model)
            raise NotImplementedError, "#{self.class} must implement #validate_model"
          end
  
          def default_model
            raise NotImplementedError, "#{self.class} must implement #default_model"
          end

          private
  
          def validate_configuration
            raise ConfigurationError, "API key is required" if api_key.nil? || api_key.empty?
          end
        end
      end
    end
  end