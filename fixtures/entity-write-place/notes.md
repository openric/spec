# Fixture — entity-write-place

**Endpoint:** `POST /api/ric/v1/places`
**Request schema:** [entity-write.schema.json](../../schemas/entity-write.schema.json)  *(`$defs/place`)*
**Response schema:** [write-response.schema.json](../../schemas/write-response.schema.json)  *(`$defs/create`)*

Headers required:

```
Content-Type: application/json
Accept: application/json
X-API-Key: <key with "write" scope>
```

`request.json` is the POST body. `expected.jsonld` is the 201 Created response.

Demonstrates:
- Minimal-field create (name + coords + authority URI) — all other fields optional.
- Server-assigned `id`, `slug` (derived from name), and `href` for retrieval.
- `type` in the response is the singular form (`place`, not `places`).

A `PATCH /places/{id}` with a partial body updates only the given fields. `DELETE /places/{id}` returns `{success: true, id}` ([write-response.schema.json](../../schemas/write-response.schema.json) `$defs/success`).
