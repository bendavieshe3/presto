# frozen_string_literal: true
# FILE: spec/presto/core/providers/anthropic_spec.rb
require 'spec_helper'

RSpec.describe Presto::Core::Providers::Anthropic do
  let(:api_key) { 'test_key' }
  let(:provider) { described_class.new(api_key: api_key) }
  let(:api_version) { '2023-06-01' }

  describe '#available_models' do
    it 'returns the list of supported Claude models' do
      models = provider.available_models
      expect(models).to be_an(Array)
      expect(models.first).to include(
        'id',
        'name',
        'description',
        'context_length'
      )
    end

    it 'includes Claude 3.5 models' do
      models = provider.available_models
      model_ids = models.map { |m| m['id'] }
      expect(model_ids).to include('claude-3-5-sonnet-20241022', 'claude-3-5-haiku-20241022')
    end

    it 'provides correct model information' do
      sonnet = provider.available_models.find { |m| m['id'] == 'claude-3-5-sonnet-20241022' }
      expect(sonnet).to include(
        'name' => 'Claude 3.5 Sonnet',
        'description' => 'Latest balanced model with enhanced capabilities',
        'context_length' => 200000
      )
    end
  end

  describe '#generate_text' do
    let(:model) { 'claude-3-5-sonnet-20241022' }
    let(:prompt) { 'Hello world' }
    let(:anthropic_response) do
      {
        'id' => 'msg_123',
        'model' => model,
        'role' => 'assistant',
        'content' => [
          {
            'type' => 'text',
            'text' => 'Response text'
          }
        ],
        'usage' => {
          'input_tokens' => 10,
          'output_tokens' => 20
        }
      }.to_json
    end

    before do
      # Stub the model validation
      allow(provider).to receive(:validate_model).and_return(true)
    end

    it 'generates text using the specified model' do
      stub = stub_request(:post, "#{described_class::API_BASE}/messages")
        .with(
          headers: {
            'accept' => 'application/json',
            'anthropic-version' => '2023-06-01',
            'content-type' => 'application/json',
            'x-api-key' => api_key,
            'connection' => 'close',
            'host' => 'api.anthropic.com',
            'user-agent' => /^http\.rb/
          },
          body: hash_including({
            model: model,
            messages: [{ role: 'user', content: prompt }],
            max_tokens: 1024
          })
        )
        .to_return(status: 200, body: anthropic_response)

      response = provider.generate_text(prompt, model: model)
      expect(response['choices'].first['message']['content']).to eq('Response text')
      expect(response['usage']).to include('prompt_tokens', 'completion_tokens')
      expect(stub).to have_been_requested
    end

    context 'with valid parameters' do
      it 'correctly includes supported parameters in the request' do
        stub = stub_request(:post, "#{described_class::API_BASE}/messages")
          .with(
            headers: {
              'accept' => 'application/json',
              'anthropic-version' => '2023-06-01',
              'content-type' => 'application/json',
              'x-api-key' => api_key,
              'connection' => 'close',
              'host' => 'api.anthropic.com',
              'user-agent' => /^http\.rb/
            },
            body: hash_including({
              temperature: 0.7,
              max_tokens: 100,
              top_p: 0.9
            })
          )
          .to_return(status: 200, body: anthropic_response)

        provider.generate_text(
          prompt,
          model: model,
          temperature: 0.7,
          max_tokens: 100,
          top_p: 0.9
        )

        expect(stub).to have_been_requested
      end
    end

    context 'when model validation fails' do
      before do
        allow(provider).to receive(:validate_model)
          .and_raise(Presto::Core::InvalidModelError, 'Invalid model')
      end

      it 'raises an InvalidModelError' do
        expect { provider.generate_text(prompt, model: model) }
          .to raise_error(Presto::Core::InvalidModelError)
      end
    end

    context 'with error responses' do
      [
        {
          scenario: 'invalid model',
          response: {
            type: 'invalid_request_error',
            message: 'Model not found'
          }.to_json,
          status: 400,
          expected_error: 'Model not found'
        },
        {
          scenario: 'context length exceeded',
          response: {
            type: 'invalid_request_error',
            message: 'Maximum context length exceeded'
          }.to_json,
          status: 400,
          expected_error: 'Maximum context length exceeded'
        }
      ].each do |test_case|
        context "with #{test_case[:scenario]}" do
          before do
            stub_request(:post, "#{described_class::API_BASE}/messages")
              .to_return(
                status: test_case[:status],
                body: test_case[:response]
              )
          end

          it 'raises an ApiError with the appropriate message' do
            expect { 
              provider.generate_text(prompt, model: model)
            }.to raise_error(
              Presto::Core::ApiError,
              test_case[:expected_error]
            )
          end
        end
      end
    end
  end

  describe '#available_parameters' do
    it 'returns the expected parameter definitions' do
      params = provider.available_parameters
      expect(params).to include(:temperature, :max_tokens, :top_p)
      
      # Verify temperature constraints
      temp_param = params[:temperature]
      expect(temp_param).to be_a(Presto::Core::Parameters::Definition)
      expect(temp_param.constraints).to include(min: 0.0, max: 1.0)
      
      # Verify max_tokens constraints
      tokens_param = params[:max_tokens]
      expect(tokens_param).to be_a(Presto::Core::Parameters::Definition)
      expect(tokens_param.constraints).to include(min: 1)
    end
  end

  describe '#default_model' do
    it 'returns Claude 3.5 Sonnet as the default model' do
      expect(provider.default_model).to eq('claude-3-5-sonnet-20241022')
    end
  end
end