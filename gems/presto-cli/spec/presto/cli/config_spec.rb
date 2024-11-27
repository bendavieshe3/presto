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
    ENV.delete('OPENROUTER_API_KEY')
    ENV.delete('OPENAI_API_KEY')
    FileUtils.mkdir_p(File.dirname(config_file))
  end

  after do
    FileUtils.rm_f(config_file)
  end

  describe 'configuration caching' do
    context 'when config file exists' do
      before do
        File.write(config_file, sample_config.to_yaml)
        described_class.reload_config!
      end

      it 'loads the config file only once' do
        # First call to force cache load
        described_class.default_provider

        # Now set up expectations for subsequent calls
        expect(File).not_to receive(:exist?)
        expect(YAML).not_to receive(:load_file)
        
        described_class.provider_config('openrouter')
        described_class.provider_api_key('openai')
      end

      it 'reloads configuration when explicitly requested' do
        # First access to cache the config
        first_provider = described_class.default_provider
        expect(first_provider).to eq('openrouter')
        
        # Modify the config file
        new_config = sample_config.merge('default_provider' => 'openai')
        File.write(config_file, new_config.to_yaml)
        
        # Should still return cached value
        expect(described_class.default_provider).to eq('openrouter')
        
        # After reload, should return new value
        described_class.reload_config!
        expect(described_class.default_provider).to eq('openai')
      end
    end

    context 'when config file does not exist' do
      before do
        FileUtils.rm_f(config_file)
      end

      it 'caches empty config hash after single check' do
        described_class.reload_config!  # Clear any existing cache
        
        # Set expectation for the single file check that should occur
        expect(File).to receive(:exist?)
          .with(config_file)
          .once
          .and_return(false)
        
        # Multiple calls should reuse the cached empty hash
        described_class.default_provider
        described_class.provider_config('openrouter')
        described_class.provider_api_key('openai')
      end
    end
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
        described_class.reload_config!  
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
        described_class.reload_config!  
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
    it 'delegates to Core::Client.available_providers' do
      providers = described_class.available_providers
      expect(providers).to eq(Presto::Core::Client.available_providers)
    end

    it 'returns array with expected providers' do
      expect(described_class.available_providers).to include('openrouter', 'openai')
    end
  end
end