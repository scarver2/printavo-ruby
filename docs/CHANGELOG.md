<!-- docs/CHANGELOG.md -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-03-29

### Added
- `Printavo::Status` — domain model with `id`, `name`, `color`, `key` (snake\_case symbol)
- `Printavo::Resources::Statuses` — `all`, `find`, and `registry` (O(1) Hash lookup by symbol key)
- `Printavo::Inquiry` — domain model mirroring `Order` with status predicate helpers
- `Printavo::Resources::Inquiries` — `all` and `find` for Printavo quote/inquiry records
- `Printavo::Order#status_id` and `#status_color` — expose full status sub-object fields
- `client.statuses` and `client.inquiries` — new entry points on `Printavo::Client`
- Orders GraphQL query now fetches `status { id name color }` for full status data
- Moved `CHANGELOG.md`, `CONTRIBUTING.md`, `FUTURE.md` to `docs/` for cleaner repo root

### Changed
- Gemspec `changelog_uri` updated to `docs/CHANGELOG.md`
- Gemspec `spec.files` updated to include `docs/**/*.md`

## [0.1.0] - 2026-03-29

### Added
- `Printavo::Client` — instance-based, multi-client capable entry point
- `Printavo::Resources::Customers` — `all` and `find` via GraphQL
- `Printavo::Resources::Orders` — `all` and `find` with status + customer association
- `Printavo::Resources::Jobs` — `all` (by order) and `find` line item queries
- `Printavo::Customer`, `Printavo::Order`, `Printavo::Job` — rich domain models
- `Printavo::Order#status?` — dynamic status predicate (handles user-defined statuses)
- `Printavo::GraphqlClient` — raw GraphQL query/mutation interface
- `Printavo::Webhooks.verify` — Rack-compatible HMAC-SHA256 signature verification
- Error hierarchy: `AuthenticationError`, `RateLimitError`, `NotFoundError`, `ApiError`
- Faraday connection with retry middleware (max 2 retries; 429/5xx)
- RSpec test suite — 62 examples, 100% line coverage with VCR + WebMock + Faker sanitization
- Coveralls coverage badge (LCOV via `simplecov-lcov`)
- Guard + RuboCop DX setup with `bin/spec` multi-Ruby local runner
- GitHub Actions CI: Ruby 3.3 (primary) + Ruby 4.0 (`continue-on-error`)
- Automated RubyGems publish on `v*` tag via `release.yml`
- `docs/CACHING.md` — nine caching strategy patterns for rate-limit-aware consumers

---

— Stan Carver II / Made in Texas 🤠 / https://stancarver.com
