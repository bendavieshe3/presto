# Presto

Presto is a command line tool and Ruby library for invoking artificial intelligence models. It provides a unified interface for working with various AI providers and models.

## Features

- Simple interface for text generation using AI models
- Support for OpenRouter's AI model providers
- Command line interface with support for model selection and output formatting
- Configurable through environment variables
- Extensible architecture for adding new providers and capabilities

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/presto.git
cd presto
```

2. Install dependencies:
```bash
bundle install
```

3. Create a `.env` file in the project root with your API keys:
```
OPENROUTER_API_KEY=your-api-key-here
```

## Usage

### Command Line Interface

The CLI provides several commands for interacting with AI models:

```bash
# Generate text using an AI model
presto generate "What is the meaning of life?"

# Generate with specific model and format options
presto generate -m gpt-4 -f json "Write a haiku about programming"

# List available providers
presto providers

# List available models
presto models

# Show version information
presto version
```

CLI Options:
- `-m, --model`: Specify the model to use (default: gpt-3.5-turbo)
- `-p, --provider`: Specify the provider to use (default: openrouter)
- `-f, --format`: Output format (text, json) (default: text)
- `-v, --verbose`: Show verbose output

### As a Ruby Library

```ruby
require "bundler/setup"
require "dotenv/load"
require "presto/core"

# Initialize client with OpenRouter
client = Presto::Core::Client.new(
  provider: :openrouter,
  api_key: ENV["OPENROUTER_API_KEY"]
)

# Generate text
response = client.generate_text(
  "Hello, how are you?",
  model: "gpt-3.5-turbo"  # optional, defaults to gpt-3.5-turbo
)

# Extract the response content
content = response.dig("choices", 0, "message", "content")
puts content
```

## Project Structure

```
presto/
├── gems/
│   ├── presto-core/           # Core invocation library
│   │   ├── lib/
│   │   ├── spec/
│   │   └── presto-core.gemspec
│   └── presto-cli/            # Command line interface
│       ├── exe/
│       ├── lib/
│       ├── spec/
│       └── presto-cli.gemspec
├── docs/                      # Documentation
│   ├── api/
│   └── guides/
└── examples/                  # Usage examples
    └── basic/
        └── text_generation.rb
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

To run the test suite:
```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).