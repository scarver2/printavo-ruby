<!-- CHANGELOG.md -->

# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.5.1] - 2026-03-30

### Changed
- Extracted all 17 embedded GraphQL heredoc constants from resource files into
  external `.graphql` files under `lib/printavo/graphql/<resource>/<operation>.graphql`
- Constants are loaded via `File.read` at class definition time — runtime behavior
  and constant names are unchanged
- Added `# frozen_string_literal: true` to all 39 `.rb` files in `lib/` and `spec/`

---

## [0.5.0] - 2026-03-29

### Added
- `Customers#create` and `Customers#update` mutations (`customerCreate`, `customerUpdate`)
- `Orders#create`, `Orders#update`, and `Orders#update_status` mutations
  (`quoteCreate`, `quoteUpdate`, `statusUpdate`)
- `Inquiries#create` and `Inquiries#update` mutations (`inquiryCreate`, `inquiryUpdate`)
- Response normalization helpers: `build_customer` (flattens `primaryContact`,
  maps `companyName` → `company`) and `build_order` (maps `total` → `totalPrice`)
- `camelize_keys` private helper on `Customers` and `Orders` for snake_case → camelCase
  GraphQL input conversion
- `GraphqlClient#mutate` method for executing GraphQL mutations
- Git pre-push hook to guard against `Gemfile.lock` version mismatch and missing
  `x86_64-linux` platform

---

## [0.4.0] - 2026-03-28

### Added
- `GraphqlClient#mutate` DSL method
- `GraphqlClient#paginate` helper for cursor-based pagination
- `Printavo::Page` value object (`records`, `has_next_page`, `end_cursor`)

---

## [0.3.0] - 2026-03-27

### Added
- Pagination helpers: `paginate` on resource classes, `each_page` enumerator
- `bin/lint` script for local RuboCop runs

---

## [0.2.0] - 2026-03-26

### Added
- `Statuses` resource with `all`, `find`, and `registry` (O(1) Symbol lookup)
- `Inquiries` resource with `all` and `find`
- `Printavo::Status` and `Printavo::Inquiry` models
- `Order#status_key` and `Order#status?` helpers
- Consolidated documentation under `docs/`

---

## [0.1.0] - 2026-03-25

### Added
- Initial release: `Printavo::Client` with `customers`, `orders`, and `jobs` resources
- `Customers#all` and `Customers#find`
- `Orders#all` and `Orders#find`
- `Jobs#all` and `Jobs#find`
- `Printavo::Customer`, `Printavo::Order`, `Printavo::Job` models
- `Printavo::Webhooks.verify` (Rack-compatible HMAC signature verification)
- Faraday + faraday-retry HTTP transport
- RSpec + VCR + WebMock + SimpleCov test suite (100% coverage)
- Guard + RuboCop DX tooling
- GitHub Actions CI + RubyGems trusted publishing release workflow

---

_Stan Carver II — Made in Texas — https://stancarver.com_
