<!-- docs/CACHING.md -->
# Caching Strategies for [printavo-ruby](https://github.com/scarver2/printavo-ruby)

The Printavo API enforces a **rate limit of 10 requests per 5 seconds** per account.
For applications that read Printavo data frequently (dashboards, reporting tools,
CRM syncs), caching is essential to stay within this limit and reduce latency.

This guide covers practical caching patterns, from zero-dependency Ruby to
Redis and Rails.cache, along with recommended TTLs for each resource type.

---

## Why Cache Printavo Responses?

| Factor | Detail |
|---|---|
| Rate limit | 10 req / 5 sec per account |
| Data volatility | Customers and statuses rarely change; orders change moderately |
| Use case | Dashboards, CRM syncs, and reporting hammer read endpoints repeatedly |
| Cost | Fewer API calls = faster responses + less risk of throttling |

---

## Strategy 1: In-Memory Caching (Zero Dependencies)

Best for: **scripts, background jobs, single-request data batches**

A plain Ruby hash is enough when you only need to deduplicate calls
within a single process run:

```ruby
customer_cache = {}

def fetch_customer(client, id, cache)
  cache[id] ||= client.customers.find(id)
end

order = client.orders.find("99")
customer = fetch_customer(client, order.customer.id, customer_cache)
```

> Note: In-memory caches are cleared on process restart and are not shared
> across processes or threads (without synchronization).

---

## Strategy 2: Status Registry Caching

Best for: **status-heavy workflows**

Printavo statuses are user-defined and rarely change. Cache them once at
startup to avoid repeated API calls when checking `order.status?`:

```ruby
# Fetch all statuses once and freeze them
raw = client.graphql.query(<<~GQL)
  {
    statuses {
      nodes { id name }
    }
  }
GQL

STATUS_REGISTRY = raw["statuses"]["nodes"].freeze
# => [{"id"=>"1", "name"=>"Quote"}, {"id"=>"2", "name"=>"In Production"}, ...]
```

This pairs well with `Printavo::Order#status_key` for symbol-based lookups.

---

## Strategy 3: Rails.cache Integration

Best for: **Rails applications** (recommended default)

Wrap any Printavo call in `Rails.cache.fetch` to use whatever cache store
your app already has configured (Redis, Memcache, memory, etc.):

```ruby
# config/initializers/printavo.rb
PRINTAVO = Printavo::Client.new(
  email: ENV["PRINTAVO_EMAIL"],
  token: ENV["PRINTAVO_TOKEN"]
)
```

```ruby
# In a service, controller, or job:
def customers
  Rails.cache.fetch("printavo:customers", expires_in: 10.minutes) do
    PRINTAVO.customers.all
  end
end

def order(id)
  Rails.cache.fetch("printavo:order:#{id}", expires_in: 2.minutes) do
    PRINTAVO.orders.find(id)
  end
end
```

> Use namespaced cache keys (`printavo:resource:id`) to make invalidation
> easier and to avoid collisions with other app cache entries.

---

## Strategy 4: Redis (Framework-Agnostic)

Best for: **non-Rails Ruby applications** that need a shared, persistent cache

```ruby
require "redis"
require "json"

REDIS = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379"))
PRINTAVO_CLIENT = Printavo::Client.new(
  email: ENV["PRINTAVO_EMAIL"],
  token: ENV["PRINTAVO_TOKEN"]
)

def cached_customer(id, ttl: 600)
  key  = "printavo:customer:#{id}"
  data = REDIS.get(key)

  if data
    Printavo::Customer.new(JSON.parse(data))
  else
    customer = PRINTAVO_CLIENT.customers.find(id)
    REDIS.setex(key, ttl, JSON.generate(customer.to_h))
    customer
  end
end
```

---

## Strategy 5: Webhook-Driven Cache Invalidation

Best for: **keeping cache fresh without polling**

When Printavo sends a webhook event (order updated, customer changed),
invalidate the specific cache entry immediately:

```ruby
# Rails controller
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def printavo
    unless Printavo::Webhooks.verify(
             request.headers["X-Printavo-Signature"],
             request.raw_post,
             ENV["PRINTAVO_WEBHOOK_SECRET"]
           )
      return head :unauthorized
    end

    event = JSON.parse(request.raw_post)
    invalidate_cache(event)
    head :ok
  end

  private

  def invalidate_cache(event)
    case event["type"]
    when "order.updated", "order.created"
      Rails.cache.delete("printavo:order:#{event.dig("data", "id")}")
    when "customer.updated"
      Rails.cache.delete("printavo:customer:#{event.dig("data", "id")}")
      Rails.cache.delete("printavo:customers")
    end
  end
end
```

This pattern gives you **real-time accuracy** with **minimal API calls**.

---

## Recommended TTLs

| Resource | Suggested TTL | Rationale |
|---|---|---|
| Customers (list) | 10 minutes | Changes infrequently |
| Customer (single) | 10 minutes | Same |
| Orders (list) | 2 minutes | Status changes often during production |
| Order (single) | 2 minutes | Same |
| Statuses/enums | 1 hour | Rarely changed by shop admins |
| Analytics/reports | 15 minutes | Acceptable staleness for reporting |

Adjust these TTLs based on your shop's actual order velocity and
how frequently staff update records.

---

## What NOT to Cache

| Item | Reason |
|---|---|
| API credentials | Managed by Printavo; don't duplicate |
| Full paginated collections | Cache individual pages by cursor key instead |
| Results immediately after a mutation | Always re-fetch after writes |
| Webhook payloads | Process once and discard |

---

## Future: Built-In Cache Adapter

A future version of `printavo-ruby` may support an optional cache adapter
passed directly to the client:

```ruby
# Possible future API — not implemented in v0.x
client = Printavo::Client.new(
  email: ENV["PRINTAVO_EMAIL"],
  token: ENV["PRINTAVO_TOKEN"],
  cache: Rails.cache,           # any object responding to fetch/delete
  default_ttl: 300
)

# Would cache automatically:
client.customers.all   # cached for 300s by default
client.orders.find(1)  # cached per-id
```

Track this feature in [FUTURE.md](../FUTURE.md).

---

## Colophon

[MIT License](LICENSE)

&copy;2026 [Stan Carver II](https://stancarver.com)

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
