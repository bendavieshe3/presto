# spec/presto/cli/application_base_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Application do
  include PrestoSpec::OutputHelper
  include PrestoSpec::TestSetupHelper

  let(:app) { described_class }  # Change this to use the class instead of instance
  let(:config_file) { Presto::CLI::Config::CONFIG_FILE }

  before do
    setup_test_config
  end

  after do
    FileUtils.rm_f(config_file)
  end

  it "exits on unknown commands" do
    expect { 
      app.start(['nonexistent'])
    }.to raise_error(SystemExit)
  end

  # Other basic application behavior tests
end