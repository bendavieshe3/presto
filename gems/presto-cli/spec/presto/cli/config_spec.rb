# frozen_string_literal: true
# FILE: gems/presto-cli/spec/presto/cli/config_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Config do
  describe '.openrouter_api_key' do
    let(:config_file) { described_class::CONFIG_FILE }
    let(:api_key) { 'test_api_key' }

    before do
      # Clear environment variable
      ENV.delete('OPENROUTER_API_KEY')
      
      # Ensure config directory exists for tests
      FileUtils.mkdir_p(File.dirname(config_file))
    end

    after do
      # Clean up test config file
      FileUtils.rm_f(config_file)
    end

    context 'when environment variable is set' do
      it 'returns the environment variable value' do
        ENV['OPENROUTER_API_KEY'] = api_key
        expect(described_class.openrouter_api_key).to eq(api_key)
      end
    end

    context 'when config file exists' do
      before do
        File.write(config_file, {
          'openrouter' => {
            'api_key' => api_key
          }
        }.to_yaml)
      end

      it 'returns the config file value' do
        expect(described_class.openrouter_api_key).to eq(api_key)
      end
    end

    context 'when neither environment variable nor config file exists' do
      it 'returns nil' do
        expect(described_class.openrouter_api_key).to be_nil
      end
    end
  end
end