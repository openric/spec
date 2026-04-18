# Fixture — autocomplete-egypt

**Endpoint:** `GET /api/ric/v1/autocomplete?q=egypt&limit=5`
**Schema:** [autocomplete.schema.json](../../schemas/autocomplete.schema.json)

Source query: `?q=egypt`, no `types` filter, `limit=5`.

Demonstrates:
- Flat array shape (no pagination wrapper — capped at `limit`).
- Heterogeneous results — Place, Record, Rule in the same response.
- `type` is the short class name (capitalised), not `rico:*`.
- `id` is an integer for the live reference server; MAY be a canonical URI for servers that use URI keys natively.
