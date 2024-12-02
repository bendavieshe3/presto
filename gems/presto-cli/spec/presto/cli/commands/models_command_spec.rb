# spec/presto/cli/commands/models_command_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Application do
  include PrestoSpec::OutputHelper
  include PrestoSpec::TestSetupHelper

  let(:app) { described_class.new }
  let(:sample_models) do
    [
      {
        'id' => 'model-1',
        'name' => 'Test Model',
        'description' => 'A test model',
        'context_length' => 4096,
        'pricing' => { 'prompt' => 0.001 }
      }
    ]
  end

  before do
    setup_test_config
    ENV['OPENROUTER_API_KEY'] = 'test_key'
    allow_any_instance_of(Presto::Core::Providers::OpenRouter)
      .to receive(:available_models)
      .and_return(sample_models)
  end

  describe '#models command' do
    let(:sample_models) do
      [
        {
          'id' => 'model-1',
          'name' => 'Test Model',
          'description' => 'A test model',
          'context_length' => 4096,
          'pricing' => { 'prompt' => 0.001 }
        }
      ]
    end

    before do
      ENV['OPENROUTER_API_KEY'] = 'test_key'
      allow_any_instance_of(Presto::Core::Providers::OpenRouter)
        .to receive(:available_models)
        .and_return(sample_models)
    end

    it 'lists models in basic format' do
      output = capture_output { app.models }
      expect(output).to include('model-1')
      expect(output).to include('Test Model')
    end

    it 'shows detailed model information in verbose mode' do
      output = capture_output { app.invoke(:models, [], verbose: true) }
      expect(output).to include('description: A test model')
      expect(output).to include('context_length: 4096')
      expect(output).to include('pricing: $0.001/1k tokens')
    end

    it 'outputs models in JSON format' do
      output = capture_output { app.invoke(:models, [], format: 'json') }
      json = JSON.parse(output)
      expect(json).to be_an(Array)
      expect(json.first['id']).to eq('model-1')
    end

    context 'with provider validation' do
      it 'raises error when provider is not configured' do
        ENV.delete('OPENROUTER_API_KEY')
        expect {
          app.models
        }.to raise_error(Thor::Error, /Provider .* is not configured/)
      end
    end
  end
end