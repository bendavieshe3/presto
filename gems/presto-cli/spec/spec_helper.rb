# frozen_string_literal: true
require "fileutils"
require "tmpdir"

# Set up test environment before loading any app code
ENV['PRESTO_CONFIG_PATH'] = Dir.mktmpdir('presto-test-')

require "thor"
require "presto/cli"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:suite) do
    # Clean up test directory
    FileUtils.remove_entry(@test_config_dir) if @test_config_dir
    ENV.delete('PRESTO_CONFIG_PATH')
  end
end
