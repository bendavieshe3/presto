# frozen_string_literal: true
# FILE: spec/presto/core/providers/openrouter_spec.rb
require 'spec_helper'

RSpec.describe Presto::Core::Providers::OpenRouter do
  let(:api_key) { 'test_key' }
  let(:provider) { described_class.new(api_key: api_key) }

  describe '#available_models' do
    let(:models_response) do
      {
        'data' => [
          { 'id' => 'meta-llama/llama-3-8b-instruct', 'name' => 'Llama 3 8B' },
          { 'id' => 'anthropic/claude-3-sonnet', 'name' => 'Claude 3 Sonnet' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{described_class::API_BASE}/models")
        .with(headers: { 'Authorization' => "Bearer #{api_key}" })
        .to_return(status: 200, body: models_response)
    end

    it 'uses OpenRouter model info directly' do
      models = provider.available_models
      expect(models.first).to include(
        'id' => 'meta-llama/llama-3-8b-instruct',
        'name' => 'Llama 3 8B'
      )
    end
  end

  describe '#available_parameters' do
    it 'includes OpenRouter-specific parameters' do
      params = provider.available_parameters
      expect(params[:stop]).to be_a(Presto::Core::Parameters::Definition)
    end
  end

  describe '#generate' do
    let(:prompt) { 'Hello world' }
    let(:model) { 'meta-llama/llama-3-8b-instruct' }
    let(:success_response) do
      {
        'choices' => [
          { 'message' => { 'content' => 'Response text' } }
        ]
      }.to_json
    end

    it 'passes through OpenRouter response format' do
      stub_request(:get, "#{described_class::API_BASE}/models")
        .with(headers: { 'Authorization' => "Bearer #{api_key}" })
        .to_return(status: 200, body: {
          'data' => [{ 'id' => model }]
        }.to_json)      
      stub_request(:post, "#{described_class::API_BASE}/chat/completions")
        .to_return(status: 200, body: success_response)

      response = provider.generate(model: model, text_prompt: prompt)
      expect(response).to eq(JSON.parse(success_response))
    end
  end
end