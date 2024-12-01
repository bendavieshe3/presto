# spec/integration/text_generation_spec.rb
require 'spec_helper'

RSpec.describe "Text Generation Integration" do
  let(:api_key) { 'test_key' }
  let(:prompt) { "Hello world" }
  
  shared_examples "text generation" do |provider_name|
    let(:client) { Presto::Core::Client.new(provider: provider_name, api_key: api_key) }

    it "validates parameters through the provider hierarchy" do
      # Stub models list so validation passes
      allow(client.provider).to receive(:available_models)
        .and_return([{"id" => "test-model"}])
      
      expect {
        client.generate_text(prompt, model: "test-model", temperature: 3.0)
      }.to raise_error(Presto::Core::InvalidParameterError, /temperature/)
    end

    it "includes both base and provider-specific parameters" do
      params = client.provider.available_parameters
      # Common text parameters from TextProvider
      expect(params.keys).to include(:text_prompt, :temperature, :max_tokens)
      # At least one provider-specific parameter
      expect(params.keys - [:text_prompt, :temperature, :max_tokens]).not_to be_empty
    end

    it "enforces model validation" do
      # Return empty models list to force validation failure
      allow(client.provider).to receive(:available_models)
        .and_return([])
      
      expect {
        client.generate_text(prompt, model: "non-existent-model")
      }.to raise_error(Presto::Core::InvalidModelError)
    end
  end

  # Test each provider
  Presto::Core::Client::AVAILABLE_PROVIDERS.each do |provider|
    context "with #{provider} provider" do
      it_behaves_like "text generation", provider
    end
  end
end