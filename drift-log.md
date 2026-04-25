---
layout: default
title: OpenRiC Drift Log — Public known issues
permalink: /drift-log.html
---

# OpenRiC Drift Log

A public log of known drift between the OpenRiC specification and its public surfaces (reference API, viewer, capture client, OpenAPI metadata, conformance probe). Updated as items land or are resolved.

This page exists because the spec moves faster than the supporting implementations, and external reviewers need a single place to see *which* gaps are known, *where* they are, and *what's planned*. It is not a defect tracker — it tracks **deliberate** lag between the spec and downstream systems.

**Last updated:** 2026-04-25.

---

## Open drift items

### Reference API (`ric.theahg.co.za`) lag against spec v0.37.0

The reference Laravel service (openric/service v0.8.19) currently tracks spec v0.36.0. Migration to v0.37.0 is **Phase G**. Items pending in Phase G:

| Item | Currently emits | Target (spec v0.37.0) | ETA |
|---|---|---|---|
| Service description | `spec_version: "0.36.0"`, claims 6 of 7 profiles | `spec_version: "0.37.0"`, declares 6 of 7 + optionally `sparql-access` draft | Phase G |
| OpenAPI tags — Repository | `rico:Repository / Custodian` | `ISDIAH repository surface; canonical: rico:CorporateBody with hasOrHadHolder` | Phase G |
| OpenAPI tags — Function | `rico:Function (ISDF)` | `ISDF function surface; canonical: openricx:Function (interim) — see mapping §6.4` | Phase G |
| OpenAPI tags — SPARQL | `Subgraph walks + full SPARQL` | `Subgraph walks; SPARQL only if server declares sparql-access draft profile` | Phase G |
| Relation examples | `relation_type: hasInstantiation` | `rico:hasOrHadInstantiation` | Phase G |
| JSON-LD `@type` for events | `rico:Production` / `rico:Accumulation` (concrete classes) | `rico:Activity` + `rico:hasActivityType <vocab IRI>` (Activity+type per spec D.3) | Phase G |
| JSON-LD `@context` extension | no `openricx:` declaration | declares `openricx: https://openric.org/ns/ext/v1#` | Phase G |
| Hold-direction property names | `rico:heldBy`, `rico:hasInstantiation`, `rico:hasSubject`, `rico:hasLanguage`, `rico:hasMandate`, `rico:hasRecordPart`, `rico:isContainedIn`, etc. | Canonical 1.1 forms (`rico:hasOrHadHolder`, `rico:hasOrHadInstantiation`, etc. — full list in spec audit doc Phase B + D mappings) | Phase G |
| Provenance & Event profile claim | Not claimed (data-gap blocker — 177 productions missing creator) | Claim once data backfill completes | Phase G + data hygiene |

### Viewer (`viewer.openric.org`)

| Item | Issue | Plan |
|---|---|---|
| Node.type CURIE handling | Viewer must accept both `rico:Person` (CURIE, per spec v0.37 §8.6) and bare local names from older servers | Update viewer to canonicalize on read; emit only CURIEs in fresh requests |
| Activity-type rendering | Viewer currently dispatches on `@type` for Production/Accumulation/Activity; needs to also dispatch on `rico:hasActivityType` IRI | Add hasActivityType branch in node-classification logic |
| openricx prefix | Viewer must declare and resolve `openricx:` in JSON-LD contexts | Update bundled context |

### Capture client (`capture.openric.org`)

| Item | Issue | Plan |
|---|---|---|
| Activity entity entry form | Currently picks `Production` / `Accumulation` / `Activity` as the @type | Refactor to single `rico:Activity` + activity-type dropdown sourced from `/vocab/activity-type` |
| Repository entity | Form labels suggest `rico:Repository` is a class | Re-label as "ISDIAH repository — canonical: CorporateBody with holder relations" |
| Function entity | Form emits `rico:Function` | Switch to `openricx:Function` until ICA-EGAD upstream decision |

### Conformance probe (`/conformance/`)

| Item | Issue | Plan |
|---|---|---|
| Default probe checks `/sparql` | Spec v0.37 says SPARQL is optional under `sparql-access` profile | Skip `/sparql` checks unless server declares `sparql-access` |
| Profile-based probe modes | Currently only the legacy L1-L4 mode | Add `--profile=<id>` for each of the 7 normative + 1 draft profile |

### Documentation drift on the static site

| Item | Issue | Plan |
|---|---|---|
| Live homepage shows historical version pills (v0.1.0, v0.2.0) in the phase-cards section | These are accurate historical labels but reviewers may misread | Add a clearer "phase history" header above the cards |

### RiC-CM navigator reconciliation

| Item | Issue | Plan |
|---|---|---|
| Two RiC-CM navigators exist with overlapping purposes | OpenRiC ships its own RiC-CM browser at [`ric.theahg.co.za/reference/ric-cm/`](https://ric.theahg.co.za/reference/ric-cm/) (SPARQL-backed, declared-vs-inherited separation, versioned URLs). The Damigos / Ionian University group ships [RiC-CM Nav](https://dlib-ionian-university.github.io/ric-cm-nav/) (SPA, listed in the official ICA RiC ResourceList). Currently both exist and the relationship is undeclared. | Decide one of: (a) deprecate the OpenRiC navigator and link out to the Ionian one; (b) contribute to the Ionian project; (c) articulate what the OpenRiC navigator does that the Ionian one doesn't (and vice versa) on the [Related Implementations page](related-implementations.html). Targeted resolution: post-v0.38, before any v1.0 freeze. |

### External-extension watch (RiC-O 1.1 ecosystem)

| Item | Issue | Plan |
|---|---|---|
| AnF RiC-O extension landing ~June 2026 | Archives nationales de France is publishing a small RiC-O 1.1 ontology extension at [`github.com/ArchivesNationalesFR/ontology`](https://github.com/ArchivesNationalesFR/ontology) (v1.0 expected mid-June 2026). Likely to overlap with `openricx:` for agent description, address, place modelling. | When it lands: audit `openricx:` against the AnF extension. Where overlap exists, propose alignment or cross-reference rather than parallel definitions. Track per [external-signals memory](https://github.com/openric/spec). |
| OpenRiC vocabularies (`/vocab/activity-type/`, `/vocab/rule-type/`) need SKOS-publishing maturity | Currently published as static Turtle + HTML. Per the v2 review, the broader SKOS-publication pattern (HTML / JSON-LD / Turtle / RDF/XML / CSV per vocabulary, with `/vocabularies` index endpoint exposing each as a `skos:ConceptScheme`) is a Garance-style maturity step. | Phase H — once a non-reference implementation expresses a need. |
| `openricx:` extension namespace remains under-publicised | The Turtle ontology stub at [`/ns/ext/v1.html`](/ns/ext/v1.html) and 48 declared terms should be communicated to the EGAD-adjacent community. | Outreach drafts in [`docs/outreach/`](https://github.com/openric/spec/tree/main/docs/outreach) — Sparna and Damigos targets identified. |

### Phase numbering reconciliation

| Item | Issue | Plan |
|---|---|---|
| Two phase systems exist | The internal project context document tracks "Phases 1-7" by feature area (skeleton, lenses, graph, audit, discovery, export, workflow). The public roadmap tracks "Phases 1-12+" keyed to spec versions (v0.1, v0.2, v0.30 → v0.36, v1.0). These do not align. | The public spec-version roadmap is authoritative. Internal documents that still refer to the feature-area phase numbering should be updated to match. The internal-context-doc update is tracked in the project memory file `project_current_state.md` (post-2026-04-25 note: "Phases 1-7 by feature area is OUT OF DATE relative to public site"). |

---

## Closed (recent)

- **2026-04-25, v0.37.0** — RiC-O 1.1 namespace remediation, all 5 phases (A → E). Audit: 110 → 0 genuine emit-context violations.
- **2026-04-25, v0.37.0** — Per-document version headers (mapping/viewing-api/graph-primitives/conformance) bumped from `0.1.0-draft` to `0.37.0`.
- **2026-04-25, v0.37.0** — Mapping spec stale "review in progress" callout replaced with "REMEDIATION COMPLETE" callout.
- **2026-04-25, v0.37.0** — Audit doc opened with prominent STATUS banner.
- **2026-04-25, v0.37.0** — README current-version banner updated to v0.37.0.
- **2026-04-25, v0.37.0** — `drift-log.md` (this page) created.

---

## How to file a new drift item

Open a [discussion on openric/spec](https://github.com/openric/spec/discussions) with the label `drift`, or open a PR adding a row to this page. Format:

```md
| Surface | Currently observed | Target spec § | ETA / blocker |
|---|---|---|---|
| <which surface> | <what it does today> | <which spec section it should match> | <when, or what blocks it> |
```

OpenRiC's commitment: every open drift item is named, located, and either has an ETA or has a blocker explanation.
