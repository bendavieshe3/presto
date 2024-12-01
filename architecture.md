# Presto Architecture

This document describes the key architectural components and design decisions in Presto. It complements the implementation-level documentation found in the source code.

## Core Components

Presto is built around several key components that work together to provide a unified interface for AI model invocation:

- **Client Interface**: The high-level API used by applications
- **Provider Framework**: Abstractions for different AI providers
- **Parameter System**: Type-safe parameter handling across providers
- **Configuration Management**: Multi-level configuration support

### Parameter System

The parameter system addresses several key challenges in AI model invocation:

1. **Type Safety**: Parameters must be validated before making expensive API calls
2. **Provider Flexibility**: Different providers support different parameters
3. **Standardization**: Common parameters need consistent validation across providers
4. **Extensibility**: New parameter types may be needed as models evolve

Key Design Decisions:

- Parameters are defined declaratively using the Definition class
- Validation happens at the provider level before API calls
- Default values and constraints are part of the definition
- Common parameters (temperature, max_tokens, etc.) are standardized

Provider Implementation Pattern:
```ruby
def available_parameters(model: nil)
  {
    temperature: Parameters::Definition.new(
      name: :temperature,
      type: :float,
      description: "Controls randomness",
      default: 0.7,
      constraints: { min: 0.0, max: 1.0 }
    )
  }
end
```

### Provider Framework

Providers are implemented through a base class that enforces consistent behavior:

- Standard method interfaces for model invocation
- Consistent error handling patterns
- Parameter validation
- Response normalization

Key Design Decisions:

- Providers are responsible for their own parameter definitions
- Response formats are normalized across providers
- Error handling is standardized but preserves provider details
- Model validation happens before parameter validation

### Configuration Management

Configuration follows a hierarchical pattern:

1. Default values in parameter definitions
2. Global configuration file
3. Environment variables
4. Runtime parameters

Key Design Decisions:

- Environment variables take precedence over config files
- Provider-specific settings are namespaced
- Configuration is validated at load time
- Sensitive values (API keys) have multiple storage options

## Development Guidelines

When extending Presto, consider these architectural principles:

1. **Consistency**: Use established patterns for new providers
2. **Validation**: Validate early to fail fast
3. **Documentation**: Focus on architectural decisions in docs, implementation details in code
4. **Testing**: Ensure both unit tests and integration tests

## Future Considerations

Areas for architectural evolution:

1. **Model Families**: Better support for related models within providers
2. **Parameter Inheritance**: Allow providers to inherit common parameters
3. **Response Streaming**: Standardized streaming response handling
4. **Caching Layer**: Optional caching for model information and responses