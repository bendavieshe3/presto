# frozen_string_literal: true
# FILE: gems/presto-cli/spec/presto/cli/application_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Application do
  let(:app) { described_class.new }
  let(:config_file) { Presto::CLI::Config::CONFIG_FILE }
  
  # Helper for capturing CLI output
  def capture_output(&block)
    original_stdout = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  before do
    # Ensure clean environment for each test
    ENV.delete('OPENROUTER_API_KEY')
    ENV.delete('OPENAI_API_KEY')
    FileUtils.mkdir_p(File.dirname(config_file))
  end

  after do
    FileUtils.rm_f(config_file)
  end
  
end