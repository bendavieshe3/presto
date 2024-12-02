# spec/presto/cli/commands/generate_command_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Application do
  include PrestoSpec::OutputHelper
  include PrestoSpec::TestSetupHelper

  let(:app) { described_class.new }
  let(:prompt) { 'test prompt' }
  let(:model_response) do
    {
      'choices' => [
        { 'message' => { 'content' => 'Test response' } }
      ]
    }
  end

  describe '#generate command' do
    let(:app) { described_class.new }
    let(:prompt) { 'test prompt' }
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
          .to receive(:generate)
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

    context 'when no model is specified' do
      before do
        ENV['OPENAI_API_KEY'] = 'test_key'
        allow_any_instance_of(Presto::Core::Providers::OpenAI)
          .to receive(:default_model)
          .and_return('gpt-3.5-turbo')
        allow_any_instance_of(Presto::Core::Providers::OpenAI)
          .to receive(:generate)
          .and_return(model_response)
      end

      it 'uses the provider default model' do
        expect_any_instance_of(Presto::Core::Providers::OpenAI)
          .to receive(:generate)
          .with(model: 'gpt-3.5-turbo', text_prompt: 'test prompt')
              
        app.invoke(:generate, ['test prompt'], provider: 'openai')
      end
    end

    context 'with verbose output' do
      before do
        ENV['OPENAI_API_KEY'] = 'test_key'
        allow_any_instance_of(Presto::Core::Providers::OpenAI)
          .to receive(:generate)
          .and_return(model_response)
      end

      it 'displays default model name when no model specified' do
        default_model = 'gpt-3.5-turbo'
        allow_any_instance_of(Presto::Core::Providers::OpenAI)
          .to receive(:default_model)
          .and_return(default_model)

        output = capture_output { 
          app.invoke(:generate, ['test prompt'], verbose: true, provider: 'openai') 
        }
        
        expect(output).to include("Using provider: openai")
        expect(output).to include("Using model: #{default_model}")
      end

      it 'displays specified model name when model provided' do
        specified_model = 'gpt-4'
        
        output = capture_output { 
          app.invoke(:generate, ['test prompt'], 
            verbose: true, 
            provider: 'openai', 
            model: specified_model) 
        }
        
        expect(output).to include("Using provider: openai")
        expect(output).to include("Using model: #{specified_model}")
      end

      it 'shows the generating message after model info' do
        output = capture_output { 
          app.invoke(:generate, ['test prompt'], verbose: true, provider: 'openai') 
        }
        
        lines = output.split("\n")
        provider_line_index = lines.index { |line| line.include?("Using provider:") }
        model_line_index = lines.index { |line| line.include?("Using model:") }
        generating_line_index = lines.index { |line| line.include?("Generating response...") }
        
        expect(provider_line_index).to be < model_line_index
        expect(model_line_index).to be < generating_line_index
      end
    end
  end

end