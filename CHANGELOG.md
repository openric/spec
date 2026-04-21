# OpenRiC Specification — Changelog

## v0.36.1 — 2026-04-21

### SPARQL positioned; triplestore-choice guide added

- `spec/viewing-api.md` §4.8 reframed from "experimental — deferred" to **"non-normative — outside the OpenRiC contract, by design"**. Implementations MAY expose a SPARQL endpoint at any implementation-specific path; the OpenRiC contract does not test it, clients should not assume its presence, and no profile can be satisfied by exposing only a SPARQL endpoint. Door is left open for a future `sparql-query` profile if concrete demand surfaces. For the common graph-walk case `/graph?uri=…&depth=N` remains the stable, SHACL-validated, bounded alternative.
- New guide: [`guides/triplestore-choice.md`](guides/triplestore-choice.html). Walks implementers through backing-store options — Apache Jena Fuseki (the reference choice), Oxigraph, GraphDB, Virtuoso Open Source, QLever, Blazegraph (now effectively unmaintained), Amazon Neptune. Scale bands (triple-count vs store), performance notes, when Fuseki gets slow and what to migrate to, dump/load migration recipe, and the reference deployment's actual numbers. Also listed on `guides/index.md`.

## v0.36.0 — 2026-04-21

### Export-Only profile — **profile matrix complete (7/7 normative)**

- **[Export-Only](spec/profiles/export-only.html)** (new, 259 lines). Mandates OAI-PMH v2.0 at `/oai` (six verbs; `oai_dc` + `rico_ld` prefixes, the latter carrying CDATA-wrapped RiC-O JSON-LD for full-semantics harvest) plus content-negotiated per-record dumps at `/records/{slug}/export` (JSON-LD default, Turtle and RDF-XML alternatives — lossless triple-set parity MUST hold across the three).
- `shapes/profiles/export-only.shacl.ttl` (new, thin — OAI-PMH XML validates against OAI-PMH.xsd, not SHACL). Covers only the JSON-LD dump envelope.
- 3 new fixtures: `oai-identify`, `oai-list-metadata-formats`, `record-export-jsonld` (43 total in manifest).
- All 5 design questions resolved on-page; Q1 (OAI-PMH mandatory) and Q2 (CDATA-JSON-LD vs bespoke RiC-XML namespace) are the consequential ones.
- Seven profiles are now normative: Core Discovery, Authority & Context, Graph Traversal, Digital Object Linkage, Round-Trip Editing, Provenance & Event, Export-Only. Subsequent path to v1.0 is governance-bound (second implementation, institution commitment, external contributors) rather than spec-drafting.

## v0.35.0 — 2026-04-21

### Provenance & Event profile + freeze-series renumber

- **[Provenance & Event](spec/profiles/provenance-event.html)** (new, 235 lines). Tightens Authority & Context's Activity shapes: `rico:Production` MUST carry `rico:resultsOrResultedIn` + `rico:hasOrHadParticipant` + `rico:isOrWasAssociatedWithDate` at Violation severity (was Warning); cross-entity link targets MUST be the correct RiC-O class via new `:ParticipantTypeShape` + `:ResultTypeShape`.
- `shapes/profiles/provenance-event.shacl.ttl` (new, 5 shapes). 2 new fixtures: `activity-production-full`, `activity-custody`.
- Q5 is the honest one: this is the first profile where the reference server's serializer didn't yet emit the required shape at freeze time. Gap closed in service v0.8.13; data backfill still pending for full conformance claim.
- **Renumber catch-up.** The freeze series was initially cut as v0.3.0 through v0.8.0, which silently collided with pre-freeze draft tags that already existed under those names. This release renumbers the series to continue the real tag history (v0.29.0 → v0.30.0 → … → v0.36.0). Profile versions (per-profile lifecycle, see core-discovery.md §10 Q8) remain independent of spec version.

## v0.34.0 — 2026-04-21

### Round-Trip Editing profile

- **[Round-Trip Editing](spec/profiles/round-trip-editing.html)** (new, 268 lines). Full write surface — POST / PATCH / DELETE on every RiC entity type + relations, gated by API-key scopes (`write`, `delete`), with a public per-entity audit trail at `GET /{type}/{id}/revisions`.
- `shapes/profiles/round-trip-editing.shacl.ttl` (new, 3 shapes focusing on the `openric:RevisionList` envelope — write/create/success envelopes are pure JSON, validated by JSON Schema at `/schemas/write-response.schema.json`, not SHACL). 2 new fixtures: `write-response-success`, `revision-list`.
- 6 design questions resolved: JSON (not JSON-LD) for the envelopes (Q1); optimistic concurrency deferred to v1+ (Q2); audit reads public with write-time redaction (Q3); deep pagination out of scope (Q4); coarse `write`/`delete` scopes only (Q5); PUT treated as PATCH alias to prevent data-loss-by-omission (Q6).

## v0.33.0 — 2026-04-21

### Digital Object Linkage profile

- **[Digital Object Linkage](spec/profiles/digital-object-linkage.html)** (new, 284 lines). Covers `rico:Instantiation` (MIME, checksums via `rico:technicalCharacteristics`, extent, record-backlinks) and `rico:Function` (ISDF business functions) as first-class entities. Optional `POST /upload` + `GET /thumbnail/{id}` endpoints are ergonomic extensions; not required for profile claim.
- Pre-existing `shapes/profiles/digital-object-linkage.shacl.ttl` (2 shapes: `:InstantiationShape`, `:FunctionShape`) now normative. 2 shipped fixtures: `instantiation-tiff`, `instantiation-application`.
- Q1 resolved the long-standing taxonomy question: `rico:Function` stays in Digital Object Linkage (historical grouping) rather than being re-homed to Authority & Context.

## v0.32.0 — 2026-04-21

### Graph Traversal profile + "six profiles" → "seven profiles" correction

- **[Graph Traversal](spec/profiles/graph-traversal.html)** (new, 296 lines). Normative spec for `/graph?uri=&depth=N` (returns `openric:Subgraph` per the Graph Primitives vocabulary), `/relations`, `/relations-for/{id}`, `/hierarchy/{id}`. Depth capped at 3 (Q1). Hierarchy + relations endpoints use REST-style `{data, pagination}` envelopes rather than JSON-LD (Q3) — mirrors IIIF Image API's split.
- Pre-existing `shapes/profiles/graph-traversal.shacl.ttl` (6 shapes, 2 property-shape + 4 SPARQL) now normative. Shipped fixtures: `subgraph-depth-1`, `subgraph-depth-2`, `hierarchy-with-children`, `relation-list`, `relations-for-place`.
- **Seven-profile-count correction.** `manifest.schema.json` has always declared 7 profile IDs, but several narrative docs said "six profiles". Fixed in `spec/profiles/index.md`, `profiles.md`, `faq.md` (×2), `data-management.md`, and `core-discovery.md`'s conformance-claim examples. Profile count is now consistent across the corpus.

## v0.31.0 — 2026-04-21

### Authority & Context profile

- **[Authority & Context](spec/profiles/authority-context.html)** (new, 298 lines). First-class `rico:Place`, `rico:Rule`, and `rico:Activity` (plus concrete subclasses `rico:Production`, `rico:Accumulation`) with reconciliation-friendly identifiers via `owl:sameAs`.
- Pre-existing `shapes/profiles/authority-context.shacl.ttl` (6 shapes) now normative. 6 shipped fixtures: `place-country`, `place-with-parent`, `place-list`, `rule-law`, `activity-production`, `activity-accumulation`.
- Orthogonal to Core Discovery. 4 design questions resolved: hierarchy shape via `rico:isOrWasPartOf` stubs (Q1); `owl:sameAs` SHOULD not MUST (Q3); Activity subclass selection mandatory when data supports it (Q4); rule-type vocabulary open with 5 conventional values RECOMMENDED (Q5).

## v0.30.0 — 2026-04-21

### Core Discovery profile — first normative freeze

- **[Core Discovery](spec/profiles/core-discovery.html)** flipped `Status: Draft — open for comment` → `Status: Normative`. All 7 design questions (Q1, Q3–Q8) now resolved.
- **Q6 resolved**: RFC 7807 Problem Details envelope is normative — errors MUST be `application/problem+json` with five required base fields (`type`, `title`, `status`, `detail`, `instance`) and extra-field tolerance. New §4.1: table of the 9 registered error-type URIs under `https://openric.org/errors/`. Reference server migrated in openric/service v0.8.11.
- **ContactPoint shape pinned**: `rico:ContactPoint` chosen over `schema:ContactPoint` (§3.4.1). New `:ContactPointShape` in `shapes/profiles/core-discovery.shacl.ttl`; `:RepositoryShape` now links to it via `sh:node`.
- §10 renamed from "Open design questions" to "Design decisions"; all 7 resolutions labelled "Resolution" (not "Draft resolution").

## v0.29.0 — 2026-04-21

### Reference-server additions rolled forward from post-v0.2.0 Unreleased

- **[openric.org/demo/browse/](demo/browse/)** — responsive card-grid browse over any OpenRiC-conformant server. Per-type filter tabs (Records / Agents / Places / Rules / Activities / Instantiations / Repositories / Functions), pagination, click-through to the 2D/3D viewer, `openric-demo` callouts when a seeded fonds is present. Pure browser, no build step.
- **Repository + Function write endpoints.** Full CRUD on all eight RiC entity classes; 46 paths in `openapi.json`.
- **`openric:rebuild-nested-set`** Artisan command with `--verify` and `--dry-run` — rebuilds information_object MPTT `lft/rgt` after bulk imports.
- **`openric:seed-demo`** Artisan command — creates a coherent mini-fonds (Repository + Agent + Place + Activity + Rule + Function + 3 Records + Instantiation + 11 relations) so the browse demo has a curated narrative. Idempotent; `--drop` removes.
- **SPARQL marked experimental** in §4.8 of the Viewing API spec. The endpoint remains a stub; clients should use `/graph?uri=…&depth=N` for traversal.
- **Conformance probe** now supports `READ_KEY=` for scope-enforcement checks (asserts a read-only key gets 403 on write routes).
- Three 404s in v0.28.3 live-linking fixed: `www.ica.org/...RiC-CM_1-0.pdf` (URL moved on ICA; swapped to the current `/app/uploads/2023/12/RiC-CM-1.0.pdf`); `openric.org/fixtures/activity-production/` and `.../agent-person-simple/` (Jekyll index pages added).

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
