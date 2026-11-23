# Fixture — activity-custody

**Profile:** `provenance-event`
**Endpoint:** `GET /api/ric/v1/activities/{id}` on a custody-transfer event
**Shape:** `:StrictActivityShape` in [shapes/profiles/provenance-event.shacl.ttl](../../shapes/profiles/provenance-event.shacl.ttl)

Pins the **generic-fallback** Activity pattern: the event type isn't a creation (`rico:Activity`) or aggregation (`rico:Activity`), so it falls through to the base `rico:Activity` class per `spec/mapping.md` §6.5. Custody transfers, publications, reproductions all land here.

Key differences from `:StrictProductionShape`:

- `rico:resultsOrResultedIn` is NOT required — a custody transfer moves an existing record, it doesn't produce one. A conformant custody event MAY still carry this predicate to link to the record being moved, but its absence is not a Violation.
- `rico:hasOrHadParticipant` is NOT required — many historical custody events have anonymous or unknown actors.
- `rico:isAssociatedWithDate` IS required (Violation) — an event without a date is effectively unplottable in a provenance timeline.
- `rico:hasActivityType` is RECOMMENDED (Warning) — lets consumers dispatch on `custody` / `publication` / `reproduction` without parsing free text.

When present, cross-entity link targets still validate against `:ParticipantTypeShape` (must be an Agent) and any `:ResultTypeShape` (must be a Record / RecordSet / RecordPart / Instantiation). Implementations that attach Places to activities use `rico:hasOrHadLocation`, as shown here — it is NOT constrained by a target-type shape in this profile because RiC-O's range for that predicate is already `rico:Place`.
