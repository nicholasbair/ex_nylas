# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added
- Added `ExNylas.APIError` exception for API response errors (non-2xx HTTP responses)
  - Fields: `message`, `response` (full Response.t()), `status` (atom), `request_id`
  - Example message: `"API request failed with status not_found: Resource not found [request_id: abc123]"`
- Added `ExNylas.TransportError` exception for network-level failures
  - Fields: `message`, `reason` (atom like `:timeout`, `:econnrefused`)
  - Example message: `"Transport failed: request timed out"`
- Added `ExNylas.ValidationError` exception for pre-request validation errors
  - Fields: `message`, `field` (optional), `details` (optional)
  - Example message: `"Validation failed for api_key: missing value for api_key"`
- Added `ExNylas.DecodeError` exception for response decoding failures
  - Fields: `message`, `reason`, `response`
  - Raised when the SDK cannot parse or decode a response (e.g., invalid JSON, unexpected format)

### Changed
- **BREAKING** Error handling completely refactored for better semantics and type safety:

  **Non-bang functions now return exception structs in error tuples:**
  ```elixir
  # Before (v0.10.x)
  {:ok, result} | {:error, %ExNylas.Response{}}

  # After (v0.11.x)
  {:ok, result} | {:error, %ExNylas.APIError{} | %ExNylas.TransportError{} | ...}
  ```

  **Update your pattern matching:**
  ```elixir
  # Before
  case ExNylas.Grants.me(conn) do
    {:ok, grant} -> handle_success(grant)
    {:error, %ExNylas.Response{status: :not_found}} -> handle_not_found()
  end

  # After
  case ExNylas.Grants.me(conn) do
    {:ok, grant} -> handle_success(grant)
    {:error, %ExNylas.APIError{status: :not_found}} -> handle_not_found()
    {:error, %ExNylas.TransportError{reason: :timeout}} -> handle_timeout()
  end
  ```

  **Prefer idiomatic error handling with pattern matching:**
  ```elixir
  # Before (v0.10.x) - pattern matching on Response
  case ExNylas.Grants.me(conn) do
    {:ok, grant} -> handle_success(grant)
    {:error, %ExNylas.Response{status: :not_found}} -> handle_not_found()
  end

  # After (v0.11.x) - pattern matching on specific exception types
  case ExNylas.Grants.me(conn) do
    {:ok, grant} -> handle_success(grant)
    {:error, %ExNylas.APIError{status: :not_found}} -> handle_not_found()
    {:error, %ExNylas.TransportError{reason: :timeout}} -> retry_with_backoff()
    {:error, %ExNylas.ValidationError{field: field}} -> prompt_for_field(field)
  end
  ```

### Removed
- **BREAKING** Removed `ExNylasError` - replaced with specific exception types listed above
  - This was a generic catch-all that provided poor error handling semantics
  - Update error handling to pattern match on specific exception types in error tuples
- **BREAKING** File read errors when attaching files to drafts or messages are now handled gracefully:
  - Non-bang functions (`Drafts.create/3`, `Drafts.update/4`, `Messages.send/3`) now return `{:error, %ExNylas.FileError{}}` instead of crashing with a `MatchError`
  - Bang functions (`Drafts.create!/3`, `Drafts.update!/4`, `Messages.send!/3`) now raise `ExNylas.FileError` instead of crashing with a `MatchError`
  - `ExNylas.Multipart.build_multipart/2` now returns `{:ok, result}` or `{:error, %ExNylas.FileError{}}` instead of `result`
  - This allows callers to handle file errors (missing files, permission denied, etc.) gracefully with clear, descriptive error messages
- Updated dependencies:
  - Bumped `credo` from 1.7.7 to 1.7.15
  - Bumped `dialyxir` from 1.4.3 to 1.4.7
  - Bumped `ecto` from 3.13.3 to 3.13.5
  - Bumped `ex_doc` from 0.38.4 to 0.39.3
  - Bumped `excoveralls` from 0.18.1 to 0.18.5
  - Bumped `polymorphic_embed` from 5.0.0 to 5.0.6
  - Bumped `req` from 0.5.10 to 0.5.17
  - Bumped `typed_ecto_schema` from 0.4.1 to 0.4.3
- Updated CI to include Elixir 1.18 and 1.19

### Security
- Added security policy document (`SECURITY.md`) with supported version scope and coordinated disclosure timeline.

## [0.10.1] - 2025-10-17

### Added
- Added new fields to notetaker schema: `action_items`, `action_items_settings`, `summary`, and `summary_settings`

### Changed
- Organized generated docs (`ex_docs`) into groups for easier navigation

## [0.10.0] - 2025-08-18

### Added
- Support for sending messages using raw MIME (`send_raw/2` and `send_raw!/2` functions in `ExNylas.Messages`)

### Changed
- **BREAKING** Updated contact phone number type from enum of atoms to string as Google allows any string value
- **BREAKING** Updated contact email address type from enum of atoms to string as Google allows any string value (only build module needed to be updated)

### Fixed
- Added several missing fields in scheduler `booking.*` webhook schema
- Added missing scheduler booking webhook type for `booking.reminder`

### Internal
- Split large utility modules
- Standardized alias usage across interface modules

## [0.9.0] - 2025-06-27

### Added
- Manage API keys functionality
- Schema tests

### Fixed
- Scheduler schema validation

### Changed
- Updated documentation with links to Nylas docs

---

## Version History Notes

### Nylas API v2 vs v3
The `main` branch of the repo now leverages Nylas API v3. The `v2` branch of this repo will track Nylas API v2, though development work on this SDK will largely focus on Nylas API v3 and the v2 API is deprecated.

### Contributing
When contributing to this project, please update this changelog with your changes following the format above. Each change should be categorized appropriately under Added, Changed, Deprecated, Removed, Fixed, or Security.
