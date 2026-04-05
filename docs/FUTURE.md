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

See [docs/CACHING.md](docs/CACHING.md) for caching options.

## Visualization

### Workflow Diagram Generation (SVG/PNG)

Generate a visual map of a shop's Printavo status workflow:

```ruby
client.workflow.diagram(format: :svg)
# => Outputs an SVG flowchart: Quote → Approved → In Production → Completed
```

Implementation options:
- [ruby-graphviz](https://github.com/glejeune/Ruby-Graphviz) — DOT → SVG/PNG
- Pure Ruby → Mermaid output (copy-paste into docs or GitHub markdown)

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
