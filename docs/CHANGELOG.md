<!-- docs/CHANGELOG.md -->
# Changelog for [printavo-ruby](https://github.com/scarver2/printavo-ruby)

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.17.0] - 2026-04-01

### Added
- `Order#visual_id`, `Order#created_at`, `Order#updated_at` — expose `VisualIDed` and
  `Timestamps` interface fields on the `Order` model
- `Invoice#visual_id`, `Invoice#created_at`, `Invoice#updated_at` — same for `Invoice`
- `Customer#created_at`, `Customer#updated_at` — `Timestamps` interface fields
- `Contact#created_at`, `Contact#updated_at` — `Timestamps` interface fields
- `CustomAddress#country` — completes the `MailAddress` interface (`address`, `city`,
  `state`, `zip`, `country` are now all exposed)
- `visualId`, `createdAt`, `updatedAt` added to all order/invoice query and mutation
  GraphQL files (`find`, `all`, `create`, `update`)
- `createdAt`, `updatedAt` added to customer and contact query/mutation files
- `country` added to all 6 custom_address query/mutation files
- Gem version badge in `README.md` switched to `badge.fury.io` service

## [0.16.0] - 2026-04-01

### Added
- `Printavo::Enums` namespace — 18 enum modules covering every GraphQL enum in the
  Printavo V2 schema (excluding `__DirectiveLocation` and `__TypeKind`, which are
  GraphQL introspection internals):
  - `ApprovalRequestStatus` — APPROVED, DECLINED, PENDING, REVOKED, UNAPPROVED
  - `ContactSortField` — CONTACT_EMAIL, CONTACT_NAME, CUSTOMER_NAME, ORDER_COUNT
  - `LineItemSize` — full garment size set (size_xs–size_6xl, youth, toddler, infant, size_other)
  - `LineItemStatus` — arrived, attached_to_po, in, need_ordering, ordered, partially_received, received
  - `MerchOrderDeliveryMethod` — DELIVERY, PICKUP
  - `MerchOrderStatus` — FULFILLED, UNFULFILLED
  - `MerchStoreStatus` — CLOSED, LIVE
  - `MessageDeliveryStatus` — BOUNCED, CLICKED, DELIVERED, ERROR, LINKED, OPENED, OTHER, PAY_FOR, PENDING, REJECTED, SENT
  - `OrderPaymentStatus` — PAID, PARTIAL_PAYMENT, UNPAID
  - `OrderSortField` — CUSTOMER_DUE_AT, CUSTOMER_NAME, OWNER, STATUS, TOTAL, VISUAL_ID
  - `PaymentDisputeStatusField` — DISPUTE_INITIATED, DISPUTE_IN_REVIEW, DISPUTE_LOST, DISPUTE_WON, RETRIEVAL_REQUEST
  - `PaymentRequestStatus` — ARCHIVED, CLOSED, OPEN
  - `PoGoodsStatus` — arrived, not_ordered, ordered, partially_received, received
  - `StatusType` — INVOICE, QUOTE
  - `TaskSortField` — CREATED_AT, DUE_AT
  - `TaskableType` — CUSTOMER, INVOICE, QUOTE
  - `TransactionCategory` — BANK_TRANSFER, CASH, CHECK, CREDIT_CARD, ECHECK, OTHER
  - `TransactionSource` — MANUAL, PROCESSOR
- Each enum exposes an `ALL` frozen array of all values
- Shared RSpec example `'a Printavo enum'` validates structure across all 18 modules

## [0.15.0] - 2026-04-01

### Added
- `Printavo::Client` now accepts `max_retries:` (default: 2) and `retry_on_rate_limit:` (default: true)
- `Printavo::Connection` — exponential backoff with ±50% jitter on retries (`backoff_factor: 2`,
  `interval_randomness: 0.5`); retry statuses are `[500, 502, 503]` plus `429` when
  `retry_on_rate_limit: true`
- `Printavo::CLI` — Thor-based command-line interface:
  - `printavo customers [--first N]` — list customers (tab-aligned output)
  - `printavo orders [--first N]` — list orders (default subcommand)
  - `printavo orders find ID` — find and display a single order
  - Credentials read from `PRINTAVO_EMAIL` / `PRINTAVO_TOKEN` environment variables
- `bin/printavo` executable (installed to PATH as `printavo`)
- `thor ~> 1.0` added as a runtime dependency
- `.graphql` files and `bin/` now included in `spec.files` (fixes missing graphql files in
  published gem)

## [0.14.0] - 2026-04-01

### Added
- `Contacts#delete(id)` — `contactDelete` mutation
- `Customers#delete(id)` — `customerDelete` mutation
- `Inquiries#delete(id)` — `inquiryDelete` mutation
- `Invoices#delete(id)` — `invoiceDelete` mutation
- `Invoices#duplicate(id)` — `invoiceDuplicate` mutation; returns a new `Printavo::Invoice`
- `Orders#delete(id)` — `quoteDelete` mutation
- `Orders#duplicate(id)` — `quoteDuplicate` mutation; returns a new `Printavo::Order`
- 7 new `.graphql` files under `lib/printavo/graphql/`

## [0.13.0] - 2026-03-31

### Added
- `Printavo::User` model (`id`, `first_name`, `last_name`, `email`, `full_name`)
- `Users` resource: `all`, `find(id)` — shop staff members
- `Printavo::Vendor` model (`id`, `name`, `email`, `phone`)
- `Vendors` resource: `all`, `find(id)` — read-only
- `Printavo::ContractorProfile` model (`id`, `name`, `email`)
- `ContractorProfiles` resource: `all`, `find(id)`
- `Printavo::DeliveryMethod` model (`id`, `name`)
- `DeliveryMethods` resource: `all`, `find(id)`, `create(**input)`, `update(id, **input)`, `archive(id)`
- `deliveryMethodCreate`, `deliveryMethodUpdate`, `deliveryMethodArchive` mutations
- `Printavo::TypeOfWork` model (`id`, `name`)
- `TypesOfWork` resource: `all` — reference data for order categorization
- `client.contractor_profiles`, `client.delivery_methods`, `client.types_of_work`,
  `client.users`, `client.vendors` entry points on `Printavo::Client`
- 11 new `.graphql` files under `lib/printavo/graphql/`
- 1 new factory file: `spec/support/factories/people.rb`

## [0.12.0] - 2026-03-31

### Added
- `Printavo::ProductionFile` model (`id`, `url`, `filename`, `created_at`)
- `ProductionFiles` resource: `all(order_id:)`, `find(id)`, `create(**input)` / `creates(inputs)`,
  `delete(id)` / `deletes(ids)`
- `Printavo::Mockup` model (`id`, `url`, `position`, `created_at`)
- `Mockups` resource: `all(order_id:)`, `find(id)`, `delete(id)` / `deletes(ids)` — no create (mockups are
  attached via `LineItems#mockup_create` and `Imprints#mockup_create`)
- `Printavo::EmailTemplate` model (`id`, `name`, `subject`, `body`)
- `EmailTemplates` resource: `all`, `find(id)` — read-only
- `Printavo::CustomAddress` model (`id`, `name`, `address`, `city`, `state`, `zip`)
- `CustomAddresses` resource: `all(order_id:)`, `find(id)`, `create(**input)` / `creates(inputs)`,
  `update(id, **input)` / `updates(inputs)`, `delete(id)` / `deletes(ids)`
- `client.custom_addresses`, `client.email_templates`, `client.mockups`, `client.production_files`
  entry points on `Printavo::Client`
- 20 new `.graphql` files under `lib/printavo/graphql/`
- 1 new factory file: `spec/support/factories/media.rb`

## [0.11.0] - 2026-03-31

### Added
- `Printavo::ApprovalRequest` model (`id`, `status`, `sent_at`, `expires_at`, `contact` — returns `Printavo::Contact`)
- `ApprovalRequests` resource: `all(order_id:)`, `find(id)`, `create(**input)`,
  `approve(id)`, `revoke(id)`, `unapprove(id)` — action mutations return updated `ApprovalRequest`
- `Printavo::PresetTask` model (`id`, `body`, `due_offset_days`, `assignee`)
- `PresetTasks` resource: `find(id)`, `create(**input)`, `update(id, **input)`, `delete(id)` —
  no standalone listing; preset tasks are accessed via `PresetTaskGroup#tasks`
- `Printavo::PresetTaskGroup` model (`id`, `name`, `tasks` — returns `[PresetTask]`)
- `PresetTaskGroups` resource: `all`, `find(id)`, `create(**input)`, `update(id, **input)`,
  `delete(id)`, `apply(id, order_id:)` — `apply` returns `[Printavo::Task]` (live tasks created on the order)
- `client.approval_requests`, `client.preset_task_groups`, `client.preset_tasks`
  entry points on `Printavo::Client`
- 16 new `.graphql` files under `lib/printavo/graphql/`
- 2 new factory files: `spec/support/factories/approval_request.rb`, `spec/support/factories/preset_task.rb`

## [0.10.0] - 2026-03-31

### Added
- `Printavo::Payment` model (`id`, `amount`, `payment_method`, `paid_at`)
- `Payments` resource: `all(order_id:)`, `find(id)` — read-only, scoped to an order
- `Printavo::PaymentRequest` model (`id`, `amount`, `sent_at`, `paid_at`, `details`)
- `PaymentRequests` resource: `all(order_id:)`, `find(id)`, `create(**input)`, `delete(id)` —
  `paymentRequestCreate` / `paymentRequestDelete` mutations
- `Printavo::PaymentTerm` model (`id`, `name`, `net_days`)
- `PaymentTerms` resource: `all`, `find(id)`, `create(**input)`, `update(id, **input)`,
  `archive(id)` — `paymentTermCreate` / `paymentTermUpdate` / `paymentTermArchive` mutations;
  `archive` returns `nil` (same convention as `delete`)
- `client.payments`, `client.payment_requests`, `client.payment_terms` entry points
  on `Printavo::Client`
- 11 new `.graphql` files under `lib/printavo/graphql/`

## [0.9.0] - 2026-03-31

### Added
- `Printavo::MerchStore` model (`id`, `name`, `url`, `summary`)
- `MerchStores` resource: `all`, `find(id)`
- `Printavo::MerchOrder` model (`id`, `status`, `delivery`, `contact` — returns `Printavo::Contact`)
- `MerchOrders` resource: `all`, `find(id)`
- `Printavo::Product` model (`id`, `name`, `sku`, `description`)
- `Products` resource: `all`, `find(id)`
- `Printavo::PricingMatrix` model (`id`, `name`)
- `PricingMatrices` resource: `all`, `find(id)`
- `Printavo::Category` model (`id`, `name`)
- `Categories` resource: `all`, `find(id)`
- `client.categories`, `client.merch_orders`, `client.merch_stores`, `client.pricing_matrices`,
  `client.products` entry points on `Printavo::Client`
- 10 new `.graphql` files under `lib/printavo/graphql/`
- 2 new factory files: `spec/support/factories/merch.rb`, `spec/support/factories/product.rb`

## [0.8.0] - 2026-03-31

### Added
- `Printavo::LineItem` model (`id`, `name`, `quantity`, `price`, `taxable`, `taxable?`)
- `LineItems` resource: `all(line_item_group_id:)`, `find`, `create`/`creates`, `update`/`updates`,
  `delete`/`deletes`, `mockup_create`/`mockup_creates`
- `Printavo::LineItemGroup` model (`id`, `name`, `description`)
- `LineItemGroups` resource: `all(order_id:)`, `find`, `create`/`creates`, `update`/`updates`, `delete`/`deletes`
- `Printavo::Imprint` model (`id`, `name`, `position`, `colors`)
- `Imprints` resource: `all(line_item_group_id:)`, `find`, `create`/`creates`, `update`/`updates`,
  `delete`/`deletes`, `mockup_create`/`mockup_creates`
- `Printavo::Fee` model (`id`, `name`, `amount`, `taxable`, `taxable?`)
- `Fees` resource: `all(order_id:)`, `find`, `create`/`creates`, `update`/`updates`, `delete`/`deletes`
- `Printavo::Expense` model (`id`, `name`, `amount`, `category`)
- `Expenses` resource: `all(order_id:)`, `find`, `create`, `update`
- `client.line_items`, `client.line_item_groups`, `client.imprints`, `client.fees`, `client.expenses`
  entry points on `Printavo::Client`
- 40 new `.graphql` files under `lib/printavo/graphql/`

### Changed
- `camelize_keys` moved from individual resource classes to `Resources::Base` — eliminates 7 duplicate definitions

## [0.7.0] - 2026-03-30

### Added
- `Printavo::Transaction` model (`id`, `amount`, `kind`, `created_at`)
- `Transactions` resource: `all(order_id:)`, `find(id)` — scoped to an order, same pattern as Jobs
- `Printavo::TransactionPayment` model (`id`, `amount`, `payment_method`, `paid_at`, `note`)
- `TransactionPayments` resource: `create(**input)`, `update(id, **input)`, `delete(id)` —
  mutation-only; `transactionPaymentCreate/Update/Delete`
- `Printavo::Task` model (`id`, `body`, `due_at`, `completed_at`, `completed?`, `assignee`)
- `Tasks` resource: `all`, `find(id)`, `create(**input)`, `update(id, **input)`,
  `complete(id)` (sets `completedAt` to now via `taskUpdate`), `delete(id)`
- `Printavo::Thread` model (`id`, `subject`, `created_at`, `updated_at`)
- `Threads` resource: `all(order_id:)`, `find(id)`, `update(id, **input)`,
  `email_message_create(**input)` — `threadUpdate` + `emailMessageCreate` mutations;
  returns raw hash (no `EmailMessage` model yet)
- `client.tasks`, `client.threads`, `client.transactions`, `client.transaction_payments`
  entry points on `Printavo::Client`
- 14 new `.graphql` files under `lib/printavo/graphql/`
- `Client#login` / `Client#logout` raise `NotImplementedError` with a message directing
  consumers to the `email` + `token` initializer; gem uses stateless header-based auth

## [0.6.0] - 2026-03-30

### Added
- `Printavo::Contact` model (`id`, `first_name`, `last_name`, `full_name`, `email`, `phone`, `fax`)
- `Contacts` resource: `find(id)`, `create(**input)`, `contactCreate` mutation,
  `update(id, **input)`, `contactUpdate` mutation
- `Printavo::Invoice` model (`id`, `nickname`, `total`, `amount_paid`,
  `amount_outstanding`, `paid_in_full?`, `invoice_at`, `payment_due_at`,
  `status`, `status_key`, `status?`, `contact`)
- `Invoices` resource: `all`, `find(id)`, `update(id, **input)` (`invoiceUpdate` mutation);
  note: invoices are promoted from quotes, so no `create` — use `client.orders.create`
- `Printavo::Account` model (`id`, `company_name`, `company_email`, `phone`,
  `website`, `logo_url`, `locale`)
- `Account` resource: singleton `find` — no ID argument, returns the account
  associated with the current API credentials
- `client.contacts`, `client.invoices`, `client.account` entry points on `Printavo::Client`
- 10 new `.graphql` files under `lib/printavo/graphql/` (contacts/find, create, update;
  invoices/all, find, update; account/find)

### Changed
- `spec/support/factories.rb` split into 9 domain files under `spec/support/factories/`
  (`account`, `contact`, `customer`, `graphql`, `inquiry`, `invoice`, `job`, `order`, `status`)
- `spec/spec_helper.rb` loads factory files via `Dir` glob; `config.include Factories` moved here
- Removed `Metrics/ModuleLength` exclusion from `.rubocop.yml` — no longer needed

## [0.5.2] - 2026-03-30

### Changed
- `README.md` Versioning Roadmap section replaced with links to `docs/CHANGELOG.md`
  and `docs/TODO.md` — eliminates milestone table duplication and content drift
- Gem version badge switched from `badge.fury.io` to `img.shields.io` for reliable
  version number display
- `docs/TODO.md` added: full project task list with completed items checked through
  v0.5.1, open items through v1.0, and Printavo API V2 coverage gap analysis
  (Contacts, Invoices, LineItemGroups, Merch, Transactions, Tasks, Threads, Account,
  delete mutations, Product catalog)
- `docs/CHANGELOG.md`, `docs/FUTURE.md`, `docs/TODO.md` headers and footers
  standardized; titles linked to GitHub project URL
- Root `CHANGELOG.md` removed (duplicate of `docs/CHANGELOG.md` introduced in 0.5.1)

## [0.5.1] - 2026-03-30

### Changed
- Extracted all 17 embedded GraphQL heredoc constants from resource files into
  external `.graphql` files under `lib/printavo/graphql/<resource>/<operation>.graphql`
- Constants are loaded via `File.read` at class definition time — runtime behavior
  and constant names are unchanged
- Added `# frozen_string_literal: true` to all 39 `.rb` files in `lib/` and `spec/`

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

## Colophon

[MIT License](LICENSE)

&copy;2026 [Stan Carver II](https://stancarver.com)

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
