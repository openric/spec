# Fixture — entity-info-place

**Endpoint:** `GET /api/ric/v1/entities/912150/info`
**Schema:** [entity-info.schema.json](../../schemas/entity-info.schema.json)

Deliberately minimal — `{id, class, slug, name, type, description}`. Intended for popovers, hover tooltips, and autocomplete result expansion. Cheap to fetch; no relations, no fields beyond identification + a human-readable summary.

The full entity document is at `/api/ric/v1/places/{id}` — use that when you need coordinates, authority URIs, parent-place, etc.
