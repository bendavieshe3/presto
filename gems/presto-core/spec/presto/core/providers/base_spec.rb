# frozen_string_literal: true
# FILE: gems/presto-core/spec/presto/core/providers/base_spec.rb
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

    it 'requires #generate_text implementation' do
      expect { provider.generate_text('test', model: 'test') }.to raise_error(NotImplementedError)
    end

    it 'requires #validate_model implementation' do
      expect { provider.send(:validate_model, 'test') }.to raise_error(NotImplementedError)
    end
  end
end