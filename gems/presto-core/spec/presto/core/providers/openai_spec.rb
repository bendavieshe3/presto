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

    it 'transforms OpenAI model info correctly' do
      models = provider.available_models
      model = models.find { |m| m['id'] == 'gpt-4' }
      expect(model).to include(
        'context_length' => 8192,
        'pricing' => { 'prompt' => 0.03, 'completion' => 0.06 }
      )
    end
  end

  describe '#available_parameters' do
    it 'includes OpenAI-specific parameters' do
      params = provider.available_parameters
      expect(params[:presence_penalty]).to be_a(Presto::Core::Parameters::Definition)
      expect(params[:frequency_penalty]).to be_a(Presto::Core::Parameters::Definition)
    end

    it 'configures presence_penalty correctly' do
      param = provider.available_parameters[:presence_penalty]
      expect(param.constraints).to include(min: -2.0, max: 2.0)
    end
  end

  describe '#generate' do
    let(:prompt) { 'Hello world' }
    let(:model) { 'gpt-3.5-turbo' }
    let(:openai_response) do
      {
        'choices' => [
          {
            'message' => { 'content' => 'Response text', 'role' => 'assistant' },
            'finish_reason' => 'stop'
          }
        ],
        'usage' => { 'prompt_tokens' => 10, 'completion_tokens' => 20, 'total_tokens' => 30 }
      }.to_json
    end

    it 'transforms OpenAI response format correctly' do
      stub_request(:get, "#{described_class::API_BASE}/models")
        .with(headers: { 'Authorization' => "Bearer #{api_key}" })
        .to_return(status: 200, body: {
          'data' => [{ 'id' => model }]
        }.to_json)      
      stub_request(:post, "#{described_class::API_BASE}/chat/completions")
        .to_return(status: 200, body: openai_response)

      response = provider.generate(model: model, text_prompt: prompt)
      expect(response['choices'].first['message']['content']).to eq('Response text')
      expect(response['usage']).to include('prompt_tokens', 'completion_tokens', 'total_tokens')
    end
  end
end