# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed
- Updated dependencies:
  - Bumped `polymorphic_embed` from 5.0.0 to 5.0.3
  - Bumped `dialyxir` from 1.4.3 to 1.4.6
  - Bumped `req` from 0.5.10 to 0.5.15
  - Bumped `ex_doc` from 0.34.2 to 0.38.4
  - Bumped `typed_ecto_schema` from 0.4.1 to 0.4.3
  - Bumped `credo` from 1.7.7 to 1.7.13
  - Bumped `excoveralls` from 0.18.1 to 0.18.5

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