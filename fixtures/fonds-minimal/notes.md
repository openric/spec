# Fixture: `fonds-minimal`

**Purpose:** The smallest possible valid OpenRiC record — a fonds with a title and one creator, nothing else.

**Exercises:**
- Level `fonds` → `rico:RecordSet` class mapping ([mapping.md §6.1](../../spec/mapping.html#6-class-mapping))
- Actor type `person` → `rico:Person` ([mapping.md §6.2](../../spec/mapping.html#62-actor--ricoagent-hierarchy))
- Event type `creation` → `rico:hasCreator` edge (rather than a full `rico:Production` event, which is tested in `event-production`)
- Language-tagged `rico:title` via `@value` / `@language`
- Minimum required fields only — nothing optional

**Does not exercise:**
- Date ranges (see `fonds-with-series`)
- Multilingual titles (see `fonds-multilingual`)
- Holding repository (see `repository-with-holdings`)
- Subject access points (see `fonds-with-series`)
- Security or personal-data flags (see dedicated fixtures)

**Validation:**
- `expected.jsonld` MUST validate against `schemas/record.schema.json`
- `expected.jsonld` MUST conform to `shapes/openric.shacl.ttl` `:RecordSetShape`
- Round-trip: feeding `input.json` through a conformant mapping implementation MUST yield a graph isomorphic to `expected.jsonld`
