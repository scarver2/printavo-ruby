<!-- docs/FUTURE.md -->
# Future Roadmap

Ideas and planned features for `printavo-ruby` that are out of scope for the
initial `0.x` releases. Contributions and discussions welcome!

## Planned Features

### CLI (Thor-based)

A `printavo` command-line tool built with [Thor](https://github.com/rails/thor):

```bash
printavo customers
printavo orders
printavo orders find 12345
printavo analytics revenue
printavo sync orders --to crm
```

Planned version: `0.7.0`

### Pagination Abstraction

A lazy-enumerator-style helper to automatically page through all results:

```ruby
client.customers.each_page do |page|
  page.each { |c| process(c) }
end

# Or collect all:
all_orders = client.orders.all_pages
```

Planned version: `0.8.0`

### Retry/Backoff

Intelligent rate limit handling with exponential backoff:

```ruby
client = Printavo::Client.new(
  email: ENV["PRINTAVO_EMAIL"],
  token: ENV["PRINTAVO_TOKEN"],
  max_retries: 3,
  retry_on_rate_limit: true
)
```

Planned version: `0.9.0`

### Analytics / Reporting Expansion

Richer wrappers for Printavo's analytics queries (revenue, job counts,
customer activity, turnaround times).

Planned version: `0.6.0`

### Mutations (Create / Update)

Support for creating and updating resources:

```ruby
client.customers.create(first_name: "Jane", last_name: "Smith", email: "jane@example.com")
client.orders.update("99", nickname: "Rush Job")
```

Planned version: `0.5.0`

### Built-In Cache Adapter

Optional cache layer that plugs into any cache store:

```ruby
client = Printavo::Client.new(
  email: ENV["PRINTAVO_EMAIL"],
  token: ENV["PRINTAVO_TOKEN"],
  cache: Rails.cache  # or a Redis client, etc.
)
```

See [docs/CACHING.md](docs/CACHING.md) for current caching recommendations.

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

Stan Carver II
Made in Texas 🤠
https://stancarver.com
