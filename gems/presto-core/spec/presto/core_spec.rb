# frozen_string_literal: true
# FILE: gems/presto-core/spec/presto/core_spec.rb

RSpec.describe Presto::Core do
  it "has a version number" do
    expect(Presto::Core::VERSION).not_to be nil
  end
end
