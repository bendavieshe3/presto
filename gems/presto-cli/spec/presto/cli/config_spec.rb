# frozen_string_literal: true
# FILE: gems/presto-cli/spec/presto/cli/config_spec.rb
require 'spec_helper'

RSpec.describe Presto::CLI::Config do
  let(:config_file) { described_class::CONFIG_FILE }
  let(:sample_config) do
    {
      'default_provider' => 'openrouter',
      'providers' => {
        'openrouter' => {
          'api_key' => 'test_openrouter_key'
        },
        'openai' => {
          'api_key' => 'test_openai_key'
        }
      }
    }
  end

  before do
    # Clear environment variables
    ENV.delete('OPENROUTER_API_KEY')
    ENV.delete('OPENAI_API_KEY')
    
    # Ensure config directory exists for tests
    FileUtils.mkdir_p(File.dirname(config_file))
  end

  after do
    # Clean up test config file
    FileUtils.rm_f(config_file)
  end

  describe '.openrouter_api_key' do
    context 'when environment variable is set' do
      it 'returns the environment variable value' do
        ENV['OPENROUTER_API_KEY'] = 'env_key'
        expect(described_class.openrouter_api_key).to eq('env_key')
      end
    end

    context 'when config file exists' do
      before do
        File.write(config_file, sample_config.to_yaml)
      end

      it 'returns the config file value' do
        expect(described_class.openrouter_api_key).to eq('test_openrouter_key')
      end
    end
  end

  describe '.provider_api_key' do
    context 'when environment variable is set' do
      it 'returns the environment variable value' do
        ENV['OPENAI_API_KEY'] = 'env_key'
        expect(described_class.provider_api_key('openai')).to eq('env_key')
      end
    end

    context 'when config file exists' do
      before do
        File.write(config_file, sample_config.to_yaml)
      end

      it 'returns the config file value for the specified provider' do
        expect(described_class.provider_api_key('openai')).to eq('test_openai_key')
      end

      it 'returns nil for unknown provider' do
        expect(described_class.provider_api_key('unknown')).to be_nil
      end
    end
  end

  describe '.default_provider' do
    context 'when config file exists with default_provider' do
      before do
        File.write(config_file, sample_config.to_yaml)
      end

      it 'returns the configured default provider' do
        expect(described_class.default_provider).to eq('openrouter')
      end
    end

    context 'when config file does not exist' do
      it 'returns openrouter as default' do
        expect(described_class.default_provider).to eq('openrouter')
      end
    end
  end

  describe '.available_providers' do
    context 'when config file exists with providers' do
      before do
        File.write(config_file, sample_config.to_yaml)
      end

      it 'returns array of configured providers' do
        expect(described_class.available_providers).to contain_exactly('openrouter', 'openai')
      end
    end

    context 'when config file does not exist' do
      it 'returns array with only openrouter' do
        expect(described_class.available_providers).to contain_exactly('openrouter')
      end
    end
  end
end