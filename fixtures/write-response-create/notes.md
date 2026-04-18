# Fixture — write-response-create

**Endpoint:** Any `POST /api/ric/v1/{type}` that successfully created an entity.
**Schema:** [write-response.schema.json](../../schemas/write-response.schema.json)  *(`$defs/create`)*

Shown here for a Place create. The same shape applies to Rules, Activities, Instantiations, and Relations (with `type` adjusted to `rule`, `activity`, `instantiation`, or relations not setting `type`).

Status code is **201 Created**, not 200. Location header MAY also be set to the `href` value.

The sibling `$defs/success` shape (status 200) is returned by:

- `PATCH /{type}/{id}`
- `DELETE /{type}/{id}`
- `DELETE /entities/{id}`
- `POST /relations`
- `PATCH /relations/{id}`
- `DELETE /relations/{id}`

Example success body:

```json
{ "success": true, "id": 912401 }
```
