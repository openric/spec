---
layout: default
title: OpenRiC
---

# OpenRiC

**An open specification for Records in Contexts (RiC) — implementation-neutral, IIIF-inspired.**

OpenRiC defines how archival descriptions (ISAD(G), ISAAR(CPF), ISDIAH) map to **Records in Contexts** (RiC-CM / RiC-O), how RiC data is served for viewing *and* for capture over HTTP, and how graph-based interfaces can render it consistently across different systems.

OpenRiC is not a product. It is a specification. Any system — AtoM, Heratio, Archivematica, a bespoke national-archive platform — can implement it.

---

## Where we are

**Current release: v0.1.0** &middot; **Status: draft, open for review** &middot; Last update: 2026-04-18

### Four public surfaces — all live

| Surface | Status | Role |
|---|---|---|
| **[openric.org](https://openric.org)** | ✓ live | Specification — four documents, 12 JSON Schemas, SHACL shapes, 20-case fixture pack, validator CLI |
| **[viewer.openric.org](https://viewer.openric.org)** | ✓ live | Graph viewer (`@openric/viewer` on npm) — 2D/3D, works against Heratio AND a non-Heratio static-fixture backend in the same UI |
| **[capture.openric.org](https://capture.openric.org)** | ✓ live | Pure-browser data-entry client — paste any OpenRiC server URL + API key, create Places, Rules, Activities, Instantiations, relations |
| **[ric.theahg.co.za/api/ric/v1](https://ric.theahg.co.za/api/ric/v1/health)** | ✓ live | Reference API endpoint — independently-deployed Laravel service over a real archival database |

### The ecosystem, more granular

| Component | Status |
|---|---|
| Four specification documents (mapping, viewing API, graph primitives, conformance) | ✓ Published |
| JSON Schemas (12) | ✓ All entity responses + list + error + service-description |
| SHACL shape files (core + full-graph) | ✓ 254 + 31 triples |
| Validator CLI (`openric-validate`) | ✓ Schema + SHACL + graph-invariant checks |
| Conformance fixture pack | ✓ 20 canonical fixtures |
| Read-side API | ✓ 21 endpoints (entity CRUD reads, subgraph, autocomplete, vocabulary, relations, hierarchy) |
| Write-side API | ✓ 9 endpoints — POST/PATCH/DELETE for Place/Rule/Activity/Instantiation + relations + generic-delete-by-id, gated by `X-API-Key` with scopes |
| Standalone viewer ([`@openric/viewer`](https://www.npmjs.com/package/@openric/viewer)) | ✓ v0.1.1 on npm |
| Standalone capture client ([`@openric/capture`](https://github.com/openric/capture)) | ✓ Live at capture.openric.org |
| Reference API deployment | ✓ [ric.theahg.co.za](https://ric.theahg.co.za) — separate nginx vhost + PHP-FPM from Heratio; cross-origin-open reads, X-API-Key writes |
| **Reference implementation is itself a consumer of the public API** | ✓ [Heratio](https://github.com/ArchiveHeritageGroup/heratio)'s admin actions POST/PATCH/DELETE to `ric.theahg.co.za/api/ric/v1/*` — same surface any external client uses. No privileged shortcut. |
| Portability proof — read-side | ✓ Viewer drives Heratio + static-fixture backends in the same demo |
| Portability proof — write-side | ✓ Capture client writes to any OpenRiC server given a URL + key |
| CI — unit tests, schema well-formedness, SHACL parse, Markdown links | ✓ GitHub Actions green |
| **Frozen v0.1.0 release** | **✓ Tagged** — see [CHANGELOG](https://github.com/openric/spec/blob/main/CHANGELOG.md) |

---

## Condensed roadmap

### Phase 1 — Spec v0.1.0 frozen *(done)*
Four documents, 12 JSON Schemas, 20-case fixture pack, validator CLI, CI green. Tagged and published.

### Phase 2 — Beyond the reference *(done)*
- **Viewer extracted** to npm as [`@openric/viewer`](https://www.npmjs.com/package/@openric/viewer), demo at [viewer.openric.org](https://viewer.openric.org).
- **Capture client** shipped at [capture.openric.org](https://capture.openric.org) — pure-browser, works against any OpenRiC-conformant backend.
- **Reference API extracted** into its own Laravel deployment at [ric.theahg.co.za/api/ric/v1](https://ric.theahg.co.za/api/ric/v1/health). Heratio stopped serving the API itself and is now a client of it — every admin action goes out over HTTP with an API key. This is the strongest possible structural commitment the reference implementation can make to the neutrality of the spec.

### Phase 3 — Governance & external review *(current)*
Invite spec editors from outside AHG. Engage with EGAD-adjacent reviewers. Attract a second, non-reference implementation. Freeze **v1.0** when at least one passes conformance.

Three seed Discussions open for [announcements](https://github.com/openric/spec/discussions/1), [second-implementer feedback](https://github.com/openric/spec/discussions/2), and [mapping sanity-checks](https://github.com/openric/spec/discussions/3). A [progress update](https://github.com/openric/spec/discussions/4) covers everything since the v0.1.0 announcement.

### Beyond v1.0
- OpenRiC-Rights (ODRL-backed rights enforcement)
- OpenRiC-Preservation (PREMIS-equivalent event vocabulary)
- Jurisdictional extensions (POPIA, GDPR, CDPA, GRAP 103, etc.) — decoupled from the core

*Detailed plans: [`ric-status-and-plan.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-status-and-plan.md), [`ric-split-plan.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-split-plan.md), [`ric-split-runbook.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-split-runbook.md), [`ric-split-collapse-plan.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-split-collapse-plan.md) in the Heratio repository.*

---

## The four specification documents

| Document | Purpose |
|---|---|
| [Mapping Spec](spec/mapping.html) | How to translate archival-description schemas into RiC-CM / RiC-O |
| [Viewing API](spec/viewing-api.html) | REST + JSON-LD contract for delivering RiC (read + write) |
| [Graph Primitives](spec/graph-primitives.html) | Abstract concepts — node, edge, cluster, drill, layout hints |
| [Conformance](spec/conformance.html) | JSON Schemas, fixtures, and a validator CLI |

*All four are drafts. Open-ended feedback and proposals → [GitHub Discussions](https://github.com/openric/spec/discussions). Concrete bugs or spec typos → [Issues](https://github.com/openric/spec/issues).*

---

## Architecture at a glance

See [Architecture](architecture.html) for the full map of how the four public surfaces fit together, what each is responsible for, and how a second implementation would slot in.

The short version:

```
Spec (openric.org) ─────► Conformance tests (spec/fixtures + SHACL)
                            │
                            ▼
                    ┌───────────────────────┐
                    │   OpenRiC API         │
                    │   /api/ric/v1/*       │
                    └───────────────────────┘
                    ▲               ▲
                    │               │
     capture.openric.org      viewer.openric.org
     (pure-browser write)    (pure-browser read)
                    ▲               ▲
                    │               │
              Heratio admin UI  (any 3rd-party client)
```

---

## Licence

- **Specification** — [Creative Commons Attribution 4.0 (CC-BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
- **Reference implementation, viewer, capture client** — [GNU AGPL 3.0](https://www.gnu.org/licenses/agpl-3.0.html)

---

## Contact

Johan Pieterse — [johan@theahg.co.za](mailto:johan@theahg.co.za)
The Archive and Heritage Group (Pty) Ltd
