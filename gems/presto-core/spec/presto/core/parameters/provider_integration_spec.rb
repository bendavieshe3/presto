# frozen_string_literal: true
# FILE: spec/presto/core/parameters/provider_integration_spec.rb

require 'spec_helper'

module Presto
  module Core
    RSpec.describe "Provider Parameter Integration" do
      let(:test_provider_class) do
        Class.new(Providers::Base) do
          def available_models
            [{"id" => "test-model"}]
          end

          def default_model
            "test-model"
          end

          protected

          def perform_generation(prompt, model, parameters)
            {"choices" => [{"message" => {"content" => "test response"}}]}
          end
        end
      end

      let(:implemented_provider_class) do
        Class.new(test_provider_class) do
          def available_parameters(model: nil)
            {
              temperature: Parameters::Definition.new(
                name: :temperature,
                type: :float,
                description: "Controls randomness",
                default: 0.7,
                constraints: { min: 0.0, max: 1.0 }
              ),
              style: Parameters::Definition.new(
                name: :style,
                type: :enum,
                description: "Output style",
                default: 'balanced',
                constraints: { values: ['balanced', 'precise', 'creative'] }
              )
            }
          end
        end
      end

      describe "#available_parameters" do
        it "requires providers to implement parameter definitions" do
          provider = test_provider_class.new(api_key: "test")
          expect { 
            provider.available_parameters 
          }.to raise_error(NotImplementedError)
        end

        context "when implemented" do
          let(:provider) { implemented_provider_class.new(api_key: "test") }

          it "returns a hash of parameter definitions" do
            params = provider.available_parameters
            expect(params).to be_a(Hash)
            expect(params[:temperature]).to be_a(Parameters::Definition)
          end

          it "includes parameter metadata" do
            param = provider.available_parameters[:temperature]
            expect(param.to_h).to include(
              name: :temperature,
              type: :float,
              description: "Controls randomness"
            )
          end
        end
      end

      describe "#generate_text" do
        let(:provider) { implemented_provider_class.new(api_key: "test") }

        context "with valid parameters" do
          it "accepts valid parameter values" do
            expect {
              provider.generate_text("test", 
                model: "test-model",
                temperature: 0.5,
                style: 'balanced'
              )
            }.not_to raise_error
          end
        end

        context "with invalid parameters" do
          it "rejects unknown parameters" do
            expect {
              provider.generate_text("test",
                model: "test-model",
                unknown_param: "value"
              )
            }.to raise_error(InvalidParameterError, /Unknown parameter/)
          end

          it "rejects invalid parameter values" do
            expect {
              provider.generate_text("test",
                model: "test-model",
                temperature: 1.5
              )
            }.to raise_error(InvalidParameterError, /must be less than or equal to 1.0/)
          end
        end

        context "with default values" do
          it "uses default when parameter is not provided" do
            response = provider.generate_text("test", model: "test-model")
            expect(response["choices"]).to be_an(Array)
          end
        end
      end
    end
  end
end