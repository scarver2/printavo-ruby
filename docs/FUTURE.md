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

### Workflow Diagram Generation

See **[examples/diagramming/workflow_diagram.rb](../examples/diagramming/workflow_diagram.rb)**
for a complete, runnable example covering all four output formats.

Adding diagram generation to the gem itself would require either shipping
`ruby-graphviz` as a hard dependency or assuming a system `dot` binary —
both are burdensome for a Ruby API client. The standalone example gives
consumers full control over their output format and toolchain without
bloating the gem.

**Supported formats in the example:**

| Format | Dependency | Best for |
|---|---|---|
| `:ascii` | none | Terminal output, quick sanity-check |
| `:mermaid` | none | GitHub README/issues/PRs, VS Code preview |
| `:dot` | none (text) | Piping to `dot -Tsvg` or any Graphviz renderer |
| `:svg` | `brew install graphviz` or `gem install ruby-graphviz` | Production-grade visual files |

Statuses are fetched via `client.statuses.all` and rendered as a linear
left-to-right flow in the order Printavo returns them. Printavo has no
explicit transition edges in its API — the workflow is an implied sequence.

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
