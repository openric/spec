---
layout: default
title: OpenRiC
---

# OpenRiC

**An open specification for Records in Contexts (RiC) — implementation-neutral, IIIF-inspired.**

OpenRiC defines how archival descriptions (ISAD(G), ISAAR(CPF), ISDIAH) map to **Records in Contexts** (RiC-CM / RiC-O), how RiC data is served for viewing, and how graph-based interfaces can render it consistently across different systems.

OpenRiC is not a product. It is a specification. Any system — AtoM, Heratio, Archivematica, a bespoke national-archive platform — can implement it.

---

## Where we are

**Current release: v0.1.0** &middot; **Status: draft, open for review** &middot; Last update: 2026-04-18

| Component | Status |
|---|---|
| Four specification documents (mapping, viewing API, graph primitives, conformance) | ✓ Published |
| JSON Schemas (12) | ✓ All entity responses + list + error + service-description |
| SHACL shape files (core + full-graph) | ✓ 254 + 31 triples |
| Validator CLI (`openric-validate`) | ✓ Schema + SHACL + graph-invariant checks |
| Conformance fixture pack | ✓ 20 canonical fixtures |
| Reference implementation ([Heratio](https://github.com/ArchiveHeritageGroup/heratio)) | ✓ 8 endpoint types live-validate; full CRUD API (read + write) for every RiC-native entity type; 12 of 13 internal admin routes now consume `/api/ric/v1/*` rather than in-process services |
| Capture workspace — [`heratio.theahg.co.za/ric-capture`](https://heratio.theahg.co.za/ric-capture) | ✓ Focused data-entry UI on the reference implementation. Creates Places, Rules, Activities, Instantiations, and relations; every write goes through `/api/ric/v1/*` and is immediately visible to external API consumers. |
| [Live demo](demo/) — browser-side viewer calling the reference implementation | ✓ 2D + 3D graph, interactive drill-down, subjects/terms now expand to tagged records |
| Standalone viewer package [`@openric/viewer`](https://www.npmjs.com/package/@openric/viewer) | ✓ v0.1.0 published on npm — consumed by [openric.org/demo](demo/) and [viewer.openric.org](https://viewer.openric.org) |
| **Portability proof** — same viewer, two backends | ✓ [viewer.openric.org](https://viewer.openric.org) runs the npm-published viewer against Heratio **and** a non-Heratio static-fixture backend (service-worker-intercepted, served from the OpenRiC conformance fixture pack). Picking "Static fixtures" in the demo dropdown proves the viewer doesn't depend on Heratio-specific behaviour. |
| CI — unit tests, schema well-formedness, SHACL parse, Markdown links | ✓ GitHub Actions green |
| **Frozen v0.1.0 release** | **✓ Tagged** — see [CHANGELOG](https://github.com/openric/spec/blob/main/CHANGELOG.md) |

---

## Condensed roadmap

### Phase 1 — Frozen v0.1.0 *(in progress)*
Close out the spec's machine-verifiable half: remaining 9 JSON Schemas, 19 fixtures, endpoint walker in the validator, CI pipeline, then tag **v0.1.0**. Target: **~3 weeks**.

### Phase 2 — Beyond the reference *(substantially complete)*
**`@openric/viewer`** extracted, published to npm, and deployed at [viewer.openric.org](https://viewer.openric.org). **Portability proof delivered:** the same npm-published viewer drives two independent backends in the live demo — the Heratio reference server AND an in-browser static-fixture server (service-worker intercept, fixtures drawn from the spec's own 20-case conformance pack). Remaining Phase 2 work is a native-not-reference implementation someone else has to build — which brings us into Phase 3.

### Phase 3 — Governance & external review *(starting)*
Invite spec editors from outside AHG. Engage with EGAD-adjacent reviewers. Freeze **v1.0** when at least one non-reference implementation passes conformance. Three seed Discussions open for [announcements](https://github.com/openric/spec/discussions/1), [second-implementer feedback](https://github.com/openric/spec/discussions/2), and [mapping sanity-check](https://github.com/openric/spec/discussions/3). Target: **6+ months**.

### Beyond v1.0
- OpenRiC-Rights (ODRL-backed rights enforcement)
- OpenRiC-Preservation (PREMIS-equivalent event vocabulary)
- Jurisdictional extensions (POPIA, GDPR, CDPA, GRAP 103, etc.) — decoupled from the core

*Detailed plans: [`ric-phase1-closeout-plan.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-phase1-closeout-plan.md) and [`ric-status-and-plan.md`](https://github.com/ArchiveHeritageGroup/heratio/blob/main/docs/ric-status-and-plan.md) in the Heratio repository.*

---

## The four specification documents

| Document | Purpose |
|---|---|
| [Mapping Spec](spec/mapping.html) | How to translate archival-description schemas into RiC-CM / RiC-O |
| [Viewing API](spec/viewing-api.html) | REST + JSON-LD contract for delivering RiC for interactive viewing |
| [Graph Primitives](spec/graph-primitives.html) | Abstract concepts — node, edge, cluster, drill, layout hints |
| [Conformance](spec/conformance.html) | JSON Schemas, fixtures, and a validator CLI |

*All four are drafts. Open-ended feedback and proposals → [GitHub Discussions](https://github.com/openric/spec/discussions). Concrete bugs or spec typos → [Issues](https://github.com/openric/spec/issues).*

---

## Reference implementation

[**Heratio**](https://github.com/ArchiveHeritageGroup/heratio) is the first reference implementation of OpenRiC. The 2D and 3D graph viewer is published separately as [`@openric/viewer`](https://www.npmjs.com/package/@openric/viewer), usable against any OpenRiC-conformant server. For transparency, Heratio today runs the OpenRiC API as an internal module — RiC data lives in its own tables (clean data boundary) and all admin routes already speak the API over HTTP, but the full separate-service split is still on the roadmap.

A focused capture workspace lives at [**heratio.theahg.co.za/ric-capture**](https://heratio.theahg.co.za/ric-capture) — it's the simplest way to see data entry against an OpenRiC-conformant server end-to-end. Everything captured there is served back through the public API and can be explored in the [viewer demo](https://viewer.openric.org) within seconds.

---

## Licence

- **Specification** — [Creative Commons Attribution 4.0 (CC-BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
- **Reference implementation** — [GNU AGPL 3.0](https://www.gnu.org/licenses/agpl-3.0.html)

---

## Contact

Johan Pieterse — [johan@theahg.co.za](mailto:johan@theahg.co.za)
The Archive and Heritage Group (Pty) Ltd
