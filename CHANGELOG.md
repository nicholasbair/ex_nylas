# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added
- Renamed `ExNylas.Error` to `ExNylas.APIError` and enhanced to implement Exception behavior
  - Can be parsed from API responses (via Ecto schema) AND raised as an exception
  - Fields match Nylas API error response: `message`, `type`, `provider_error`
  - Embedded in `Response.error` field for non-2xx responses
  - Bang functions extract and raise `APIError` from failed responses
- Added `ExNylas.TransportError` exception for network-level failures
  - Fields: `message`, `reason` (atom like `:timeout`, `:econnrefused`)
  - Example message: `"Transport failed: request timed out"`
- Added `ExNylas.ValidationError` exception for pre-request validation errors
  - Fields: `message`, `field` (optional), `details` (optional)
  - Example message: `"Validation failed for api_key: missing value for api_key"`
- Added `ExNylas.DecodeError` exception for response decoding failures
  - Fields: `message`, `reason`, `response`
  - Raised when the SDK cannot parse or decode a response (e.g., invalid JSON, unexpected format)
- Enhanced `ExNylas.HostedAuthentication.Error` to implement Exception behavior
  - Now properly raisable by bang functions while preserving OAuth-specific fields
  - Fields: `message`, `error`, `error_code`, `error_uri`, `request_id`
  - Designed for compatibility with OAuth libraries per Nylas API design

### Changed
- **BREAKING** Error handling refactored for better semantics and type safety:

  **Return types remain consistent with v0.10.x for API errors:**
  ```elixir
  # v0.10.x and v0.11.x - Both return Response envelope
  {:ok, result} | {:error, %ExNylas.Response{}}
  ```

  **Key change: Response.error field now contains APIError details:**
  ```elixir
  # v0.10.x - Error embedded in Response
  {:error, %ExNylas.Response{error: %ExNylas.Error{message: "..."}}}

  # v0.11.x - Error renamed to APIError with same fields
  {:error, %ExNylas.Response{error: %ExNylas.APIError{message: "..."}}}
  ```

  **Non-API errors (network, validation, decoding) return specific exception types:**
  ```elixir
  {:error, %ExNylas.TransportError{reason: :timeout}}
  {:error, %ExNylas.ValidationError{field: :api_key}}
  {:error, %ExNylas.DecodeError{reason: :invalid_json}}
  ```

  **Bang functions now raise APIError (not Response) for API failures:**
  ```elixir
  # Before (v0.10.x)
  ExNylas.Grants.me!(conn)  # Raised ExNylasError

  # After (v0.11.x)
  ExNylas.Grants.me!(conn)  # Raises ExNylas.APIError with message, type, provider_error
  ```

  **Pattern matching on status remains the same:**
  ```elixir
  # Works in both v0.10.x and v0.11.x
  case ExNylas.Grants.me(conn) do
    {:ok, grant} -> handle_success(grant)
    {:error, %ExNylas.Response{status: :not_found}} -> handle_not_found()
    {:error, %ExNylas.TransportError{reason: :timeout}} -> retry_with_backoff()
  end
  ```

  **Access API error details from Response.error field:**
  ```elixir
  case ExNylas.Grants.me(conn) do
    {:error, %ExNylas.Response{error: %ExNylas.APIError{type: type}}} ->
      Logger.error("API error type: #{type}")

    {:error, %ExNylas.Response{error: nil, status: status}} ->
      Logger.error("Non-JSON API error with status: #{status}")
  end
  ```

### Removed
- **BREAKING** Removed `ExNylasError` - replaced with specific exception types
  - `APIError` for API failures (extracted from Response.error in bang functions)
  - `TransportError` for network failures
  - `ValidationError` for validation failures
  - `DecodeError` for response parsing failures
  - Update rescue clauses if you were catching `ExNylasError`
- **BREAKING** Renamed `ExNylas.Error` to `ExNylas.APIError`
  - If you were referencing the schema type, update to `ExNylas.APIError`
  - The struct is still embedded in `Response.error` the same way
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
