# Fixture — relation-list

**Endpoint:** `GET /api/ric/v1/relations?per_page=2&page=1`
**Schema:** [relation-list.schema.json](../../schemas/relation-list.schema.json)

Global paginated browse over every relation in the triple store. Items are shown at their full metadata: subject + object + canonical predicate + optional dates + certainty + evidence.

The `pagination` block uses the same `{page, per_page, total, last_page}` shape all paginated responses converge on. Browsers and batch jobs both lean on `last_page` to know when to stop.

Filtering with `?q=some_term` matches against `rico_predicate`, `dropdown_code`, and `evidence` text.
