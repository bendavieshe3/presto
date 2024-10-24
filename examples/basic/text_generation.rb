#!/usr/bin/env ruby

require "bundler/setup"
require "dotenv/load"
require "presto/core"
require "json"

client = Presto::Core::Client.new(
  provider: :openrouter,
  api_key: ENV["OPENROUTER_API_KEY"]
)

puts "Sending request to OpenRouter..."
response = client.generate_text("Hello, how are you?")

if response["choices"] && !response["choices"].empty?
  content = response.dig("choices", 0, "message", "content")
  puts "\nResponse: #{content}"
else
  puts "\nError: No valid response received"
  puts JSON.pretty_generate(response)
end