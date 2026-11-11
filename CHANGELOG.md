# Changelog

All notable changes to kwtsms-zig are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

## [0.5.0] - 2026-11-06

### Added

- The client sends a User-Agent `kwtsms-zig/<version>` (name and version only, no personal data) so kwtSMS can see which integrations are in use. `client.setAppName()` puts your app's token in front, e.g. `my-shop/2.1.0 kwtsms-zig/0.5.0`. New `kwtsms.version` (from build.zig.zon), `client.userAgent()`, `kwtsms.buildUserAgent()` and `request.apiRequestWithUserAgent()`.

### Changed

- ERR006 and ERR025 action text, docs and examples use the placeholder `965XXXXXXXX` instead of a sample mobile number; tests read the phone number from `KWTSMS_TEST_NUMBER` and skip the tests that need it when it is unset.
- The two live 250-number bulk tests (generated number ranges) are removed; live tests send only to `KWTSMS_TEST_NUMBER`. The 200 + 50 batching has no offline test yet: the send path has no transport seam.
- Package author and license holder are now kwtSMS.

### Docs

- ERR028 action text: "Sent to the same number too soon." ERR028 is opt-in per account (Duplicate SMS protection) with a per-account window (10 seconds by default), not a fixed 15 seconds.
- Test mode: test messages are queued but not delivered, and their credits are held until you delete them from the Sending Queue. Earlier text said no credits were consumed.

---

## [0.4.0] - 2026-03-13

### Changed
- Version bump. All security fixes and `ValidateResult` changes from this development cycle are now stable.

---

## [0.3.0] - 2026-03-13

### Added
- `ValidateResult` struct: `validate()` now returns locally-rejected numbers in a `rejected: []InvalidEntry` slice instead of silently discarding them. Call `result.deinit(allocator)` to free.
- `BulkSendResult.deinit(allocator)`: frees all heap-allocated batch data (`msg_ids`, `batch_errors`, `invalid`).
- `KwtSMS.deinit()`: frees strings loaded from a `.env` file when using `fromEnv()`.
- `EnvConfig.deinit(allocator)`: frees owned `.env` string copies via `_owned_*` flags.

### Security
- Security fix.

### Fixed
- `errors.zig` doc comment corrected: 28 documented error codes (not 33); ERR014-ERR018 are intentional gaps.

---

## [0.2.0] - 2026-03-07

### Added
- Country-specific phone number validation via `PhoneRule` lookup table (60+ countries, GCC through Oceania).
- `findCountryCode()`: longest-match country prefix extraction (3-digit, 2-digit, 1-digit).
- `validatePhoneFormat()`: per-country length and mobile-prefix validation.
- Saudi Arabia trunk prefix stripping (`0` prefix removal after country code detection).
- Full test suite for phone validation edge cases.

### Changed
- `std.ComptimeStringMap` replaced by `std.StaticStringMap(PhoneRule).initComptime(...)` for Zig 0.13 compatibility.

---

## [0.1.0] - 2026-03-06

### Added
- Initial release of the kwtSMS Zig client library.
- `KwtSMS.init()` and `KwtSMS.fromEnv()` client constructors.
- `send()`, `sendOne()`, `sendBulk()`, `validate()`, `balance()`, `purchased()`, `senderids()`, `coverage()`, `status()`, `dlr()` API methods.
- `cachedBalance()` and `cachedPurchased()` thread-safe cached accessors.
- `normalizePhone()` and `validatePhoneInput()` phone utilities.
- `cleanMessage()` message sanitizer (strips non-GSM characters, trims whitespace).
- JSONL request/response logger with password masking.
- 28 documented kwtSMS API error codes with human-readable descriptions and recommended actions.
- Error enrichment: automatic action field on all error responses.
- `.env` file support with environment variable priority.
- Thread-safe cached balance tracking.
- Number deduplication before API calls.
- Comprehensive unit tests (100+ test cases).
- Integration tests with `test_mode` support.
- CLI tool (`src/main.zig`) with all API commands.
- Six runnable examples (`examples/00` through `examples/05`).
- GitHub Actions: CI tests, format check, weekly cron, cross-platform release binaries.
- Zero external dependencies (Zig stdlib only).
