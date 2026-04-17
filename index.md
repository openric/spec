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

**Current release: v0.2.0** &middot; **Status: draft, open for review** &middot; Last update: 2026-04-17

| Component | Status |
|---|---|
| Four specification documents (mapping, viewing API, graph primitives, conformance) | ✓ Drafts published |
| JSON Schemas (`record`, `agent`) | ✓ Live, validate real responses |
| SHACL shape file (`openric.shacl.ttl`) | ✓ Core RiC-O shapes |
| Validator CLI (`openric-validate`) | ✓ Alpha — schema + SHACL checks working |
| Conformance fixture pack | 1 of 20 published |
| Reference implementation ([Heratio](https://github.com/ArchiveHeritageGroup/heratio)) | ✓ First endpoint fully green: `/agents/{slug}` |
| Frozen v0.1.0 release | ⏳ Pending fixture pack + CI |

---

## Condensed roadmap

### Phase 1 — Frozen v0.1.0 *(in progress)*
Close out the spec's machine-verifiable half: remaining 9 JSON Schemas, 19 fixtures, endpoint walker in the validator, CI pipeline, then tag **v0.1.0**. Target: **~3 weeks**.

### Phase 2 — Beyond the reference
Extract **`@openric/viewer`** as a standalone npm package so any OpenRiC-conformant server can drive the 2D/3D graph UI. Demonstrate against a non-Heratio backend. Target: **~1 month after Phase 1**.

### Phase 3 — Governance & external review
Invite spec editors from outside AHG. Engage with EGAD-adjacent reviewers. Freeze **v1.0** when at least one non-reference implementation passes conformance. Target: **6+ months**.

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

*All four are drafts. Comment issues are welcome on the [GitHub repository](https://github.com/ArchiveHeritageGroup/openric-spec).*

---

## Reference implementation

[**Heratio**](https://github.com/ArchiveHeritageGroup/heratio) is the first reference implementation of OpenRiC. The 2D and 3D graph viewer will be published separately as `@openric/viewer`, usable against any OpenRiC-conformant server.

---

## Licence

- **Specification** — [Creative Commons Attribution 4.0 (CC-BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
- **Reference implementation** — [GNU AGPL 3.0](https://www.gnu.org/licenses/agpl-3.0.html)

---

## Contact

Johan Pieterse — [johan@theahg.co.za](mailto:johan@theahg.co.za)
The Archive and Heritage Group (Pty) Ltd
