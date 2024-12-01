# spec/presto/core/providers/text_provider_spec.rb
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

      def perform_generation(prompt, model, parameters)
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
    end
  end

  describe '#generate_text' do
    it 'validates the text prompt as a parameter' do
      expect {
        provider.generate_text('', model: 'test-model')
      }.to raise_error(Presto::Core::InvalidParameterError, /text_prompt/)
    end
  end
end