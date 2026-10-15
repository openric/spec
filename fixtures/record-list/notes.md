# Fixture: `record-list`

**Source:** [`https://heratio.theahg.co.za/api/ric/v1/records?limit=3`](https://heratio.theahg.co.za/api/ric/v1/records?limit=3)

A paginated openricx:RecordList in the Core Discovery 0.4.0 envelope (openric:total, page, limit, next, prev, items), with the deprecated ric:* aliases still present. Exercises: list schema, @type pattern for list responses. Recaptured from the reference service 2026-10-15 (service v0.17.6).

**Validation:** `expected.jsonld` MUST validate against the schema selected by its `@type`.
