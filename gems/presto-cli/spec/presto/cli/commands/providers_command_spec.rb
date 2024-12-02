# spec/presto/cli/commands/providers_command_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Application do
  include PrestoSpec::OutputHelper
  include PrestoSpec::TestSetupHelper

  let(:app) { described_class.new }

  before do
    setup_test_config
  end

  describe '#providers command' do
    context 'when no providers are configured' do
      it 'shows openrouter as default but unconfigured' do
        output = capture_output { app.providers }
        expect(output).to include('openrouter (default)')
        expect(output).to include('not configured')
      end
    end

    context 'with configured providers' do
      before do
        ENV['OPENROUTER_API_KEY'] = 'test_key'
      end

      it 'shows configured status for providers with API keys' do
        output = capture_output { app.providers }
        expect(output).to include('openrouter (default)')
        expect(output).to include('configured')
      end
    end

    context 'with JSON format' do
      before do
        ENV['OPENROUTER_API_KEY'] = 'test_key'
      end

      it 'outputs provider information in JSON format' do
        output = capture_output { app.invoke(:providers, [], format: 'json') }
        json = JSON.parse(output)
        expect(json['default_provider']).to eq('openrouter')
        expect(json['configured_providers']).to include('openrouter')
      end
    end
  end
end