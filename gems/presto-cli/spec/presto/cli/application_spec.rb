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

  describe '#generate command' do
    let(:model_response) do
      {
        'choices' => [
          { 'message' => { 'content' => 'Test response' } }
        ]
      }
    end

    context 'with valid configuration' do
      before do
        ENV['OPENROUTER_API_KEY'] = 'test_key'
        allow_any_instance_of(Presto::Core::Providers::OpenRouter)
          .to receive(:generate_text)
          .and_return(model_response)
      end

      it 'generates text successfully' do
        output = capture_output { app.generate('test prompt') }
        expect(output).to include('Test response')
      end

      it 'shows additional information in verbose mode' do
        output = capture_output { app.invoke(:generate, ['test prompt'], verbose: true) }
        expect(output).to include('Using provider: openrouter')
        expect(output).to include('Using model:')
      end

      it 'outputs raw response in JSON format' do
        output = capture_output { app.invoke(:generate, ['test prompt'], format: 'json') }
        json = JSON.parse(output)
        expect(json['choices']).to be_an(Array)
      end
    end

    context 'with provider validation' do
      it 'raises error for invalid provider' do
        expect {
          app.invoke(:generate, ['test prompt'], provider: 'invalid')
        }.to raise_error(Thor::Error, /Unknown provider/)
      end

      it 'raises error when provider is not configured' do
        expect {
          app.generate('test prompt')
        }.to raise_error(Thor::Error, /Provider .* is not configured/)
      end
    end
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