# gems/presto-core/spec/presto/core/client_spec.rb
require 'spec_helper'

RSpec.describe Presto::Core::Client do
  let(:api_key) { 'test_key' }

  describe '.available_providers' do
    it 'returns array of supported provider names as strings' do
      providers = described_class.available_providers
      expect(providers).to be_an(Array)
      expect(providers).to include('openrouter', 'openai')
      expect(providers.all? { |p| p.is_a?(String) }).to be true
    end
  end

  describe '#initialize' do
    it 'creates an OpenRouter provider when specified' do
      client = described_class.new(provider: :openrouter, api_key: api_key)
      expect(client.provider).to be_a(Presto::Core::Providers::OpenRouter)
    end

    it 'raises error for unsupported providers' do
      expect {
        described_class.new(provider: :unsupported, api_key: api_key)
      }.to raise_error(Presto::Core::ProviderError, "Unsupported provider: unsupported")
    end
  end

  describe '#available_models' do
    let(:client) { described_class.new(provider: :openrouter, api_key: api_key) }

    it 'delegates to the provider' do
      expect(client.provider).to receive(:available_models)
      client.available_models
    end
  end

  describe '#generate_text' do
    let(:client) { described_class.new(provider: :openrouter, api_key: api_key) }
    let(:prompt) { 'test prompt' }
    let(:model) { 'test-model' }

    it 'delegates to the provider with correct parameters' do
      expect(client.provider).to receive(:generate_text)
        .with(prompt, model: model)
      client.generate_text(prompt, model: model)
    end
  end
end