# Contributing to ExNylas

Thank you for your interest in contributing to ExNylas! This guide will help you get started with contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Code Style](#code-style)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Architecture](#architecture)

## Getting Started

Before contributing, please:

1. Check existing [issues](https://github.com/nicholasbair/ex_nylas/issues) to see if your contribution is already being discussed
2. For new features or major changes, open an issue first to discuss your approach
3. Review our [architecture documentation](ARCHITECTURE.md) to understand how the SDK is structured

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/nicholasbair/ex_nylas.git
   cd ex_nylas
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Run tests to ensure everything is working:
   ```bash
   mix test
   ```

## How to Contribute

### Reporting Bugs

When reporting bugs, please include:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your Elixir and ExNylas versions
- Any relevant code samples or error messages

### Suggesting Features

Feature suggestions are welcome! Please:
- Check if the feature has already been suggested
- Clearly describe the use case and benefits
- Consider if it aligns with the SDK's goals

### Adding New Resources

If you're adding a new Nylas API resource, see the [Adding a New Resource](ARCHITECTURE.md#adding-a-new-resource) section in the architecture documentation for detailed guidance on the required structure and patterns.

## Code Style

Please follow these guidelines:

- Use `TypedEctoSchema` for all schemas
- Always add `@primary_key false` to embedded schemas
- Use `@moduledoc` for modules and `@doc` for public functions
- Run `mix format` before committing to ensure consistent formatting
- Run `mix credo` for static analysis and style suggestions
- Follow existing patterns in the codebase for consistency

### Documentation

- All public functions should have `@doc` annotations
- Include `@spec` type specifications for public functions
- Use clear, concise language
- Include code examples for complex functions

## Testing

All contributions should include appropriate tests. Run the test suite with:

```bash
mix test
```

### Testing Guidelines

When adding new features or resources:
1. Test that changesets validate correctly
2. Test that build schemas reject invalid input (if applicable)
3. Test custom methods with mocked HTTP responses
4. Ensure all existing tests still pass

### Running Specific Tests

```bash
# Run a specific test file
mix test test/ex_nylas/messages_test.exs

# Run a specific test
mix test test/ex_nylas/messages_test.exs:42
```

## Submitting Changes

### Pull Request Process

1. Fork the repository and create a new branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the code style guidelines

3. Add or update tests as needed

4. Run the full test suite and ensure all tests pass:
   ```bash
   mix test
   ```

5. Run code formatting and linting:
   ```bash
   mix format
   mix credo
   ```

6. Commit your changes with clear, descriptive commit messages

7. Push to your fork and submit a pull request to the `main` branch

### Pull Request Guidelines

- Provide a clear description of the changes
- Reference any related issues
- Include examples of how to use new features
- Ensure CI checks pass
- Be responsive to feedback and questions

## Architecture

For detailed information about the SDK's architecture, including:
- Project structure
- Metaprogramming and code generation
- Resource module patterns
- Core infrastructure components

Please see [ARCHITECTURE.md](ARCHITECTURE.md).

## Questions or Need Help?

If you have questions or need help with your contribution:
- Open an issue for discussion
- Check existing documentation and issues
- Review the [architecture guide](ARCHITECTURE.md) for technical details

We appreciate your contributions to ExNylas!
