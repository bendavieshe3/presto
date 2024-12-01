# spec/presto/core/providers/text_provider_spec.rb
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Presto::Core::Providers::TextProvider do
  let(:test_provider) do
    Class.new(described_class) do
      def available_models
        [{"id" => "test-model"}]
      end

      def default_model
        "test-model"
      end

      protected

      def generate_text(prompt, model, parameters)
        {"choices" => [{"message" => {"content" => "test response"}}]}
      end
    end
  end

  let(:api_key) { 'test_key' }
  let(:provider) { test_provider.new(api_key: api_key) }

  describe '#available_parameters' do
    it 'includes text_prompt parameter' do
      params = provider.available_parameters
      expect(params[:text_prompt]).to be_a(Presto::Core::Parameters::Definition)
      expect(params[:text_prompt].type).to eq(:string)
    end

    it 'includes common text generation parameters' do
      params = provider.available_parameters
      expect(params[:temperature]).to be_a(Presto::Core::Parameters::Definition)
      expect(params[:max_tokens]).to be_a(Presto::Core::Parameters::Definition)
      expect(params[:top_p]).to be_a(Presto::Core::Parameters::Definition)
    end

    it 'enforces text prompt constraints' do
      text_prompt = provider.available_parameters[:text_prompt]
      expect(text_prompt.constraints).to include(
        min_length: 1,
        max_length: 32768
      )
    end
  end

  describe '#generate' do
    it 'requires a text_prompt parameter' do
      expect {
        provider.generate(model: 'test-model', temperature: 0.5)
      }.to raise_error(Presto::Core::InvalidParameterError, /requires a text_prompt parameter/)
    end

    it 'validates text prompt length' do
      expect {
        provider.generate(model: 'test-model', text_prompt: '')
      }.to raise_error(Presto::Core::InvalidParameterError, /must have minimum length/)
    end

    it 'delegates to generate_text with correct parameters' do
      allow(provider).to receive(:generate_text).and_return({"choices" => []})
      
      params = { text_prompt: 'hello', temperature: 0.5 }
      provider.generate(model: 'test-model', **params)
      
      expect(provider).to have_received(:generate_text)
        .with('test-model', params)
    end
  end
end