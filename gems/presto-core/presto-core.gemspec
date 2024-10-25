# frozen_string_literal: true

require_relative 'lib/presto/core/version'

Gem::Specification.new do |spec|
  spec.name = 'presto-core'
  spec.version = Presto::Core::VERSION
  spec.authors = ['Ben Davies']
  spec.email = ['ben@bendavies.id.au']

  spec.summary = 'Core library for Presto AI model invocation'
  spec.description = 'A Ruby library for invoking AI models across different providers'
  spec.homepage = 'https://github.com/yourusername/presto'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  spec.files = Dir.glob('{lib,spec}/**/*')
  spec.require_paths = ['lib']

  spec.add_dependency 'dotenv', '~> 2.8'
  spec.add_dependency 'dry-configurable', '~> 1.0'
  spec.add_dependency 'http', '~> 5.1'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'yard', '~> 0.9'
end
