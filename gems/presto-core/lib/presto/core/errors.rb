# frozen_string_literal: true
# FILE: lib/presto/core/errors.rb
module Presto
    module Core
      class Error < StandardError; end
      class InvalidModelError < Error; end
      class ProviderError < Error; end
      class ApiError < Error; end
      class ConfigurationError < Error; end
      
      class InvalidParameterError < Error
        attr_reader :parameter_name
        
        def initialize(message, parameter_name: nil)
          @parameter_name = parameter_name
          super(message)
        end
      end
    end
  end