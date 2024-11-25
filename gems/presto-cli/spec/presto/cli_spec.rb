# frozen_string_literal: true
# FILE: gems/presto-cli/spec/presto/cli_spec.rb

RSpec.describe Presto::CLI do
  it "has a version number" do
    expect(Presto::CLI::VERSION).not_to be nil
  end
end
