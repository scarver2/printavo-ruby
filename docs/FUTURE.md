<!-- docs/FUTURE.md -->
# Future Roadmap for [printavo-ruby](https://github.com/scarver2/printavo-ruby)

Ideas and planned features for `printavo-ruby` that are out of scope for the
initial `0.x` releases. Contributions and discussions welcome!

## Planned Features

### Client-Side Aggregation Helpers

Printavo's V2 GraphQL API is a transactional API — it has no pre-aggregated
analytics or reporting endpoints. Any analytics must be computed by paging
through existing resources in Ruby.

Potential helpers that would add value:

```ruby
# Revenue across all invoices in a date range
client.invoices.revenue_summary(after: "2026-01-01")
# => { total: "142300.00", count: 87, average: "1636.78" }

# Order counts grouped by status
client.orders.status_breakdown
# => { in_production: 12, approved: 5, completed: 230, ... }

# Most active customers by order count
client.customers.top(limit: 10, by: :order_count)

# Average turnaround time (created_at → updated_at) per status
client.orders.avg_turnaround
```

These helpers would page all relevant records locally and compute aggregates
in Ruby. Because they require full pagination, using the built-in cache adapter
is strongly recommended before implementing these in production workflows.

See [CACHING.md](CACHING.md) for caching options.

### Schema-Derived Developer Experience

Borrow the strongest ideas from
[laravel-printavo](https://github.com/brandonjjon/laravel-printavo) without its
Laravel facade or global configuration model:

- generate discoverable Ruby enum modules and RBS signatures from a reviewed
  Printavo schema snapshot;
- provide typed field-selection objects for advanced GraphQL callers;
- expose documented filter methods instead of requiring callers to know raw
  GraphQL input names; and
- keep caching configurable through the existing per-client adapter.

Generated artifacts must be reviewable, reproducible, and traceable to an
official Printavo schema. They must not turn third-party guesses into SDK
contracts.

### Resumable Export Tooling

Evaluate a separate `printavo-export` executable or opt-in resumable enumerator
layer inspired by
[printavo-exporter](https://github.com/lamb92009/printavo-exporter):

- checkpointed cursor progress and safe resume;
- streaming NDJSON output rather than retaining whole accounts in memory;
- manifests with record counts, hashes, schema metadata, and reconciliation;
- schema introspection captured separately from customer data; and
- a read-only execution mode that rejects mutation documents.

File downloads should be optional and should account for expiring artwork URLs,
as demonstrated by
[printavo-backup](https://github.com/hypnotizedent/printavo-backup). Export data,
manifests, and downloaded artwork are sensitive operational artifacts and need
explicit storage, retention, and encryption guidance.

### Complexity-Aware Query Composition

Large order reads should be composable into smaller selections and resumable
follow-up queries instead of relying on one maximal document. A future query
planner could estimate selection depth and complexity, split high-cost order
reads, and retry only the failed segment.

The SDK does **not** currently impose client-side limits. Provider guidance has
described 10 requests per five seconds, maximum complexity of 25,000, and depth
13, but hard-coded enforcement would create an unnecessary compatibility gate
if those values change or differ by account. Any future limiter should be
opt-in, respond to authoritative provider errors or metadata, permit custom
budgets, and document exactly when it delays or rejects work.

### Read-Only Business Tools

The read-only production schedules, revenue summaries, and customer-spend
tools in
[printavo-mcp-server](https://github.com/watson-pierbras/printavo-mcp-server)
reinforce the aggregation helpers above. Build these first as ordinary Ruby
services over the public SDK so CLI, MCP, and application adapters can share
one implementation.

### Contract Research Sources

[API Evangelist's Printavo inventory](https://github.com/api-evangelist/printavo)
is useful for discovering possible operations and machine-readable gaps, but
it is third-party and partly modeled. It may seed research, never establish a
public contract. Confirm behavior against
[Printavo's official GraphQL reference](https://www.printavo.com/docs/api/v2/)
or sanitized live contract tests before implementation.

Printavo's
[activemerchant_payrix](https://github.com/Printavo/activemerchant_payrix)
repository is relevant to payment-gateway integration but currently offers no
direct architectural guidance for this API SDK.

## Visualization

See **[docs/VISUALIZATION.md](VISUALIZATION.md)** for workflow diagram generation —
Mermaid, DOT, ASCII, and SVG output via the standalone example script.

## Multi-Language SDK Family

`printavo-ruby` is the first gem in a planned multi-language SDK family:

| Repo | Language | Status |
|---|---|---|
| `printavo-ruby` | Ruby | Active |
| `printavo-python` | Python | Planned |
| `printavo-swift` | Swift | Planned |
| `printavo-zig` | Zig | Planned |
| `printavo-odin` | Odin | Planned |

---

## Colophon

[MIT License](LICENSE)

&copy;2026 [Stan Carver II](https://stancarver.com)

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
