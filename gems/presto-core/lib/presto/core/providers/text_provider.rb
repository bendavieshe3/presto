# frozen_string_literal: true
# FILE: gems/presto-core/lib/presto/core/providers/text_provider.rb
module Presto
    module Core
      module Providers
        class TextProvider < Base
            def available_parameters(model: nil)
                {
                  text_prompt: Parameters::Definition.new(
                    name: :text_prompt,
                    type: :string,
                    description: "The text input to send to the model",
                    constraints: {
                      min_length: 1,
                      max_length: 32768
                    }
                  ),
                  temperature: Parameters::Definition.new(
                    name: :temperature,
                    type: :float,
                    description: "Controls randomness in the output",
                    default: 0.7,
                    constraints: { min: 0.0, max: 2.0 }
                  ),
                  top_p: Parameters::Definition.new(
                    name: :top_p,
                    type: :float,
                    description: "Controls diversity via nucleus sampling",
                    default: 1.0,
                    constraints: { min: 0.0, max: 1.0 }
                  ),
                  max_tokens: Parameters::Definition.new(
                    name: :max_tokens,
                    type: :integer,
                    description: "Maximum number of tokens to generate",
                    default: 1000,
                    constraints: { min: 1, max: 4096 }
                  )
                }
            end
    
            def generate_text(prompt, model:, **parameters)
                # Validate model first
                validate_model(model)
                
                # Then handle parameters
                parameters = parameters.merge(text_prompt: prompt)
                validate_parameters(parameters, model: model)
                perform_generation(parameters[:text_prompt], model, parameters)
            end
        end
      end
    end
  end