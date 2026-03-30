<!-- docs/TODO.md -->
# Project TODO for [printavo-ruby](https://github.com/scarver2/printavo-ruby)

Full task list for `printavo-ruby` across all versions. Checked items are shipped.

---

## Foundation

- [x] Scaffold gem with RSpec, GitHub Actions CI, MIT license
- [x] `Printavo::Client` — instance-based, multi-client capable entry point
- [x] `Printavo::Connection` — Faraday builder with `email` + `token` headers
- [x] `Printavo::GraphqlClient` — raw `query` interface over POST
- [x] `Printavo::Error` hierarchy (`AuthenticationError`, `RateLimitError`, `NotFoundError`, `ApiError`)
- [x] Faraday retry middleware (max 2 retries; 429/5xx)
- [x] RSpec + VCR + WebMock + Faker sanitization — 100% line coverage
- [x] SimpleCov + Coveralls coverage badge
- [x] Guard + RuboCop DX setup
- [x] `bin/spec` — multi-Ruby local test runner (reads versions from `.mise.toml`)
- [x] `bin/lint` — multi-Ruby RuboCop runner
- [x] GitHub Actions CI: Ruby 3.3 + Ruby 4.0 matrix
- [x] Automated RubyGems publish on `v*` tag via trusted publishing (`release.yml`)
- [x] Git pre-push hook: guards `Gemfile.lock` version sync and `x86_64-linux` platform

---

## Resources & Models

- [x] `Customers` — `all`, `find`
- [x] `Orders` — `all`, `find`
- [x] `Jobs` — `all` (by order), `find`
- [x] `Statuses` — `all`, `find`, `registry` (O(1) Symbol lookup)
- [x] `Inquiries` — `all`, `find`
- [x] `Printavo::Customer` model
- [x] `Printavo::Order` model with `status_key`, `status?`, `status_id`, `status_color`
- [x] `Printavo::Job` model
- [x] `Printavo::Status` model with `key` (snake_case Symbol)
- [x] `Printavo::Inquiry` model

---

## Mutations

- [x] `GraphqlClient#mutate` — semantic write method (same transport as `query`)
- [x] `Customers#create(primary_contact:, **input)` — `customerCreate`
- [x] `Customers#update(id, **input)` — `customerUpdate`
- [x] `Orders#create(**input)` — `quoteCreate`
- [x] `Orders#update(id, **input)` — `quoteUpdate`
- [x] `Orders#update_status(id, status_id:)` — `statusUpdate` (handles `OrderUnion` via inline fragments)
- [x] `Inquiries#create(**input)` — `inquiryCreate`
- [x] `Inquiries#update(id, **input)` — `inquiryUpdate`
- [x] `camelize_keys` — snake_case → camelCase input conversion
- [x] `build_customer` / `build_order` — mutation response normalization helpers

---

## Pagination

- [x] `Printavo::Page` — value object (`records`, `has_next_page`, `end_cursor`, `to_a`, `size`, `empty?`)
- [x] `Resources::Base#each_page` — cursor-following page enumerator
- [x] `Resources::Base#all_pages` — flat array across all pages
- [x] `GraphqlClient#paginate` — raw cursor pagination with dot-path resolution

---

## Code Quality & DX

- [x] `# frozen_string_literal: true` on all 39 `.rb` files
- [x] Extract 17 GraphQL heredocs into external `.graphql` files (`lib/printavo/graphql/<resource>/<op>.graphql`)
- [x] `docs/` consolidation — `CHANGELOG.md`, `CONTRIBUTING.md`, `FUTURE.md`, `CACHING.md`
- [x] `docs/CACHING.md` — nine caching strategy patterns for rate-limit-aware consumers

---

## Webhooks

- [x] `Printavo::Webhooks.verify` — Rack-compatible HMAC-SHA256 signature verification
- [ ] Webhook event type registry (map Printavo event names to Ruby symbols)
- [ ] Rack middleware: `Printavo::Webhooks::Middleware` (verify + parse in one step)

---

## API V2 Coverage Gaps

Resources and mutations present in the Printavo V2 GraphQL API that are not yet
wrapped by a resource class. Raw GraphQL access works for all of these today via
`client.graphql.query(...)` — these tasks add first-class resource support.

### Contacts

- [ ] `Printavo::Contact` model (`id`, `firstName`, `lastName`, `email`, `phone`)
- [ ] `Contacts` resource: `find(id)`
- [ ] `contact` query (contacts are distinct from the customer's `primaryContact`)

### Invoices

- [ ] `Printavo::Invoice` model (mirrors Order; has `invoiceNumber`, `paidAt`, `balanceDue`)
- [ ] `Invoices` resource: `all`, `find(id)`
- [ ] `client.invoices` entry point on `Printavo::Client`

### Line Item Groups

- [ ] `Printavo::LineItemGroup` model (`id`, `name`, `description`)
- [ ] `LineItemGroups` resource: `all(order_id:)`, `find(id)`
- [ ] `lineItemGroup` / `lineItemGroups` queries

### Merch

- [ ] `Printavo::MerchStore` model
- [ ] `Printavo::MerchOrder` model
- [ ] `MerchStores` resource: `all`, `find(id)`
- [ ] `MerchOrders` resource: `all`, `find(id)`
- [ ] `client.merch_stores` / `client.merch_orders` entry points

### Transactions & Payments

- [ ] `Printavo::Transaction` model (`id`, `amount`, `kind`, `createdAt`)
- [ ] `Transactions` resource: `all(order_id:)`, `find(id)`
- [ ] Payment request mutations
- [ ] Payment dispute handling

### Tasks

- [ ] `Printavo::Task` model (`id`, `body`, `dueAt`, `completedAt`, `assignee`)
- [ ] `Tasks` resource: `all`, `find(id)`, `create`, `update`, `complete`
- [ ] `taskCreate`, `taskUpdate` mutations

### Threads (Messages)

- [ ] `Printavo::Thread` model (`id`, `body`, `author`, `createdAt`)
- [ ] `Threads` resource: `all(order_id:)`, `find(id)`, `create`
- [ ] `threadCreate` mutation

### Account

- [ ] `Printavo::Account` model (shop-level info: name, address, phone, logo)
- [ ] `Account` resource: `find` (singleton — no ID needed)
- [ ] `account` query

### Delete Mutations

- [ ] `customerDelete(id:)`
- [ ] `quoteDelete(id:)` / `invoiceDelete(id:)`
- [ ] `lineItemDelete(id:)`
- [ ] `taskDelete(id:)`

### Product Catalog & Pricing

- [ ] `Printavo::Product` model
- [ ] `Products` resource: `all`, `find(id)`
- [ ] Pricing matrix queries

---

## Planned Versions

### v0.6.0 — Invoices, Contacts & Analytics

- [ ] `Invoices` resource (`all`, `find`)
- [ ] `Contacts` resource (`find`)
- [ ] `Account` resource (singleton)
- [ ] Analytics/Reporting resource: revenue, job counts, customer activity, turnaround times
- [ ] Community burn-in — gather feedback on 0.5.x API surface

### v0.7.0 — Transactions, Tasks & Threads

- [ ] `Transactions` resource (`all`, `find`)
- [ ] `Tasks` resource (`all`, `find`, `create`, `update`, `complete`)
- [ ] `Threads` resource (`all`, `find`, `create`)
- [ ] Delete mutations for Customer, Order, LineItem, Task

### v0.8.0 — Merch & Products

- [ ] `MerchStores` + `MerchOrders` resources
- [ ] `LineItemGroups` resource
- [ ] `Products` resource + pricing matrix queries

### v0.9.0 — Retry / Backoff & CLI

- [ ] Configurable `max_retries` on `Printavo::Client`
- [ ] Exponential backoff with jitter on 429 responses
- [ ] `retry_on_rate_limit: true/false` client option
- [ ] Thor-based `printavo` CLI (`customers`, `orders`, `orders find <id>`)

### v0.10.0 — API Freeze

- [ ] Community feedback integration
- [ ] Deprecation notices for any renamed methods
- [ ] Full YARD API reference
- [ ] Final documentation pass before 1.0

### v1.0.0 — Stable SDK

- [ ] Semver stability guarantee
- [ ] Migration guide from 0.x

---

## Future / Stretch Goals

### Built-In Cache Adapter

- [ ] Optional `cache:` kwarg on `Printavo::Client`
- [ ] Adapter interface: `read(key)` / `write(key, value, ttl:)` / `delete(key)`
- [ ] `Rails.cache`, Redis, and in-memory adapter support

### Workflow Diagram Generation

- [ ] `client.workflow.diagram(format: :svg)` — visual status flowchart
- [ ] `ruby-graphviz` backend (DOT → SVG/PNG)
- [ ] Mermaid output option (embed in GitHub markdown)

### Multi-Language SDK Family

- [ ] `printavo-python`
- [ ] `printavo-swift`
- [ ] `printavo-zig`
- [ ] `printavo-odin`

---


## Colophon

[MIT License](LICENSE)

&copy;2026 [Stan Carver II](https://stancarver.com)

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
