#!/usr/bin/env ruby
# examples/basic/text_generation.rb

require "bundler/setup"
require "dotenv/load"
require "presto/core"
require "json"

# Create a client with OpenRouter (default provider)
client = Presto::Core::Client.new(
  provider: :openrouter,
  api_key: ENV["OPENROUTER_API_KEY"]
)

# List available models
puts "\nAvailable models:"
models = client.available_models
models.each do |model|
  puts "- #{model['id']}"
end

# Generate text using default model
puts "\nGenerating text with OpenRouter default model..."
begin
  response = client.generate_text("Hello, how are you?")
  if response["choices"] && !response["choices"].empty?
    content = response.dig("choices", 0, "message", "content")
    puts "\nResponse: #{content}"
  else
    puts "\nError: No valid response received"
    puts JSON.pretty_generate(response)
  end
rescue Presto::Core::Error => e
  puts "\nError: #{e.message}"
end

# Example with OpenAI provider and specific model
if ENV["OPENAI_API_KEY"]
  puts "\nTrying OpenAI provider..."
  openai_client = Presto::Core::Client.new(
    provider: :openai,
    api_key: ENV["OPENAI_API_KEY"]
  )

  begin
    response = openai_client.generate_text(
      "What is Ruby?",
      model: "gpt-3.5-turbo" # Explicitly specify model
    )
    if response["choices"] && !response["choices"].empty?
      content = response.dig("choices", 0, "message", "content")
      puts "\nOpenAI Response: #{content}"
    end
  rescue Presto::Core::Error => e
    puts "\nOpenAI Error: #{e.message}"
  end
end