# frozen_string_literal: true
# FILE: gems/presto-cli/presto-cli.gemspec

require_relative "lib/presto/cli/version"

Gem::Specification.new do |spec|
  spec.name = "presto-cli"
  spec.version = Presto::CLI::VERSION
  spec.authors = ["Ben Davies"]
  spec.email = ["ben@bendavies.id.au"]

  spec.summary = "Presto CLI"
  spec.description = "Command line tool for invoking AI models"
  spec.homepage = "https://github.com/bendavieshe3/presto"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.glob("{bin,exe,lib}/**/*") + %w[README.md]
  spec.bindir = "exe"
  spec.executables = ["presto"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_runtime_dependency "thor", "~> 1.3"
  spec.add_runtime_dependency "dotenv", "~> 2.8"
  spec.add_runtime_dependency "presto-core", "~> 0.1.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "stringio", "~> 3.1.0"
end