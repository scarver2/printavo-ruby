<!-- docs/LIVE_TESTING.md -->
# Live Contract Testing

`bin/live-contract` verifies the SDK's newest GraphQL surface against the live
Printavo schema:

```bash
PRINTAVO_EMAIL="..." PRINTAVO_TOKEN="..." bin/live-contract
```

Use a dedicated A1Web demo account. Never use Texas Embroidery Ranch production
credentials or customer data for development testing.

The command sends exactly one read-only introspection request. It verifies:

- `quote`, `quotes`, `lineItemGroupPricing`, and `transactionDetail` queries;
- query and mutation argument types, including required parent IDs;
- the Quote timestamp shape and fields selected by direct queries;
- documented batch mutation names and operation-specific input types;
- richer `LineItem` fields; and
- payment-ledger members of `TransactionUnion`.

It neither reads business records nor performs mutations, retries, pagination,
or VCR recording. It prints operation/type names only and never prints
credentials or provider response bodies.

This check deliberately does not impose a client-side request, complexity, or
depth limit. Its single bounded request is safe by construction. General SDK
limit handling remains an opt-in roadmap item until Printavo exposes stable,
authoritative limit metadata or errors suitable for adaptive behavior.

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
