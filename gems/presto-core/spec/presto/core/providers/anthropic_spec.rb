# spec/presto/core/providers/anthropic_spec.rb
RSpec.describe Presto::Core::Providers::Anthropic do
  let(:api_key) { 'test_key' }
  let(:provider) { described_class.new(api_key: api_key) }

  # Keep provider-specific model tests
  describe '#available_models' do
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

  # Keep provider-specific parameter overrides
  describe '#available_parameters' do
    it 'overrides temperature constraints for Anthropic' do
      params = provider.available_parameters
      expect(params[:temperature].constraints).to include(min: 0.0, max: 1.0)
    end
  end

  describe '#generate' do
    let(:prompt) { 'Hello world' }
    let(:model) { 'claude-3-5-sonnet-20241022' }
    let(:anthropic_response) do
      {
        'content' => [{ 'type' => 'text', 'text' => 'Response text' }],
        'usage' => { 'input_tokens' => 10, 'output_tokens' => 20 }
      }.to_json
    end

    it 'transforms Anthropic response format correctly' do 
      stub_request(:post, "#{described_class::API_BASE}/messages")
        .to_return(status: 200, body: anthropic_response)

      response = provider.generate(model: model, text_prompt: prompt)
      expect(response['choices'].first['message']['content']).to eq('Response text')
      expect(response['usage']).to include('prompt_tokens', 'completion_tokens')
    end

    context 'with error responses' do
      it 'handles Anthropic-specific errors' do
        stub_request(:post, "#{described_class::API_BASE}/messages")
          .to_return(status: 400, body: { type: 'invalid_request_error', message: 'Context length exceeded' }.to_json)

        expect { 
          provider.generate(model: model, text_prompt: prompt)
        }.to raise_error(Presto::Core::ApiError, /Context length exceeded/)
      end
    end
  end
end