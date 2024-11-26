# frozen_string_literal: true
# FILE: spec/presto/core/providers/openai_spec.rb
require 'spec_helper'

RSpec.describe Presto::Core::Providers::OpenAI do
  let(:api_key) { 'test_key' }
  let(:provider) { described_class.new(api_key: api_key) }

  describe '#available_models' do
    let(:models_response) do
      {
        'data' => [
          {
            'id' => 'gpt-4',
            'description' => 'Most capable GPT-4 model',
            'context_window' => 8192
          },
          {
            'id' => 'gpt-3.5-turbo',
            'description' => 'Most capable GPT-3.5 model',
            'context_window' => 4096
          }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{described_class::API_BASE}/models")
        .with(headers: { 'Authorization' => "Bearer #{api_key}" })
        .to_return(status: 200, body: models_response)
    end

    it 'fetches and transforms available models from the API' do
      models = provider.available_models
      expect(models).to be_an(Array)
      expect(models.first).to include(
        'id',
        'name',
        'description',
        'context_length',
        'pricing'
      )
    end

    it 'maintains consistent model information structure' do
      model = provider.available_models.first
      expect(model['context_length']).to eq(8192)
      expect(model['pricing']).to be_a(Hash)
    end

    context 'when API request fails' do
      [
        {
          scenario: 'structured error response',
          response: { error: { message: 'Invalid API key' } }.to_json,
          expected_error: 'Invalid API key'
        },
        {
          scenario: 'simple error response',
          response: { error: 'Rate limit exceeded' }.to_json,
          expected_error: 'Rate limit exceeded'
        },
        {
          scenario: 'unparseable response',
          response: 'Internal Server Error',
          expected_error: 'Internal Server Error'
        }
      ].each do |test_case|
        context "with #{test_case[:scenario]}" do
          before do
            stub_request(:get, "#{described_class::API_BASE}/models")
              .to_return(status: 500, body: test_case[:response])
          end

          it 'raises an ApiError with the appropriate message' do
            expect { provider.available_models }.to raise_error(
              Presto::Core::ApiError,
              test_case[:expected_error]
            )
          end
        end
      end
    end
  end

  describe '#generate_text' do
    let(:model) { 'gpt-4' }
    let(:prompt) { 'Hello world' }
    let(:openai_response) do
      {
        'choices' => [
          {
            'message' => {
              'content' => 'Response text',
              'role' => 'assistant'
            },
            'finish_reason' => 'stop'
          }
        ],
        'usage' => {
          'prompt_tokens' => 10,
          'completion_tokens' => 20,
          'total_tokens' => 30
        }
      }.to_json
    end

    before do
      # Stub the model validation
      allow(provider).to receive(:validate_model).and_return(true)
      
      stub_request(:post, "#{described_class::API_BASE}/chat/completions")
        .with(
          headers: { 'Authorization' => "Bearer #{api_key}" },
          body: hash_including({
            model: model,
            messages: [{ role: 'user', content: prompt }]
          })
        )
        .to_return(status: 200, body: openai_response)
    end

    it 'generates text using the specified model' do
      response = provider.generate_text(prompt, model: model)
      expect(response['choices'].first['message']['content']).to eq('Response text')
      expect(response['usage']).to include('prompt_tokens', 'completion_tokens')
    end

    it 'maintains consistent response structure' do
      response = provider.generate_text(prompt, model: model)
      expect(response).to match(
        'choices' => [
          hash_including(
            'message' => hash_including('content', 'role'),
            'finish_reason' => 'stop'
          )
        ],
        'usage' => hash_including(
          'prompt_tokens',
          'completion_tokens',
          'total_tokens'
        )
      )
    end

    context 'with additional options' do
      it 'sanitizes and maps options correctly' do
        stub = stub_request(:post, "#{described_class::API_BASE}/chat/completions")
          .with(
            body: hash_including({
              temperature: 0.7,
              max_tokens: 100
            })
          )
          .to_return(status: 200, body: openai_response)

        provider.generate_text(
          prompt,
          model: model,
          temperature: 0.7,
          max_tokens: 100,
          unsupported_option: 'ignored'
        )

        expect(stub).to have_been_requested
      end
    end
  end
end