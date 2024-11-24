# frozen_string_literal: true
# FILE: gems/presto-core/spec/spec_helper.rb
require 'bundler/setup'
require 'webmock/rspec'
require 'presto/core'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up any WebMock stubs after each test
  config.after(:each) do
    WebMock.reset!
  end
end