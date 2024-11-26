# frozen_string_literal: true
# FILE: gems/presto-cli/lib/presto/cli.rb

require_relative 'cli/version'
require_relative 'cli/config'
require_relative 'cli/application'

module Presto
  module CLI
    class Error < StandardError; end
  end
end