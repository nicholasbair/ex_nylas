# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Support for sending messages using raw mime (`send_raw/2` and `send_raw!/2` functions in `ExNylas.Messages`)

### Fixed
- Added several missing fields in scheduler `booking.*` webhook schema
- Added missing scheduler booking webhook type for `booking.reminder`
- Updated contact phone number type from enum of atom to string as Google allows any string value
- Updated contact email address type from enum of atom to string as Google allows any string value (only build module needed to be updated)

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