# spec/presto/cli/commands/generate_command_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Application do
  include PrestoSpec::OutputHelper
  include PrestoSpec::TestSetupHelper

  let(:app) { described_class.new }
  let(:prompt) { 'test prompt' }
  let(:model_response) do
    {
      'choices' => [
        { 'message' => { 'content' => 'Test response' } }
      ]
    }
  end

  describe '#generate command' do
    context 'with valid configuration' do
      before do
        ENV['OPENROUTER_API_KEY'] = 'test_key'
        allow_any_instance_of(Presto::Core::Providers::OpenRouter)
          .to receive(:generate)
          .and_return(model_response)
      end

      # ... existing generate specs ...
    end
  end
end