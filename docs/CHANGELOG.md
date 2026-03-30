<!-- docs/CHANGELOG.md -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-03-30

### Added
- `Customers#create(primary_contact:, **input)` — `customerCreate` mutation; normalizes `primaryContact` + `companyName` response fields to match the read-side `Customer` model
- `Customers#update(id, **input)` — `customerUpdate` mutation
- `Orders#create(**input)` — `quoteCreate` mutation; normalizes `total` → `totalPrice` in response
- `Orders#update(id, **input)` — `quoteUpdate` mutation
- `Orders#update_status(id, status_id:)` — `statusUpdate` mutation; handles `OrderUnion (Quote | Invoice)` via inline fragments
- `Inquiries#create(**input)` — `inquiryCreate` mutation
- `Inquiries#update(id, **input)` — `inquiryUpdate` mutation
- All mutation methods accept snake_case keyword args and camelize them for GraphQL input
- `CREATE_MUTATION` and `UPDATE_MUTATION` constants on `Customers`, `Orders`, `Inquiries`; `UPDATE_STATUS_MUTATION` on `Orders`
- Private `build_customer` and `build_order` normalizers centralize mutation response mapping
- Private `camelize_keys` on `Customers` and `Orders` converts `snake_case` → `camelCase` for input variables
- Factory helpers `fake_customer_mutation_response` and `fake_order_mutation_response` for testing

## [0.4.0] - 2026-03-30

### Added
- `GraphqlClient#mutate` — semantic method for GraphQL mutations; identical transport to `query` but signals write intent at the call site; lays the foundation for 0.5.0 resource-level mutations
- `GraphqlClient#paginate` — cursor-following pagination for raw GraphQL queries; accepts a dot-separated `path:` to resolve nested connections (e.g. `"order.lineItems"`); yields each page's `nodes` array
- `GraphqlClient#execute` (private) — extracted shared POST logic; `query` and `mutate` both delegate to it
- `GraphqlClient#dig_path` (private) — resolves dot-separated key paths against nested response hashes
- Roadmap: removed stale Pagination entry from 0.8.0 (shipped in 0.3.0); Retry/backoff renumbered to 0.8.0

## [0.3.0] - 2026-03-29

### Added
- `Printavo::Page` — value object wrapping `records`, `has_next_page`, `end_cursor` with `to_a`, `size`, `empty?`
- `Printavo::Resources::Base#each_page` — yields each page of records as an Array, following cursors automatically
- `Printavo::Resources::Base#all_pages` — returns all records across all pages as a flat Array
- All resources (`Customers`, `Orders`, `Jobs`, `Statuses`, `Inquiries`) implement `fetch_page` and support `each_page`/`all_pages`
- `Jobs#each_page(order_id:)` and `Jobs#all_pages(order_id:)` — `order_id` forwarded via `**kwargs`
- `bin/lint` — multi-Ruby RuboCop runner mirroring `bin/spec` (reads versions from `.mise.toml`)
- Roadmap: moved Pagination from 0.8.0 to 0.3.0; Webhooks slot repurposed

### Changed
- All resource `all` methods refactored to delegate to `fetch_page` (backward compatible — still returns `Array`)

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
