# Presto

Presto is a command line tool and Ruby library for invoking artificial intelligence models. It provides a unified interface for working with various AI providers and models.

## Features

- Simple interface for text generation using AI models
- Support for OpenRouter's AI model providers
- Command line interface with support for model selection and output formatting
- Configurable through environment variables or config file
- Extensible architecture for adding new providers and capabilities

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

3. Configure your API key using one of two methods:

   Option 1: Environment variable:
   ```bash
   export OPENROUTER_API_KEY=your-api-key
   ```

   Option 2: Configuration file:
   ```bash
   mkdir -p ~/.config/presto
   ```
   Create `~/.config/presto/config.yml` with:
   ```yaml
   openrouter:
     api_key: your-api-key
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

# List available models (add -v for detailed information)
presto models
presto models -v

# Show version information
presto version
```

CLI Options:
- `-m, --model`: Specify the model to use (default: meta-llama/llama-3-8b-instruct)
- `-p, --provider`: Specify the provider to use (default: openrouter)
- `-f, --format`: Output format (text, json) (default: text)
- `-v, --verbose`: Show verbose output

### As a Ruby Library

```ruby
require "presto/core"

# Initialize client with OpenRouter
client = Presto::Core::Client.new(
  provider: :openrouter,
  api_key: "your-api-key"
)

# Generate text
response = client.generate_text(
  "Hello, how are you?",
  model: "meta-llama/llama-3-8b-instruct"  # optional
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

The project includes several rake tasks to help with development:

```bash
# Setup development environment
rake setup              # Install dependencies for all gems
rake gems:dev:update    # Update all gem dependencies

# Building and Installing
rake gems:build         # Build all gems in correct order
rake gems:clean         # Clean all built gem packages
rake install           # Build and install all gems (shortcut for gems:install)

# Testing
rake spec              # Run all specs (shortcut for gems:spec)
rake gems:spec_doc     # Run all specs with documentation format
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