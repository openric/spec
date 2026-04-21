# OpenRiC — Specification

> **Records in Contexts, served over HTTP — implementation-neutral, IIIF-inspired.**
>
> An open specification for how archival descriptions map to **RiC-CM / RiC-O**, how that data is served over HTTP for both reading and writing, and how graph-based interfaces can render it consistently across any conformant server. **Not a product — a contract anyone can implement.**

**🌐 [openric.org](https://openric.org)**   ·   **📖 [Read the spec](https://openric.org/spec/)**   ·   **🧪 [Try the API](https://openric.org/api-explorer/)**   ·   **✅ [Conformance probe](https://openric.org/conformance/)**

---

## Current version

**v0.36.1** — 2026-04-21. All 7 profiles normative: Core Discovery, Authority & Context, Graph Traversal, Digital Object Linkage, Round-Trip Editing, Provenance & Event, Export-Only. SPARQL explicitly positioned as non-normative (implementers MAY expose one at any path; it's not an OpenRiC contract). New implementer guide on triplestore choice. See [`CHANGELOG.md`](CHANGELOG.md).

## The OpenRiC ecosystem

| Repository | Role | Licence |
|---|---|---|
| **[openric/spec](https://github.com/openric/spec)** (you are here) | The specification, schemas, shapes, fixtures, conformance probe, API explorer | CC-BY 4.0 (spec) / AGPL-3.0 (tools) |
| **[openric/service](https://github.com/openric/service)** | Reference implementation — Laravel service, public and tracking spec v0.36.0 | AGPL-3.0 |
| **[openric/viewer](https://github.com/openric/viewer)** | `@openric/viewer` on npm — 2D + 3D graph rendering library | AGPL-3.0 |
| **[openric/capture](https://github.com/openric/capture)** | Pure-browser data-entry client; talks to any conformant server | AGPL-3.0 |

The reference implementation is **live at [ric.theahg.co.za](https://ric.theahg.co.za/api/ric/v1/health)**, with ~40 endpoints across read, write, graph walk, OAI-PMH, and file upload. It's backed by real archival data via [Heratio](https://heratio.theahg.co.za), which is an **operational consumer of the same public API** — no privileged shortcut.

---

## Repository layout

```
.
├── index.md                 — site landing page (rendered at openric.org/)
├── architecture.md          — how the four public deployments fit together
├── for-institutions.md      — executive / institutional brief
├── governance.md            — stewardship, change process, compatibility
├── spec/                    — the four normative documents
│   ├── mapping.md           — ISAD(G) / ISAAR(CPF) / ISDF / ISDIAH → RiC-CM / RiC-O
│   ├── viewing-api.md       — HTTP contract: read, write, graph, harvest
│   ├── graph-primitives.md  — node, edge, cluster, drill, layout-hint
│   └── conformance.md       — four levels (L1–L4), JSON Schemas, fixtures
├── schemas/                 — 19 JSON Schema files
├── shapes/                  — SHACL shapes (openric.shacl.ttl + full-graph)
├── fixtures/                — 27 end-to-end test cases
├── conformance/             — probe.sh + README (pure bash + jq)
├── api-explorer/            — Swagger UI over any OpenRiC server
├── demo/                    — live graph demo
│   └── browse/              — row-layout catalogue over any server
├── guides/
│   ├── getting-started.md   — 15-min walkthrough, zero to embed
│   ├── api.md               — client guide: curl, Python, JS
│   ├── viewer.md            — embedding the viewer library
│   └── capture.md           — using the capture tool
├── validator/               — pyshacl-based CLI validator
└── CHANGELOG.md             — versioned change history
```

## Quick start

```bash
# Read the spec
open https://openric.org/spec/

# Probe any OpenRiC server for conformance
git clone https://github.com/openric/spec
BASE=https://ric.theahg.co.za/api/ric/v1 bash spec/conformance/probe.sh
# → 21 passing checks on the reference server
```

## Conformance in one curl

```bash
curl -s https://ric.theahg.co.za/api/ric/v1/openapi.json \
  | jq '{version: .info.version, paths: (.paths | keys | length)}'
# → {"version": "1.0.0", "paths": 46}
```

## Licence

- **Specification** (`spec/`, `schemas/`, `shapes/`, `fixtures/`, all Markdown): [**CC-BY 4.0**](LICENSE) — adapt, fork, translate freely, with attribution.
- **Code** (`validator/`, `conformance/probe.sh`, `api-explorer/`, `demo/`): **AGPL-3.0-or-later** — per-file headers declare this; the separate ecosystem repos (`viewer`, `capture`, `service`) follow the same convention.

## Contributing

Changes to the spec are proposed via [GitHub Discussions](https://github.com/openric/spec/discussions) first, then PR. Bug reports as issues. See [governance](https://openric.org/governance.html) for the full change process.

The spec is currently **single-maintainer**; a second-implementer invitation goes out once anyone successfully runs an independent implementation through the conformance probe.

## Contact

Johan Pieterse · [johan@theahg.co.za](mailto:johan@theahg.co.za) · The Archive and Heritage Group (Pty) Ltd.
