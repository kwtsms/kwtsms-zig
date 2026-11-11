# Changelog

All notable changes to kwtsms-zig are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

## [0.5.0] - 2026-11-06

### Added

- Client identifies itself with its name and version; `client.setAppName()` for your app.

### Changed

- Package author and license holder are now kwtSMS.

---

## [0.4.0] - 2026-03-13

### Changed
- Bug fixes.

---

## [0.3.0] - 2026-03-13

### Added
- `ValidateResult` reports locally rejected numbers.
- Cleanup methods for bulk results and `.env` configuration.

### Changed
- Bug fixes.

---

## [0.2.0] - 2026-03-07

### Added
- Country-specific phone number validation (60+ countries).
- Trunk prefix handling.

### Changed
- Zig 0.13 compatibility.

---

## [0.1.0] - 2026-03-06

### Added
- Initial release of the kwtSMS Zig client library.
- Full API coverage: send, bulk send, validate, balance, sender IDs, coverage, status, delivery reports.
- Phone and message cleaning utilities.
- Cached balance, JSONL logging and `.env` support.
- Error codes with recommended actions.
- Number deduplication.
- CLI tool and six runnable examples.
- CI and release workflows.
- Zero external dependencies.
