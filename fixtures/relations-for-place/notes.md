# Fixture — relations-for-place

**Endpoint:** `GET /api/ric/v1/relations-for/912150`  *(Egypt — Place)*
**Schema:** [relations-for.schema.json](../../schemas/relations-for.schema.json)

Demonstrates:
- Outgoing vs incoming split with a canonical RiC-O predicate per relation.
- Inverse predicates (`hasBroaderGeographicalContext` ↔ `hasNarrowerGeographicalContext`) populated from `ric_relation_meta`.
- Dated relations (the archaeological activity has start+end dates) alongside date-less ones (subject-of associations).
- Optional `certainty` + `evidence` per relation — used for assertions that aren't 100% verified.

Invariants:
- Sum of `|outgoing| + |incoming| == total`.
- Every relation has a `rico_predicate` (canonical) and a `target_id`.
- The subject entity (id `912150`) does NOT appear in the target lists.
