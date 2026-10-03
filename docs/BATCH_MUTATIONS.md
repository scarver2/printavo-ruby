<!-- docs/BATCH_MUTATIONS.md -->
# Batch Mutations

The SDK exposes Printavo's documented batch mutation surface through the same
resource that owns each single-record operation.

| Resource | Create | Update | Delete | Mockup create |
|---|---|---|---|---|
| `client.custom_addresses` | `creates(inputs)` | `updates(inputs)` | `deletes(ids)` | — |
| `client.fees` | `creates(inputs)` | `updates(inputs)` | `deletes(ids)` | — |
| `client.imprints` | `creates(inputs)` | `updates(inputs)` | `deletes(ids)` | `mockup_creates(inputs)` |
| `client.line_item_groups` | `creates(inputs)` | `updates(inputs)` | `deletes(ids)` | — |
| `client.line_items` | `creates(inputs)` | `updates(inputs)` | `deletes(ids)` | `mockup_creates(inputs)` |
| `client.mockups` | — | — | `deletes(ids)` | — |
| `client.production_files` | `creates(inputs)` | — | `deletes(ids)` | — |

Each input hash may use Ruby-style `snake_case` keys; the resource translates
them to GraphQL `camelCase`. These calls use Printavo's operation-specific
input objects, such as `LineItemCreatesInput` and `FeeUpdatesInput`, rather
than treating a batch as an array of single-operation inputs.

Mockup creation belongs to the parent imprint or line item in Printavo's
schema. Standalone mockups therefore expose batch deletion only.

Single creates keep Printavo's required parent IDs separate from their input:

```ruby
client.line_item_groups.create(parent_id: quote.id, position: 0)
client.line_items.create(line_item_group_id: group.id, description: "Core Cotton Tee", position: 0)
```

Provider reference: [Printavo GraphQL mutations](https://www.printavo.com/docs/api/v2/operation/mutation/).

—
Stan Carver II
Made in Texas 🤠
https://stancarver.com
