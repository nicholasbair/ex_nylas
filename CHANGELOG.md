# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

> **Breaking:** the `req` requirement is raised from `~> 0.5.10` to `~> 0.7`
> (see Security below). Apps pinned to `req` 0.5.x/0.6.x must upgrade to `req`
> 0.7.x. This release also replaces the `req_telemetry` dependency with the
> maintained `req_tele` fork; the emitted telemetry events are unchanged
> (`[:req, :request, :pipeline | :adapter, ...]`).
>
> **Minimum Elixir version is now 1.15** (was 1.14) and **minimum Erlang/OTP is
> now 25** (was 24). This follows the `req`/`finch` HTTP stack: `finch` 0.22+
> requires Elixir ~> 1.15 and uses an OTP 25+ `:ets` option.

### Security
- Bumped runtime HTTP-stack dependencies to resolve reported advisories: `req` 0.5.17 → 0.7.2 (HIGH decompression CVE), `mint` 1.7.1 → 1.9.3 (CVE-2026-56810 HIGH), and `hpax` 1.0.3 → 1.0.4 (CVE-2026-58226 HIGH). Moving to `req` 0.7 required replacing `req_telemetry` (unmaintained, pinned `req ~> 0.5.0`) with the API-compatible `req_tele` fork, which allows current `req` — so no dependency `override` is needed.
- Bumped transitive test-only dependencies to resolve reported advisories in the Cowboy stack (pulled in via `bypass`): `cowboy` 2.12.0 → 2.18.0, `cowlib` 2.13.0 → 2.19.0, `plug_cowboy` 2.7.1 → 2.9.0 (CVE-2026-32688 HIGH), `plug` 1.19.1 → 1.20.3, `ranch` 1.8.0 → 1.8.1. These are only used by the test suite and are not shipped in the published package. Two `cowlib` advisories (CVE-2026-43966 MEDIUM, CVE-2026-43969 LOW) remain with no upstream fix and are ignored in the CI audit step.
- Added security policy document (`SECURITY.md`) with supported version scope and coordinated disclosure timeline.

### Changed
- Updated dependencies:
  - Bumped `credo` from 1.7.7 to 1.7.18
  - Bumped `dialyxir` from 1.4.3 to 1.4.7
  - Bumped `ecto` from 3.13.3 to 3.13.6
  - Bumped `ex_doc` from 0.38.4 to 0.40.2
  - Bumped `excoveralls` from 0.18.1 to 0.18.5
  - Bumped `finch` from 0.20.0 to 0.23.0
  - Bumped `polymorphic_embed` from 5.0.0 to 5.0.6
  - Bumped `typed_ecto_schema` from 0.4.1 to 0.4.3
- Updated CI to include Elixir 1.18, 1.19, and 1.20; dropped Elixir 1.14 / OTP 24.
- Added a `mix hex.audit` security-advisory check to CI that fails the build on known advisories in the dependency tree.

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
