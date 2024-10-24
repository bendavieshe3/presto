# What is Presto?
Presto is a command line tool for invoking artificial intelligence models.

# Objectives
1. Develop an affective service library for the generic invocation of AI models, specifically implemented in Ruby
    - tested and usable via CLI
    - comprising one or more gem definitions (which may be reused in client applications)
2. Explore the capabilities of AI models

# Approach
Presto is intended to be progressively implemented as the problem domain is better understood.
* The initial implementations will have limited flexibility and configurability, but will provide a foundation for future development
* The initial implementation will be expanded and grown horizontally (across more models) and vertically (more configurability) over time

# Strategic Requirements
1. Cross-provider invocation: The library must be able to invoke models from OpenRouter, Fal.ai, Replicate and other first and second party providers
2. Support for different modalities: The library must be able to invoke models that support multimodal inputs and outputs, such as images, audio, and video
3. Ongoing relevance: The library must be able to invoke models that are currently released and those that are under development. The CLI tool should be useful for research, experimentation and adhoc tasks

# Core Features
1. **Command Pattern CLI**
   - Primary commands: generate/g for model invocation
   - Model/provider discovery and information
   - Configuration management and project scaffolding
   - Template management

2. **Configuration Layers**
   - Client configuration
   - Provider meta-configuration (API keys, rate limits)
   - Model configuration (parameters, defaults)
   - Project-specific settings
   - Command-line overrides

3. **Advanced Features**
   - Request templating with parameter interpolation
   - Request extrapolation for parameter ranges
   - Request enrichment via external data sources
   - Workflow chaining and context persistence
   - Structured input/output formatting

# Project Structure
The project follows standard Ruby gem conventions:

```
presto/
├── gems/
│   ├── presto-core/           # Core invocation library
│   │   ├── lib/
│   │   ├── spec/
│   │   ├── Gemfile
│   │   ├── README.md
│   │   └── presto-core.gemspec
│   ├── presto-framework/      # Advanced features framework
│   ├── presto-config/         # Configuration management
│   ├── presto-daemon/         # Service daemon
│   └── presto-cli/            # Command line interface
│       ├── exe/
│       │   └── presto        # CLI executable
│       └── [standard gem structure]
├── docs/
│   ├── api/
│   └── guides/
└── examples/
```

## Component Responsibilities

1. **presto-core**: Stateless library for model invocation with standardized I/O parameters
2. **presto-framework**: Advanced features including templating, workflows, and context management
3. **presto-config**: Configuration management for system, user, project, and templates
4. **presto-daemon**: HTTP endpoints and async operations via messaging/streaming
5. **presto-cli**: Command-line interface mapping library capabilities to outcomes

# Domain Characteristics

1. **Modality**: AI models support a variety of modalities, including text, image, audio, and video
2. **Provider**: AI models are provided by a variety of entities, including OpenRouter, Replicate, and other first and second party providers
3. **Interface**: AI models are invoked through a variety of interfaces, including REST, GraphQL, and gRPC
4. **Invocation**: AI models are invoked with a variety of inputs, including text, image, audio, and video
5. **Output**: AI models produce a variety of outputs, including text, image, audio, and video
6. **Context**: The use of context is important to the invocation of AI models, either independently or as part of a chain of invocation. Usage development requires the ability to iterate on inputs, develop workflows and reliable processes

[Previous sections remain the same through Domain Characteristics]

# Cross-cutting Concerns
1. **Error Handling**
   - Provider-agnostic error abstractions
   - Configurable retry strategies
   - Error recovery workflows

2. **Response Management**
   - Normalized response formats across providers
   - Consistent metadata handling
   - Support for multiple output types (text, binary, composite)
   - Progress indication for long-running operations

3. **Resource Management**
   - Rate limiting
   - Concurrent request handling
   - Resource cleanup and streaming termination

[Implementation Strategy and Development Priorities sections follow as before]

# Implementation Strategy
1. **Initial Implementation**: Simple library for AI model invocation using Ruby and OpenRouter
2. **Horizontal Expansion**: Support for more models and providers
3. **Vertical Expansion**: Support for more modalities and inputs/outputs
4. **Context Management**: Support for context persistence and management
5. **Workflow Development**: Support for workflow creation and execution
6. **Reliability**: Enhanced workflow reliability and error handling

# Development Priorities
1. Run initial AI model with single modality
2. Extract configuration patterns
3. Implement testing framework
4. Add new provider support
5. Expand modality support
6. Continuous architecture refinement based on learnings

# Core Concepts

## Organization
- **Project**: Collection of configuration, templates, and workflows for a specific use case
- **Provider**: Service offering AI model access (e.g., OpenRouter)
- **Model Family**: Group of related models from a provider (e.g., GPT-4)
- **Model**: Specific implementation with defined capabilities (e.g., GPT-4-Vision)

## Execution
- **Invocation**: Single execution of a model with parameters
- **Workflow**: Series of connected invocations with defined data flow
- **Modality**: Type of input/output (text, image, audio, video)

## Configuration
- **Template**: Reusable invocation pattern with placeholders
- **Base Parameters**: Default configuration values
- **Actual Parameters**: Final values used in invocation
- **Parameter Set**: Collection of related parameters
- **Smart Token**: Dynamic parameter resolved at runtime

# Execution Dimensions

Specific dimensions of implementation to ensure consistency of delivery.

## Providers
(Add specific providers as implemented)

## Models
(Add Specific coverage of models as implemented)

## Modality
(Add specific coverage of modalities as implemented)

## CLI Commands
(Add specific CLI commands as implemented that need to be supported going forward)

