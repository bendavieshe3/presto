# frozen_string_literal: true
# FILE: gems/presto-core/spec/presto/core/providers/openrouter_spec.rb
require 'spec_helper'

RSpec.describe Presto::Core::Providers::OpenRouter do
  let(:api_key) { 'test_key' }
  let(:provider) { described_class.new(api_key: api_key) }

  describe '#available_models' do
    let(:models_response) do
      {
        'data' => [
          { 'id' => 'model-1', 'name' => 'Model 1' },
          { 'id' => 'model-2', 'name' => 'Model 2' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{described_class::API_BASE}/models")
        .with(headers: { 'Authorization' => "Bearer #{api_key}" })
        .to_return(status: 200, body: models_response)
    end

    it 'fetches available models from the API' do
      models = provider.available_models
      expect(models).to be_an(Array)
      expect(models.first).to include('id', 'name')
    end

    context 'when API request fails' do
      before do
        stub_request(:get, "#{described_class::API_BASE}/models")
          .to_return(status: 500, body: '{"error": "Server error"}')
      end

      it 'raises an ApiError' do
        expect { provider.available_models }.to raise_error(Presto::Core::ApiError)
      end
    end
  end

  describe '#generate_text' do
    let(:model) { 'test-model' }
    let(:prompt) { 'Hello world' }
    let(:success_response) do
      {
        'choices' => [
          { 'message' => { 'content' => 'Response text' } }
        ]
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
        .to_return(status: 200, body: success_response)
    end

    it 'generates text using the specified model' do
      response = provider.generate_text(prompt, model: model)
      expect(response).to include('choices')
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
  end
end
