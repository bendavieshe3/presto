# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core/errors.rb
module Presto
    module Core
      class Error < StandardError; end
      class InvalidModelError < Error; end
      class ProviderError < Error; end
      class ApiError < Error; end
      class ConfigurationError < Error; end
    end
  end