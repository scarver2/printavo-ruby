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
- `LoggedIn` — auth response type
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

### Approvals

- [ ] `Printavo::Approval` model (`id`, `status`, `approvedAt`, `contact`)
- [ ] `Printavo::ApprovalRequest` model (`id`, `sentAt`, `expiresAt`, `approval`)
- [ ] `Approvals` resource: `all(order_id:)`, `find(id)`
- [ ] `approvalCreate`, `approvalUpdate` mutations

### Categories

- [ ] `Printavo::Category` model (`id`, `name`)
- [ ] `Categories` resource: `all`, `find(id)` — reference data for products/line items

### Contractor Profiles

- [ ] `Printavo::ContractorProfile` model (`id`, `name`, `email`)
- [ ] `ContractorProfiles` resource: `all`, `find(id)` — contractors assignable to invoices

### Delivery Methods

- [ ] `Printavo::DeliveryMethod` model (`id`, `name`)
- [ ] `DeliveryMethods` resource: `all` — reference data (pickup, ship, etc.)

### Delete Mutations

- [ ] `contactDelete(id:)`
- [ ] `customerDelete(id:)`
- [ ] `quoteDelete(id:)` / `invoiceDelete(id:)`
- [ ] `lineItemDelete(id:)`
- [ ] `taskDelete(id:)`

### Email Templates

- [ ] `Printavo::EmailTemplate` model (`id`, `name`, `subject`, `body`)
- [ ] `EmailTemplates` resource: `all`, `find(id)`

### Expenses

- [ ] `Printavo::Expense` model (`id`, `name`, `amount`, `category`)
- [ ] `Expenses` resource: `all(order_id:)`, `find(id)`, `create`, `update`
- [ ] `expenseCreate`, `expenseUpdate` mutations

### Fees

- [ ] `Printavo::Fee` model (`id`, `name`, `amount`, `taxable`)
- [ ] `Fees` resource: `all(order_id:)`, `find(id)`, `create`, `update`
- [ ] `feeCreate`, `feeUpdate` mutations

### Imprints

- [ ] `Printavo::Imprint` model (`id`, `name`, `position`, `colors`, `personalization`)
- [ ] `Imprints` resource: `all(line_item_group_id:)`, `find(id)`, `create`, `update`
- [ ] `imprintCreate`, `imprintUpdate` mutations

### Line Item Groups

- [ ] `Printavo::LineItemGroup` model (`id`, `name`, `description`, `sizes`, `enabled_columns`)
- [ ] `LineItemGroups` resource: `all(order_id:)`, `find(id)`, `create`, `update`
- [ ] `lineItemGroupCreate`, `lineItemGroupUpdate` mutations

### Merch

- [ ] `Printavo::MerchStore` model (`id`, `name`, `url`, `summary`)
- [ ] `Printavo::MerchOrder` model (`id`, `status`, `delivery`, `contact`)
- [ ] `MerchStores` resource: `all`, `find(id)`
- [ ] `MerchOrders` resource: `all`, `find(id)`
- [ ] `client.merch_stores` / `client.merch_orders` entry points

### Mockups & Production Files

- [ ] `Printavo::Mockup` model (`id`, `url`, `position`, `createdAt`)
- [ ] `Printavo::ProductionFile` model (`id`, `url`, `filename`, `createdAt`)
- [ ] `Mockups` resource: `all(order_id:)`, `find(id)`, `create`
- [ ] `ProductionFiles` resource: `all(order_id:)`, `find(id)`, `create`

### Payments

- [ ] `Printavo::Payment` model (`id`, `amount`, `method`, `paidAt`)
- [ ] `Printavo::PaymentDispute` model (`id`, `amount`, `reason`, `status`)
- [ ] `Printavo::PaymentRequest` model (`id`, `amount`, `sentAt`, `paidAt`, `details`)
- [ ] `Printavo::PaymentTerm` model (`id`, `name`, `netDays`) — reference data
- [ ] `Payments` resource: `all(order_id:)`, `find(id)`
- [ ] `PaymentRequests` resource: `all(order_id:)`, `find(id)`, `create`
- [ ] `PaymentTerms` resource: `all` — reference data
- [ ] `paymentRequestCreate` mutation

### Preset Tasks

- [ ] `Printavo::PresetTask` model (`id`, `body`, `dueOffsetDays`, `assignee`)
- [ ] `Printavo::PresetTaskGroup` model (`id`, `name`, `tasks`)
- [ ] `PresetTaskGroups` resource: `all`, `find(id)`, `create`, `update`
- [ ] `presetTaskGroupCreate`, `presetTaskGroupUpdate` mutations

### Product Catalog & Pricing

- [ ] `Printavo::Product` model (`id`, `name`, `sku`, `description`)
- [ ] `Printavo::PricingMatrix` model (`id`, `name`, `cells`, `columns`)
- [ ] `Products` resource: `all`, `find(id)`
- [ ] `PricingMatrices` resource: `all`, `find(id)`

### Purchase Orders

- [ ] `Printavo::PurchaseOrder` model (`id`, `vendorName`, `total`, `sentAt`)
- [ ] `Printavo::PoLineItem` model (`id`, `name`, `quantity`, `price`)
- [ ] `PurchaseOrders` resource: `all`, `find(id)`, `create`, `update`
- [ ] `purchaseOrderCreate`, `purchaseOrderUpdate` mutations

### Refunds & Returns

- [ ] `Printavo::Refund` model (`id`, `amount`, `reason`, `createdAt`)
- [ ] `Printavo::Return` model (`id`, `quantity`, `reason`, `createdAt`)
- [ ] `Refunds` resource: `all(order_id:)`, `find(id)`, `create`
- [ ] `refundCreate` mutation

### Tasks

- [ ] `Printavo::Task` model (`id`, `body`, `dueAt`, `completedAt`, `assignee`)
- [ ] `Tasks` resource: `all`, `find(id)`, `create`, `update`, `complete`
- [ ] `taskCreate`, `taskUpdate` mutations

### Threads (Messages)

- [ ] `Printavo::Thread` model (`id`, `body`, `author`, `createdAt`, `attachments`)
- [ ] `Threads` resource: `all(order_id:)`, `find(id)`, `create`
- [ ] `threadCreate` mutation

### Transactions

- [ ] `Printavo::Transaction` model (`id`, `amount`, `kind`, `createdAt`, `details`)
- [ ] `Transactions` resource: `all(order_id:)`, `find(id)`

### Types of Work

- [ ] `Printavo::TypeOfWork` model (`id`, `name`)
- [ ] `TypesOfWork` resource: `all` — reference data for order categorization

### Users

- [ ] `Printavo::User` model (`id`, `firstName`, `lastName`, `email`, `avatar`, `permissions`)
- [ ] `Users` resource: `all`, `find(id)` — shop staff members

### Vendors

- [ ] `Printavo::Vendor` model (`id`, `name`, `email`, `phone`)
- [ ] `Vendors` resource: `all`, `find(id)`, `create`, `update`
- [ ] `vendorCreate`, `vendorUpdate` mutations

---

## Planned Versions

### v0.6.0 — Invoices, Contacts & Account ✅

- [x] `Invoices` resource (`all`, `find`, `update`)
- [x] `Contacts` resource (`find`, `create`, `update`)
- [x] `Account` resource (singleton `find`)

### v0.7.0 — Transactions, Tasks & Threads

- [ ] `Transactions` resource (`all`, `find`)
- [ ] `Tasks` resource (`all`, `find`, `create`, `update`, `complete`)
- [ ] `Threads` resource (`all`, `find`, `create`)
- [ ] Delete mutations: `contactDelete`, `customerDelete`, `quoteDelete`, `invoiceDelete`, `lineItemDelete`, `taskDelete`

### v0.8.0 — Order Structure: Line Item Groups, Imprints & Fees

- [ ] `LineItemGroups` resource (`all`, `find`, `create`, `update`)
- [ ] `Imprints` resource (`all`, `find`, `create`, `update`)
- [ ] `Fees` resource (`all`, `find`, `create`, `update`)
- [ ] `Expenses` resource (`all`, `find`, `create`, `update`)

### v0.9.0 — Merch, Products & Pricing

- [ ] `MerchStores` + `MerchOrders` resources
- [ ] `Products` resource + `PricingMatrices` resource
- [ ] `Categories` resource (reference data)

### v0.10.0 — Financial: Payments, Purchase Orders & Refunds

- [ ] `Payments` resource (`all`, `find`)
- [ ] `PaymentRequests` resource (`all`, `find`, `create`)
- [ ] `PaymentTerms` resource (`all`) — reference data
- [ ] `PurchaseOrders` + `PoLineItems` resources
- [ ] `Refunds` + `Returns` resources

### v0.11.0 — Workflow: Approvals & Preset Tasks

- [ ] `Approvals` resource (`all`, `find`, `create`)
- [ ] `PresetTaskGroups` resource (`all`, `find`, `create`, `update`)

### v0.12.0 — Files, Media & Communication

- [ ] `ProductionFiles` resource (`all`, `find`, `create`)
- [ ] `Mockups` resource (`all`, `find`, `create`)
- [ ] `EmailTemplates` resource (`all`, `find`)

### v0.13.0 — People, Orgs & Reference Data

- [ ] `Users` resource (`all`, `find`)
- [ ] `Vendors` resource (`all`, `find`, `create`, `update`)
- [ ] `ContractorProfiles` resource (`all`, `find`)
- [ ] `DeliveryMethods` resource (`all`) — reference data
- [ ] `TypesOfWork` resource (`all`) — reference data

### v0.14.0 — Retry / Backoff & CLI

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
