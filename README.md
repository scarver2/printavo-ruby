<!-- README.md -->
# printavo-ruby

[![CI](https://github.com/scarver2/printavo-ruby/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/scarver2/printavo-ruby/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/scarver2/printavo-ruby/badge.svg?branch=master)](https://coveralls.io/github/scarver2/printavo-ruby?branch=master)
[![Gem Version](https://badge.fury.io/rb/printavo-ruby.svg)](https://badge.fury.io/rb/printavo-ruby)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A framework-agnostic Ruby SDK for the [Printavo](https://www.printavo.com) GraphQL API (v2).

> I use Printavo every day at [Texas Embroidery Ranch](https://texasembroideryranch.com). This gem was created to bridge Printavo
> with other operational systems—CRM, marketing, finance, and automation—so that print shops
> can build integrated workflows without writing raw GraphQL by hand.

## Features

- Full [Printavo v2 GraphQL API](https://www.printavo.com/docs/api/v2) support
- Resource-oriented interface: `client.customers.all`, `client.orders.find(id)`
- Raw GraphQL access: `client.graphql.query("{ ... }")`
- Rich domain models: `order.status`, `order.status?(:in_production)`, `order.customer`
- Rack-compatible webhook signature verification
- Multi-client support — no globals required
- Ruby 3.0+ required

## Installation

Add to your Gemfile:

```ruby
gem "printavo-ruby"
```
or

```bash
bundle add printavo-ruby
```

or install directly:

```bash
gem install printavo-ruby
```

## Authentication

Printavo authenticates via your account **email** and **API token**
(found at My Account → API Token on [printavo.com](https://www.printavo.com)).

```ruby
require "printavo"

client = Printavo::Client.new(
  email: ENV["PRINTAVO_EMAIL"],
  token: ENV["PRINTAVO_TOKEN"]
)
```

### Rails Initializer

```ruby
# config/initializers/printavo.rb
PRINTAVO = Printavo::Client.new(
  email: ENV["PRINTAVO_EMAIL"],
  token: ENV["PRINTAVO_TOKEN"]
)
```

## Usage

### Customers

```ruby
# List customers (25 per page by default)
customers = client.customers.all
customers.each { |c| puts "#{c.full_name} — #{c.email}" }

# Paginate
page_2 = client.customers.all(first: 25, after: cursor)

# Find a specific customer
customer = client.customers.find("12345")
puts customer.full_name   # => "Jane Smith"
puts customer.company     # => "Acme Shirts"
```

### Orders

```ruby
# List orders
orders = client.orders.all
orders.each { |o| puts "#{o.nickname}: #{o.status}" }

# Find an order
order = client.orders.find("99")
puts order.status                    # => "In Production"
puts order.status_key                # => :in_production
puts order.status?(:in_production)   # => true
puts order.total_price               # => "1250.00"
puts order.customer.full_name        # => "Bob Johnson"
```

### Jobs (Line Items)

```ruby
# List jobs for an order
jobs = client.jobs.all(order_id: "99")
jobs.each { |j| puts "#{j.name} x#{j.quantity} @ #{j.price}" }

# Find a specific job
job = client.jobs.find("77")
puts job.taxable?   # => true
```

### Raw GraphQL

For queries not yet wrapped by a resource, use the raw GraphQL client directly:

```ruby
result = client.graphql.query(<<~GQL)
  {
    customers(first: 5) {
      nodes {
        id
        firstName
        lastName
      }
    }
  }
GQL

result["customers"]["nodes"].each { |c| puts c["firstName"] }
```

With variables:

```ruby
result = client.graphql.query(
  "query Customer($id: ID!) { customer(id: $id) { id email } }",
  variables: { id: "42" }
)
```

## Webhooks

`Printavo::Webhooks.verify` provides Rack-compatible HMAC-SHA256 signature verification.
No extra dependencies required.

```ruby
# Pure Ruby / Rack
valid = Printavo::Webhooks.verify(
  signature,  # X-Printavo-Signature header value
  payload,    # raw request body string
  secret      # your webhook secret
)
```

### Rails Controller Example

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def printavo
    if Printavo::Webhooks.verify(
         request.headers["X-Printavo-Signature"],
         request.raw_post,
         ENV["PRINTAVO_WEBHOOK_SECRET"]
       )
      event = JSON.parse(request.raw_post)
      # process event["type"] ...
      head :ok
    else
      head :unauthorized
    end
  end
end
```

## Error Handling

```ruby
begin
  client.orders.find("not_a_real_id")
rescue Printavo::AuthenticationError => e
  # Bad email/token
rescue Printavo::RateLimitError => e
  # Exceeded 10 req/5 sec — back off and retry
rescue Printavo::NotFoundError => e
  # Resource doesn't exist
rescue Printavo::ApiError => e
  # GraphQL error — e.message contains details, e.response has raw data
rescue Printavo::Error => e
  # Catch-all for any Printavo error
end
```

## Versioning Roadmap

| Version | Milestone |
|---|---|
| 0.1.0 | Auth + Customers + Orders + Jobs |
| 0.2.0 | Status registry + Analytics/Reporting |
| 0.3.0 | Webhooks (Rack-compatible) |
| 0.4.0 | Expanded GraphQL DSL |
| 0.5.0 | Mutations (create/update) |
| 0.6.0 | Community burn-in / API stabilization |
| 0.7.0 | Pagination abstraction helpers |
| 0.8.0 | Retry/backoff + rate limit awareness |
| 0.9.0 | Community feedback + API freeze |
| 1.0.0 | Stable public SDK |

**Rules**: `PATCH` = bug fix · `MINOR` = new backward-compatible feature · `MAJOR` = breaking change

## API Documentation

- [Printavo v2 API Reference](https://www.printavo.com/docs/api/v2)
- [Printavo GraphQL API Blog Post](https://www.printavo.com/blog/new-graphql-api/)

## Development

```bash
git clone https://github.com/scarver2/printavo-ruby.git
cd printavo-ruby
bundle install

# Run specs
bundle exec rspec

# Lint
bundle exec rubocop

# Guard DX (watches files, re-runs tests + lint on save)
bundle exec guard

# Interactive console
PRINTAVO_EMAIL=you@example.com PRINTAVO_TOKEN=your_token bin/console
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for full contribution guidelines.

## License

[MIT](LICENSE) © Stan Carver II

## Colophon

&copy;2026 [Stan Carver II](https://stancarver.com)

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
