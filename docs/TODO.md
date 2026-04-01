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
- [x] `Client#login` / `Client#logout` — raise `NotImplementedError`; gem uses header-based auth, not session mutations

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
- [ ] `Contacts#delete(id)` — `contactDelete`
- [ ] `Customers#delete(id)` — `customerDelete`
- [ ] `Inquiries#delete(id)` — `inquiryDelete`
- [ ] `Invoices#delete(id)` — `invoiceDelete`
- [ ] `Invoices#duplicate(id)` — `invoiceDuplicate`
- [ ] `Orders#delete(id)` — `quoteDelete`
- [ ] `Orders#duplicate(id)` — `quoteDuplicate`

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
- [x] Split `spec/support/factories.rb` monolith into 9 domain files under `spec/support/factories/`

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

### Embedded / Infrastructure Types (no standalone resource needed)

These types appear in the schema but are sub-objects, pagination wrappers, or
return values — they are exposed via model field accessors, not separate resources.

- `*Connection` / `*Edge` (all variants) — GraphQL pagination wrappers; handled by `Printavo::Page`
- `Address`, `BillingAddress`, `CustomerAddress`, `MerchAddress`, `CustomAddress` — embedded address shapes
- `Avatar` — embedded in `User`
- `CatalogInformation`, `InvoiceInformation` — embedded in `Account`
- `DeletedID` — return type for delete mutations
- `EmailMessage`, `TextMessage` — message subtypes under `Thread`
- `Feature`, `FeatureRestriction` — embedded in `Account.features`
- `LineItemEnabledColumns`, `LineItemGroupSize`, `LineItemPriceReceipt`, `LineItemSizeCount` — embedded in `LineItemGroup` / `LineItem`
- `LoggedIn` — auth response type for `login` / `logout` mutations; not wrapped — gem uses
  header-based auth. Both methods raise `NotImplementedError` on `Printavo::Client` with a
  message directing consumers to the `email` + `token` initializer pattern.
- `MerchOrderDelivery`, `MerchStoreSummary` — embedded in `MerchOrder` / `MerchStore`
- `MessageAttachment` — embedded in `Thread` messages
- `ObjectTimestamps` — `createdAt` / `updatedAt` on all objects
- `OrderUnionConnection` / `OrderUnionEdge` — union pagination for `Quote | Invoice`; handled via inline fragments
- `PageInfo` — cursor pagination metadata; handled by `Printavo::Page`
- `PaymentRequestDetail` — embedded in `PaymentRequest`
- `Permission` — embedded in `User`
- `Personalization` — size/color breakdown embedded in `LineItem` / `Imprint`
- `PricingMatrixCell`, `PricingMatrixColumn` — sub-objects of `PricingMatrix`
- `ProductCatalog` — configuration embedded in `Account`
- `Social` — social media links embedded in `Account`
- `ThreadSummary` — preview summary embedded on orders; not a standalone query
- `TransactionDetails`, `TransactionUnionConnection`, `TransactionUnionEdge` — embedded / pagination wrappers

---

### Account ✅

- [x] `Printavo::Account` model (shop-level info: name, address, phone, logo)
- [x] `Account` resource: `find` (singleton — no ID needed)
- [x] `account` query

### Contacts ✅

- [x] `Printavo::Contact` model (`id`, `firstName`, `lastName`, `email`, `phone`)
- [x] `Contacts` resource: `find(id)`, `create`, `update`
- [x] `contact` query (contacts are distinct from the customer's `primaryContact`)

### Invoices ✅

- [x] `Printavo::Invoice` model (mirrors Order; has `amountPaid`, `amountOutstanding`, `paidInFull?`)
- [x] `Invoices` resource: `all`, `find(id)`, `update`
- [x] `client.invoices` entry point on `Printavo::Client`

---

### Approvals ✅

- [x] `Printavo::ApprovalRequest` model (`id`, `status`, `sent_at`, `expires_at`, `contact`)
- [x] `ApprovalRequests` resource: `all(order_id:)`, `find(id)`
- [x] `approvalRequestCreate` mutation
- [x] `approvalRequestApprove(id:)` mutation
- [x] `approvalRequestRevoke(id:)` mutation
- [x] `approvalRequestUnapprove(id:)` mutation

### Categories ✅

- [x] `Printavo::Category` model (`id`, `name`)
- [x] `Categories` resource: `all`, `find(id)` — reference data for products/line items

### Contractor Profiles

- [ ] `Printavo::ContractorProfile` model (`id`, `name`, `email`)
- [ ] `ContractorProfiles` resource: `all`, `find(id)` — contractors assignable to invoices

### Custom Addresses ✅

- [x] `Printavo::CustomAddress` model (`id`, `name`, `address`, `city`, `state`, `zip`)
- [x] `CustomAddresses` resource: `all(order_id:)`, `find(id)`, `create`, `update`, `delete`
- [x] `customAddressCreate` / `customAddressCreates` (bulk) mutations
- [x] `customAddressUpdate` / `customAddressUpdates` (bulk) mutations
- [x] `customAddressDelete` / `customAddressDeletes` (bulk) mutations

### Delivery Methods

- [ ] `Printavo::DeliveryMethod` model (`id`, `name`)
- [ ] `DeliveryMethods` resource: `all`, `find(id)`, `create`, `update`, `archive`
- [ ] `deliveryMethodCreate`, `deliveryMethodUpdate`, `deliveryMethodArchive` mutations

### Email Templates ✅

- [x] `Printavo::EmailTemplate` model (`id`, `name`, `subject`, `body`)
- [x] `EmailTemplates` resource: `all`, `find(id)`

### Expenses ✅

- [x] `Printavo::Expense` model (`id`, `name`, `amount`, `category`)
- [x] `Expenses` resource: `all(order_id:)`, `find(id)`, `create`, `update`
- [x] `expenseCreate`, `expenseUpdate` mutations

### Fees ✅

- [x] `Printavo::Fee` model (`id`, `name`, `amount`, `taxable`)
- [x] `Fees` resource: `all(order_id:)`, `find(id)`, `create`, `update`, `delete`
- [x] `feeCreate` / `feeCreates` (bulk) mutations
- [x] `feeUpdate` / `feeUpdates` (bulk) mutations
- [x] `feeDelete` / `feeDeletes` (bulk) mutations

### Imprints ✅

- [x] `Printavo::Imprint` model (`id`, `name`, `position`, `colors`)
- [x] `Imprints` resource: `all(line_item_group_id:)`, `find(id)`, `create`, `update`, `delete`
- [x] `imprintCreate` / `imprintCreates` (bulk) mutations
- [x] `imprintUpdate` / `imprintUpdates` (bulk) mutations
- [x] `imprintDelete` / `imprintDeletes` (bulk) mutations
- [x] `imprintMockupCreate` / `imprintMockupCreates` (bulk) — attach mockup to imprint

### Line Items ✅

- [x] `Printavo::LineItem` model (`id`, `name`, `quantity`, `price`, `taxable`)
- [x] `LineItems` resource: `all(line_item_group_id:)`, `find(id)`, `create`, `update`, `delete`
- [x] `lineItemCreate` / `lineItemCreates` (bulk) mutations
- [x] `lineItemUpdate` / `lineItemUpdates` (bulk) mutations
- [x] `lineItemDelete` / `lineItemDeletes` (bulk) mutations
- [x] `lineItemMockupCreate` / `lineItemMockupCreates` (bulk) — attach mockup to line item

### Line Item Groups ✅

- [x] `Printavo::LineItemGroup` model (`id`, `name`, `description`)
- [x] `LineItemGroups` resource: `all(order_id:)`, `find(id)`, `create`, `update`, `delete`
- [x] `lineItemGroupCreate` / `lineItemGroupCreates` (bulk) mutations
- [x] `lineItemGroupUpdate` / `lineItemGroupUpdates` (bulk) mutations
- [x] `lineItemGroupDelete` / `lineItemGroupDeletes` (bulk) mutations

### Merch ✅

- [x] `Printavo::MerchStore` model (`id`, `name`, `url`, `summary`)
- [x] `Printavo::MerchOrder` model (`id`, `status`, `delivery`, `contact`)
- [x] `MerchStores` resource: `all`, `find(id)`
- [x] `MerchOrders` resource: `all`, `find(id)`
- [x] `client.merch_stores` / `client.merch_orders` entry points

### Mockups & Production Files ✅

- [x] `Printavo::Mockup` model (`id`, `url`, `position`, `created_at`)
- [x] `Printavo::ProductionFile` model (`id`, `url`, `filename`, `created_at`)
- [x] `Mockups` resource: `all(order_id:)`, `find(id)`, `delete`, `deletes`
- [x] `mockupDelete` / `mockupDeletes` (bulk) mutations
- [x] `ProductionFiles` resource: `all(order_id:)`, `find(id)`, `create`, `creates`, `delete`, `deletes`
- [x] `productionFileCreate` / `productionFileCreates` (bulk) mutations
- [x] `productionFileDelete` / `productionFileDeletes` (bulk) mutations

### Payments ✅

- [x] `Printavo::Payment` model (`id`, `amount`, `payment_method`, `paid_at`)
- [x] `Printavo::PaymentRequest` model (`id`, `amount`, `sent_at`, `paid_at`, `details`)
- [x] `Printavo::PaymentTerm` model (`id`, `name`, `net_days`)
- [x] `Payments` resource: `all(order_id:)`, `find(id)`
- [x] `PaymentRequests` resource: `all(order_id:)`, `find(id)`, `create`, `delete`
- [x] `paymentRequestCreate`, `paymentRequestDelete` mutations
- [x] `PaymentTerms` resource: `all`, `find(id)`, `create`, `update`, `archive`
- [x] `paymentTermCreate`, `paymentTermUpdate`, `paymentTermArchive` mutations

### Preset Tasks ✅

- [x] `Printavo::PresetTask` model (`id`, `body`, `due_offset_days`, `assignee`)
- [x] `Printavo::PresetTaskGroup` model (`id`, `name`, `tasks`)
- [x] `PresetTasks` resource: `find(id)`, `create`, `update`, `delete`
- [x] `presetTaskCreate`, `presetTaskUpdate`, `presetTaskDelete` mutations
- [x] `PresetTaskGroups` resource: `all`, `find(id)`, `create`, `update`, `delete`, `apply`
- [x] `presetTaskGroupCreate`, `presetTaskGroupUpdate`, `presetTaskGroupDelete` mutations
- [x] `presetTaskGroupApply(id:, order_id:)` mutation — applies a group to an order

### Product Catalog & Pricing ✅

- [x] `Printavo::Product` model (`id`, `name`, `sku`, `description`)
- [x] `Printavo::PricingMatrix` model (`id`, `name`)
- [x] `Products` resource: `all`, `find(id)`
- [x] `PricingMatrices` resource: `all`, `find(id)`

### Tasks ✅

- [x] `Printavo::Task` model (`id`, `body`, `dueAt`, `completedAt`, `assignee`)
- [x] `Tasks` resource: `all`, `find(id)`, `create`, `update`, `complete`, `delete`
- [x] `taskCreate`, `taskUpdate`, `taskDelete` mutations

### Threads (Messages) ✅

- [x] `Printavo::Thread` model (`id`, `subject`, `createdAt`, `updatedAt`)
- [x] `Threads` resource: `all(order_id:)`, `find(id)`, `update`
- [x] `threadUpdate` mutation
- [x] `emailMessageCreate` mutation — send an email message on a thread

### Transactions ✅

- [x] `Printavo::Transaction` model (`id`, `amount`, `kind`, `createdAt`)
- [x] `Transactions` resource: `all(order_id:)`, `find(id)`
- [x] `Printavo::TransactionPayment` model (`id`, `amount`, `paymentMethod`, `paidAt`, `note`)
- [x] `TransactionPayments` resource: `create`, `update`, `delete`
- [x] `transactionPaymentCreate`, `transactionPaymentUpdate`, `transactionPaymentDelete` mutations

### Types of Work

- [ ] `Printavo::TypeOfWork` model (`id`, `name`)
- [ ] `TypesOfWork` resource: `all` — reference data for order categorization

### Users

- [ ] `Printavo::User` model (`id`, `firstName`, `lastName`, `email`, `avatar`, `permissions`)
- [ ] `Users` resource: `all`, `find(id)` — shop staff members

### Vendors

- [ ] `Printavo::Vendor` model (`id`, `name`, `email`, `phone`)
- [ ] `Vendors` resource: `all`, `find(id)` — read-only; no create/update/delete in V2 API

---

## Planned Versions

### v0.6.0 — Invoices, Contacts & Account ✅

- [x] `Invoices` resource (`all`, `find`, `update`)
- [x] `Contacts` resource (`find`, `create`, `update`)
- [x] `Account` resource (singleton `find`)

### v0.7.0 — Transactions, Tasks & Threads ✅

- [x] `Transactions` resource (`all`, `find`) + `TransactionPayments` (`create`, `update`, `delete`)
- [x] `Tasks` resource (`all`, `find`, `create`, `update`, `complete`, `delete`)
- [x] `Threads` resource (`all`, `find`, `update`) + `emailMessageCreate`

### v0.8.0 — Order Structure: Line Items, Line Item Groups, Imprints & Fees ✅

- [x] `LineItems` resource (`all`, `find`, `create`/`creates`, `update`/`updates`, `delete`/`deletes`)
- [x] `LineItemGroups` resource (`all`, `find`, `create`/`creates`, `update`/`updates`, `delete`/`deletes`)
- [x] `Imprints` resource (`all`, `find`, `create`/`creates`, `update`/`updates`, `delete`/`deletes`, mockup attach)
- [x] `Fees` resource (`all`, `find`, `create`/`creates`, `update`/`updates`, `delete`/`deletes`)
- [x] `Expenses` resource (`all`, `find`, `create`, `update`)

### v0.9.0 — Merch, Products & Pricing ✅

- [x] `MerchStores` + `MerchOrders` resources
- [x] `Products` resource + `PricingMatrices` resource
- [x] `Categories` resource (reference data)

### v0.10.0 — Financial: Payments, Payment Terms & Requests ✅

- [x] `Payments` resource (`all`, `find`)
- [x] `PaymentRequests` resource (`all`, `find`, `create`, `delete`)
- [x] `PaymentTerms` resource (`all`, `find`, `create`, `update`, `archive`)

### v0.11.0 — Workflow: Approvals & Preset Tasks ✅

- [x] `ApprovalRequests` resource (`all`, `find`, `create`, `approve`, `revoke`, `unapprove`)
- [x] `PresetTasks` resource (`find`, `create`, `update`, `delete`)
- [x] `PresetTaskGroups` resource (`all`, `find`, `create`, `update`, `delete`, `apply`)

### v0.12.0 — Files, Media & Communication ✅

- [x] `ProductionFiles` resource (`all`, `find`, `create`/`creates`, `delete`/`deletes`)
- [x] `Mockups` resource (`all`, `find`, `delete`/`deletes`)
- [x] `EmailTemplates` resource (`all`, `find`)
- [x] `CustomAddresses` resource (`all`, `find`, `create`/`creates`, `update`/`updates`, `delete`/`deletes`)

### v0.13.0 — People, Orgs & Reference Data

- [ ] `Users` resource (`all`, `find`)
- [ ] `Vendors` resource (`all`, `find`) — read-only
- [ ] `ContractorProfiles` resource (`all`, `find`)
- [ ] `DeliveryMethods` resource (`all`, `find`, `create`, `update`, `archive`)
- [ ] `TypesOfWork` resource (`all`)

### v0.14.0 — Delete & Duplicate Mutations for Shipped Resources

- [ ] `Contacts#delete` — `contactDelete`
- [ ] `Customers#delete` — `customerDelete`
- [ ] `Inquiries#delete` — `inquiryDelete`
- [ ] `Invoices#delete` — `invoiceDelete`
- [ ] `Invoices#duplicate` — `invoiceDuplicate`
- [ ] `Orders#delete` — `quoteDelete`
- [ ] `Orders#duplicate` — `quoteDuplicate`

### v0.15.0 — Retry / Backoff & CLI

- [ ] Configurable `max_retries` on `Printavo::Client`
- [ ] Exponential backoff with jitter on 429 responses
- [ ] `retry_on_rate_limit: true/false` client option
- [ ] Thor-based `printavo` CLI (`customers`, `orders`, `orders find <id>`)

### v0.99.0 — API Freeze

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
