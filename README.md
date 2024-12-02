# Presto

Presto is a command line tool and Ruby library for invoking artificial intelligence models. It provides a unified interface for working with various AI providers and models.

This is the README for the monorepo. For a high-level overview of Presto's goals and philosophy, see [About](docs/about.md). For detailed information about internal architecture and design decisions, see [Architecture](docs/architecture.md).

## Features

- Simple interface for text generation using AI models
- Support for multiple AI providers (OpenRouter, OpenAI)
- Command line interface with model selection and output formatting
- Configurable through environment variables or config file
- Standardized response format across providers
- Detailed model information and availability checking
- Extensible architecture for adding new providers

## Installation

1. Clone the repository:
```bash
git clone https://github.com/bendavieshe3/presto.git
cd presto
```

2. Set up the development environment:
```bash
rake setup
```

## Configuration

Configure your API keys using one of two methods:

### Option 1: Environment Variables

```bash
# For OpenRouter
export OPENROUTER_API_KEY=your-openrouter-api-key

# For OpenAI
export OPENAI_API_KEY=your-openai-api-key

# For Anthropic
export ANTHROPIC_API_KEY=your-anthropic-api-key
```

### Option 2: Configuration File

Create the config directory:
```bash
mkdir -p ~/.config/presto
```

Create `~/.config/presto/config.yml` with:
```yaml
# Optional: Set default provider (defaults to openrouter if not specified)
default_provider: openrouter

providers:
  openrouter:
    api_key: your-openrouter-api-key
  openai:
    api_key: your-openai-api-key
  anthropic:
    api_key: your-anthropic-api-key
```

## Usage

### Command Line Interface

The CLI provides several commands for interacting with AI models:

```bash
# Generate text using default provider and model
presto generate "What is the meaning of life?"

# Generate with specific provider and model
presto generate -p openai -m gpt-3.5-turbo "Write a haiku about programming"
presto generate -p anthropic -m claude-3-5-sonnet-20241022 "Tell me a joke"

# Generate with JSON output format
presto generate -f json "Tell me a joke"

# List available models (add -v for detailed information)
presto models
presto models -p openai
presto models -v

# List available providers
presto providers

# Show version information
presto version
```

CLI Options:
- `-p, --provider`: Specify the provider to use (openrouter, openai)
- `-m, --model`: Specify the model to use (defaults to provider's default)
- `-f, --format`: Output format (text, json)
- `-v, --verbose`: Show verbose output

### As a Ruby Library

```ruby
require "presto/core"

# Initialize client with OpenRouter (default provider)
client = Presto::Core::Client.new(
  provider: :openrouter,
  api_key: ENV["OPENROUTER_API_KEY"]
)

# Use Anthropic provider with specific model
anthropic_client = Presto::Core::Client.new(
  provider: :anthropic,
  api_key: ENV["ANTHROPIC_API_KEY"]
)

response = anthropic_client.generate_text(
  "What is Ruby?",
  model: "claude-3-5-sonnet-20241022"
)
content = response.dig("choices", 0, "message", "content")
puts content

# List available models
models = client.available_models
models.each do |model|
  puts "- #{model['id']}"
end
```

# Project Structure

The project is organized into several key components:

```
presto/
├── core/                  # Core library functionality
│   ├── client/           # Client interface
│   ├── providers/        # Provider implementations
│   ├── parameters/       # Parameter handling system
│   └── config/          # Configuration management
├── cli/                  # Command-line interface
└── docs/                # Documentation
    ├── about.md         # Project overview and goals
    └── architecture.md  # Technical design and decisions
```

For a high-level overview of Presto's goals and philosophy, see [About](docs/about.md).
For detailed information about internal architecture and design decisions, see [Architecture](docs/architecture.md).

## Development

The project includes several rake tasks to help with development:

```bash
# Setup development environment
rake setup              # Install dependencies for all gems

# Building and Installing
rake gems:build         # Build all gems in correct order
rake install           # Build and install all gems

# Testing
rake spec              # Run all specs
rake gems:spec_doc     # Run specs with documentation format
```

### Running the CLI in Development

You can run the Presto CLI in development using:
```bash
# From project root
bundle exec gems/presto-cli/exe/presto

# Or after installation
presto
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