# Changelog

All notable changes to kwtsms-zig are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [0.6.0] - 2026-11-17

This release needs Zig 0.17 or later. On an older Zig, stay on 0.5.0.

### Changed

- Requires Zig 0.17 (was 0.13). `build.zig.zon` now has an enum-literal name and a fingerprint, and `minimum_zig_version` is 0.17.0. CI and release builds use Zig 0.17.1.
- `KwtSMS.fromEnv(allocator, environ, env_file)` and `env.loadConfig(allocator, environ, env_file)` take the process environment as a new second argument (Zig 0.16+ has no global environment); pass `init.environ` from `main(init: std.process.Init.Minimal)`. Environment lookup is POSIX only.

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
