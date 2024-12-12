# spec/support/shared_examples/text_provider.rb
RSpec.shared_examples "a text provider" do
    describe "#available_parameters" do
      it "includes required text parameters" do
        params = provider.available_parameters
        expect(params[:text_prompt]).to be_a(Presto::Core::Parameters::Definition)
        expect(params[:temperature]).to be_a(Presto::Core::Parameters::Definition)
        expect(params[:max_tokens]).to be_a(Presto::Core::Parameters::Definition)
      end
  
      it "validates text prompt length" do
        expect {
          provider.generate_text('', model: 'test-model')
        }.to raise_error(Presto::Core::InvalidParameterError, /text_prompt/)
      end
    end
  
    describe "#generate_text" do
      let(:prompt) { "Test prompt" }
      let(:model) { "test-model" }
  
      before do
        allow(provider).to receive(:validate_model).and_return(true)
      end
  
      it "validates parameters before generation" do
        expect(provider).to receive(:validate_parameters)
        allow(provider).to receive(:perform_generation).and_return({})
        provider.generate_text(prompt, model: model)
      end
    end
  end