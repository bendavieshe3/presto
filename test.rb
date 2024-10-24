require "presto/core"
require "dotenv/load"

client = Presto::Core::Client.new(
  provider: :openrouter,
  api_key: ENV["OPENROUTER_API_KEY"]
)

response = client.generate_text("Hello, how are you?")
puts response.dig("choices", 0, "message", "content")