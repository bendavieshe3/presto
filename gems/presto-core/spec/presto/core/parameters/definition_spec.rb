# frozen_string_literal: true
# FILE: spec/presto/core/parameters/definition_spec.rb

require 'spec_helper'

module Presto
  module Core
    module Parameters
      RSpec.describe Definition do
        let(:simple_param) {
          described_class.new(
            name: :temperature,
            type: :float,
            description: "Controls randomness",
            default: 0.7,
            constraints: { min: 0.0, max: 1.0 }
          )
        }

        let(:enum_param) {
          described_class.new(
            name: :style,
            type: :enum,
            description: "Output style",
            default: 'balanced',
            constraints: { values: ['balanced', 'precise', 'creative'] }
          )
        }

        describe "#initialize" do
          it "requires a name" do
            expect {
              described_class.new(
                type: :float,
                description: "test"
              )
            }.to raise_error(ArgumentError)
          end

          it "requires a type" do
            expect {
              described_class.new(
                name: :test,
                description: "test"
              )
            }.to raise_error(ArgumentError)
          end

          it "requires a description" do
            expect {
              described_class.new(
                name: :test,
                type: :float
              )
            }.to raise_error(ArgumentError)
          end

          it "accepts valid parameters" do
            expect {
              described_class.new(
                name: :test,
                type: :float,
                description: "test",
                default: 0.5,
                constraints: { min: 0.0, max: 1.0 }
              )
            }.not_to raise_error
          end
        end

        describe "#validate" do
          context "with float parameter" do
            it "accepts valid values" do
              expect { simple_param.validate(0.5) }.not_to raise_error
            end

            it "accepts integer values within float constraints" do
              expect { simple_param.validate(1) }.not_to raise_error
            end

            it "rejects values below minimum" do
              expect { 
                simple_param.validate(-0.1) 
              }.to raise_error(InvalidParameterError, /must be greater than or equal to 0.0/)
            end

            it "rejects values above maximum" do
              expect { 
                simple_param.validate(1.1) 
              }.to raise_error(InvalidParameterError, /must be less than or equal to 1.0/)
            end

            it "rejects non-numeric values" do
              expect { 
                simple_param.validate("0.5") 
              }.to raise_error(InvalidParameterError, /must be a number/)
            end
          end

          context "with enum parameter" do
            it "accepts valid values" do
              expect { enum_param.validate('balanced') }.not_to raise_error
            end

            it "rejects invalid values" do
              expect { 
                enum_param.validate('invalid') 
              }.to raise_error(InvalidParameterError, /must be one of/)
            end
          end
        end

        describe "#to_h" do
          it "returns a hash representation" do
            hash = simple_param.to_h
            expect(hash).to include(
              name: :temperature,
              type: :float,
              description: "Controls randomness",
              default: 0.7,
              constraints: { min: 0.0, max: 1.0 }
            )
          end
        end
      end
    end
  end
end

