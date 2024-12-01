# frozen_string_literal: true
# FILE: gems/presto-core/spec/presto/core/providers/base_spec.rb
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Presto::Core::Providers::Base do
  let(:api_key) { 'test_key' }
  
  describe '#initialize' do
    it 'requires an API key' do
      expect { described_class.new(api_key: nil) }.to raise_error(Presto::Core::ConfigurationError)
      expect { described_class.new(api_key: '') }.to raise_error(Presto::Core::ConfigurationError)
    end

    it 'accepts valid configuration' do
      expect { described_class.new(api_key: api_key) }.not_to raise_error
    end
  end

  describe 'interface requirements' do
    let(:provider) { described_class.new(api_key: api_key) }

    it 'requires #available_models implementation' do
      expect { provider.available_models }.to raise_error(NotImplementedError)
    end

    it 'requires #available_parameters implementation' do
      expect { provider.available_parameters }.to raise_error(NotImplementedError)
    end

    it 'requires #perform_generation implementation' do
      expect { provider.generate(model: 'test', text_prompt: 'test') }.to raise_error(NotImplementedError)
    end

    it 'requires #default_model implementation' do
      expect { provider.default_model }.to raise_error(NotImplementedError)
    end
  end

  describe '#generate' do
    let(:test_provider) do
      Class.new(described_class) do
        def available_models
          [{ "id" => "test-model" }]
        end

        def available_parameters(model: nil)
          {
            test_param: Presto::Core::Parameters::Definition.new(
              name: :test_param,
              type: :string,
              description: "Test parameter",
              constraints: { min_length: 1 }
            )
          }
        end

        def default_model
          "test-model"
        end

        protected

        def perform_generation(model, parameters)
          { "result" => "test" }
        end
      end
    end

    let(:provider) { test_provider.new(api_key: api_key) }

    it 'validates the model exists' do
      expect {
        provider.generate(model: 'nonexistent-model', test_param: 'value')
      }.to raise_error(Presto::Core::InvalidModelError)
    end

    it 'validates parameters against definitions' do
      expect {
        provider.generate(model: 'test-model', invalid_param: 'value')
      }.to raise_error(Presto::Core::InvalidParameterError, /Unknown parameter/)
    end

    it 'calls perform_generation with validated parameters' do
      expect(provider).to receive(:perform_generation)
        .with('test-model', { test_param: 'value' })
        .and_return({ "result" => "test" })

      provider.generate(model: 'test-model', test_param: 'value')
    end
  end
end