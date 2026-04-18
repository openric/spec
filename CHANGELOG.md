# OpenRiC Specification — Changelog

## Unreleased

### Browse demo

- **[openric.org/demo/browse/](demo/browse/)** — responsive card-grid browse over any OpenRiC-conformant server. Per-type filter tabs (Records / Agents / Places / Rules / Activities / Instantiations / Repositories / Functions), pagination, click-through to the 2D/3D viewer, `openric-demo` callouts when a seeded fonds is present. Pure browser, no build step.

### Reference-server additions post-v0.2.0

- **Repository + Function write endpoints.** Full CRUD on all eight RiC entity classes now. 46 paths in `openapi.json`.
- **`openric:rebuild-nested-set`** Artisan command with `--verify` and `--dry-run` — rebuilds information_object MPTT `lft/rgt` after bulk imports.
- **`openric:seed-demo`** Artisan command — creates a coherent mini-fonds (Repository + Agent + Place + Activity + Rule + Function + 3 Records + Instantiation + 11 relations) so the browse demo has a curated narrative. Idempotent; `--drop` removes.
- **SPARQL marked experimental** in §4.8 of the Viewing API spec. The endpoint remains a stub; clients should use `/graph?uri=…&depth=N` for traversal.
- **Conformance probe** now supports `READ_KEY=` for scope-enforcement checks (asserts a read-only key gets 403 on write routes).

## v0.2.0 — 2026-04-18

Second freeze of the OpenRiC specification. All changes below are live on the reference infrastructure at ric.theahg.co.za and have been verified with the conformance probe.

### New public surfaces

- **[capture.openric.org](https://capture.openric.org)** — pure-browser data-entry client (`github.com/openric/capture`, AGPL-3.0). Paste a server URL + API key, create Places, Rules, Activities, Instantiations, and relations against any OpenRiC-conformant backend. Mirror of the viewer's decoupling story on the capture side.
- **[ric.theahg.co.za/api/ric/v1](https://ric.theahg.co.za/api/ric/v1/health)** — the reference API moved to its own deployment. Heratio stopped serving `/api/ric/v1/*` and is now a client of this endpoint over HTTP, same surface any third-party client uses. No privileged shortcut.

### Specification additions (pending a `v0.2.0` freeze)

The following endpoints were added to the Viewing API document (`§4.11–4.18`). They are live on the reference deployment but not yet part of a frozen tag:

**Read-side (no new auth required):**
- `GET /places`, `/places/{id}`, `/places/flat?exclude_id=` — RiC-native Places with list + show + picker helper.
- `GET /rules`, `/rules/{id}` — RiC-native Rules.
- `GET /activities`, `/activities/{id}` — RiC-native Activities.
- `GET /instantiations`, `/instantiations/{id}` — RiC-native Instantiations.
- `GET /relations` — paginated global list; `GET /relations-for/{id}` — relations for one entity grouped by direction; `GET /relation-types` — filtered relation predicate catalog.
- `GET /hierarchy/{entity-id}?include=parent,children,siblings` — hierarchy walk.
- `GET /autocomplete?q=&types=&limit=` — cross-entity label search.
- `GET /vocabulary/{taxonomy}` — single-taxonomy detail (complements the all-taxonomies catalog at `/vocabulary`).
- `GET /records/{id}/entities?types=` — linked RiC entities aggregate for one record.
- `GET /entities/{id}/info` — minimal info card for popovers.

**Write-side (new — requires `X-API-Key` + `write` / `delete` scopes):**
- `POST /{type}`, `PATCH /{type}/{id}`, `DELETE /{type}/{id}` for `{type} ∈ places|rules|activities|instantiations`.
- `POST /agents`, `PATCH /agents/{id}`, `DELETE /agents/{id}` — rico:Agent / Person / CorporateBody / Family (ISAAR-CPF).
- `POST /records`, `PATCH /records/{id}`, `DELETE /records/{id}` — rico:Record / RecordSet (ISAD).
- `POST /relations`, `PATCH /relations/{id}`, `DELETE /relations/{id}`.
- `POST /upload` — multipart file upload; returns `{id, url, mime, size, filename}` with a publicly-fetchable URL under `/uploads/`.
- `DELETE /entities/{id}` — type-agnostic delete-by-id for UIs that hold an id without a type.

### Harvesting — OAI-PMH v2.0

- `GET /oai?verb=...` — standard OAI-PMH endpoint over `information_object` records.
- Six verbs: `Identify`, `ListMetadataFormats`, `ListSets`, `ListIdentifiers`, `ListRecords`, `GetRecord`.
- Two metadata prefixes: `oai_dc` (Dublin Core — title/identifier/description/date/type) and `rico_ld` (RiC-O JSON-LD wrapped in CDATA for harvesters that want the full graph).
- Sets are derived from the hierarchy: each top-level (`parent_id IS NULL`) record becomes a `fonds:N` set.
- Resumption tokens are opaque base64(JSON) and carry the prefix, offset, set, from, until filters.

### Conformance suite

- `conformance/probe.sh` — black-box probe that hits every documented endpoint and verifies shape via `jq`. Takes a `BASE` env var for any OpenRiC-conformant server. Optional `KEY` enables write-side probes. Exits non-zero if any required endpoint fails.
- `conformance/README.md` — what it does and how to run it in CI.
- `conformance/.github-workflows-conformance.yml` — copy-paste GitHub Actions workflow for weekly + push-triggered conformance runs.

### API Explorer

- **[openric.org/api-explorer/](https://openric.org/api-explorer/)** — interactive Swagger UI page. Point it at any OpenRiC server (default: reference). Loads the server's `/openapi.json`, renders all ~40 endpoints grouped by tag, and lets you "Try it out" with your own API key (key stays in localStorage, never leaves your browser).
- **`GET /api/ric/v1/openapi.json`** — every OpenRiC server now ships a live OpenAPI 3.0 spec with full request/response schemas for Agents, Records, Places, Rules, Activities, Instantiations, Relations, Graph, SPARQL, Uploads, OAI-PMH, and Validation. Previously this endpoint returned an empty stub.
- **`GET /api/ric/v1/docs`** — per-server embedded Swagger UI. Bookmark this on your own deployment for the canonical test console.

### Graph endpoint additions

- `/graph?uri=/default/term/{id}` and `/default/thing/{id}`, `/default/concept/{id}`, `/default/subject/{id}` — the subgraph root dispatcher now recognises Term/Thing/Concept/Subject entity URIs, so clicking a subject node in the viewer drills into the records tagged with it. `rico:hasBroaderConcept` + `rico:hasSubject` edges.

### Auth

§6 of the Viewing API spec is revised. Reads stay public by default; writes require an API key with an appropriate scope. Three scopes defined: `write`, `delete`, and implicit `read`. `401` on missing key, `403` on missing scope.

### CORS

§5.3 extended: write endpoints MUST handle the `OPTIONS` preflight and return the standard CORS headers. Without this, browser-based capture clients can't write.

### Tooling

- `@openric/viewer@0.1.1` — fixes `fetchSubgraph` to accept relative server bases. Adds rich hover tooltip (RiC-O type, full URI, per-node extras). Published on npm.
- Reference deployment runbook ([`ric-split-runbook.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-split-runbook.md)) + collapse plan ([`ric-split-collapse-plan.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-split-collapse-plan.md)) published in the Heratio repository. They're the implementation playbook for anyone wanting to reproduce the "reference impl is a consumer of its own API" topology.

### Fixtures / validator

No changes yet — the 20-case fixture pack and the validator CLI still target v0.1.0 endpoint shapes. Adding fixtures for the new read endpoints + the write surface is the blocker for a `v0.2.0` tag.

---

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

*v0.1.0 is a draft freeze. If you plan to implement against it, please [open an issue on GitHub](https://github.com/openric/spec/issues) so we know who's implementing and can coordinate breaking changes in v0.2.x.*
