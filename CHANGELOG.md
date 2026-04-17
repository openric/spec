# OpenRiC Specification — Changelog

## v0.1.0 — 2026-04-17 *(first frozen draft)*

First frozen release of OpenRiC. The specification is **draft-stable**: implementations can now claim conformance against a specific version. Breaking changes are allowed in v0.2.x in response to external review, but any such change will bump the minor version.

### Four specification documents

Published at **[openric.org](https://openric.org)**:

- **[Mapping Specification](https://openric.org/spec/mapping.html)** — how archival descriptions (ISAD(G), ISAAR(CPF), ISDIAH) map to RiC-CM / RiC-O. Complete class and property tables.
- **[Viewing API](https://openric.org/spec/viewing-api.html)** — REST + JSON-LD contract for serving RiC data. 10 endpoints defined.
- **[Graph Primitives](https://openric.org/spec/graph-primitives.html)** — abstract viewing model with five primitives (Subgraph, Node, Edge, Cluster, LayoutHint) and six invariants.
- **[Conformance](https://openric.org/spec/conformance.html)** — four levels (L1–L4), SHACL shapes, JSON Schemas, fixture pack, validator CLI.

### Machine-checkable artifacts

- **12 JSON Schemas** (Draft 2020-12) — record, agent, repository, place, instantiation, activity, rule, subgraph, vocabulary, error, list, service-description.
- **2 SHACL shape files** — `openric.shacl.ttl` (single-document validation; 254 triples) and `full-graph.shacl.ttl` (triple-store-wide checks; 31 triples).
- **20 canonical fixtures** covering every supported entity type, list responses, multilingual content, subgraph depth 1 & 2, error responses, and service-description.
- **`openric-validate` CLI** — Python 3.11+, installable via `pip install -e ./validator` or eventually `pipx install openric-validate`. Runs JSON Schema validation + SHACL shape validation + graph invariant checks.

### Reference implementation

**[Heratio](https://github.com/ArchiveHeritageGroup/heratio)** is the first reference implementation and live-validated against these artifacts. Eight endpoint types pass schema + shape validation:

- `/records/{slug}` — fonds, series, files, items
- `/agents/{slug}` — Person, CorporateBody, Family
- `/repositories/{slug}` — ISDIAH repositories
- `/places/{id}` — RiC-native Places with coordinates + authority URIs
- `/instantiations/{id}` — digital/physical manifestations
- `/activities/{id}` — Production / Accumulation / Activity
- `/rules/{id}` — mandates, laws, policies
- `/graph?uri=…&depth=N` — full OpenRiC Subgraph envelope

All graph edges emit canonical `rico:*` predicates; 2,000+ RiC entities are currently served.

### Licensing

- Specification (mapping / viewing-api / graph-primitives / conformance, schemas, SHACL shapes, fixtures): **CC-BY 4.0**
- Validator CLI (`validator/`): **AGPL-3.0-or-later**

### CI

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push and PR:

1. Validator unit + fixture tests (pytest)
2. JSON Schema 2020-12 well-formedness
3. SHACL Turtle parse check
4. Markdown internal-link check

### Contributors

- **Johan Pieterse** (Plain Sailing Information Systems, The Archive and Heritage Group) — spec drafting, reference implementation, validator
- **Richard** — IIIF-analogy feedback that reframed OpenRiC from product feature to neutral specification

### What's next (roadmap for v0.2.x)

- External review from EGAD-adjacent spec editors
- At least one non-Heratio reference implementation
- `@openric/viewer` npm package extraction
- OpenRiC-Rights (ODRL-backed rights enforcement) — separate spec
- OpenRiC-Preservation (PREMIS-equivalent event vocabulary) — separate spec
- L4 full conformance testing with round-trip preservation

---

*v0.1.0 is a draft freeze. If you plan to implement against it, please [open an issue on GitHub](https://github.com/ArchiveHeritageGroup/openric-spec/issues) so we know who's implementing and can coordinate breaking changes in v0.2.x.*
