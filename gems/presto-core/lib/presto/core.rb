# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core.rb

require_relative "core/version"
require_relative "core/errors"
require_relative "core/providers/base"
require_relative "core/providers/openrouter"
require_relative "core/providers/openai"
require_relative "core/parameters/definition"
require_relative "core/client"

module Presto
  module Core
    class Error < StandardError; end
  end
end
