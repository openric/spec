---
layout: default
title: OpenRiC — Data management & deployment topologies
description: How RiC data is stored, projected, and kept consistent — for green-field deployments, retrofits over AtoM, and consumer-with-own-UI cases like Heratio.
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Architecture · Data management</div>
    <h1>Where does RiC data live, and how does it get there?</h1>
    <p class="hero-lede">OpenRiC's specification describes an HTTP contract. It says nothing about how a conformant server stores its data. This page is the reference answer to "what should I run in the back?" — three deployment shapes (green-field, AtoM retrofit, Heratio-style consumer) and the trade-offs between them.</p>
  </div>
</div>

## The clarifying point

The **OpenRiC spec is storage-agnostic.** Endpoints, JSON-LD shapes, SHACL shapes, and the conformance probe are all the spec covers. Whether the server backing `ric.theahg.co.za` runs on a triplestore, a relational database, or something else is a separate engineering decision — any of the options below satisfies the spec equally.

Pick by operational fit, not semantic purity.

---

## What "RiC data" actually is

A RiC record is a **graph fragment**: a `rico:Record` node with typed edges — `rico:hasInstantiation` to Instantiation nodes, `rico:hasCreator` to Agents, `rico:isOrWasPartOf` up into a RecordSet — and dozens of other relation types defined in [RiC-O](https://github.com/ICA-EGAD/RiC-O). Every node carries one of the ~19 RiC classes; every edge has defined cardinality and an inverse.

A server needs to store three things:

1. **Typed entities** — one row / node per Record, Agent, Place, etc.
2. **Typed relations between them** — each relation carries its own type URI.
3. **Literal-valued properties** — titles, identifiers, dates, notes.

Three shapes of backing store handle that:

| Shape | Fit | Trade-offs |
|---|---|---|
| **Triplestore** (Apache Jena Fuseki, Virtuoso, Stardog) | Graph-native. SPARQL is the query and mutation language. | Pure. SPARQL writes are slower than SQL for bulk work; transactional guarantees weaker than ACID; poor tooling for ops/BI/reporting. |
| **Normalised relational tables** (PostgreSQL schema mirroring RiC classes + a generic `relation` table) | ACID writes. Mature tooling. Laravel/Django/Rails admin UIs are straightforward. | Joins get expensive beyond graph-depth 2. Exposing a SPARQL endpoint requires materialising into RDF on the side. |
| **Hybrid** — relational for write + triplestore for graph reads | Writes are safe and fast; graph queries don't punish the transactional path. | Two stores to keep in sync. Eventual consistency on the graph side (typically sub-second lag). |

For any production archive with 10k+ records, **the hybrid pattern is where the semantic-web ecosystem has converged** — Semantic MediaWiki, Wikibase, Fedora Commons, LD4P, and several EGAD-adjacent implementations all run variants of it.

---

## Topology A — Green-field standalone

Small-to-medium archive with no legacy system. OpenRiC is the only platform.

```
┌───────────────────────┐   writes    ┌─────────────────┐
│  OpenRiC admin UI     │────────────▶│  PostgreSQL     │
│  or capture.openric   │             │  normalised     │
└───────────────────────┘             │  RiC schema     │
        ▲                             └────────┬────────┘
        │ simple reads (list, detail)          │
        │                             materialise on commit
        │                                      ▼
        │                             ┌─────────────────┐
        │   graph reads (/graph,      │  Fuseki         │
        └───  /sparql, hierarchy)────▶│  openric        │
                                      │  dataset        │
                                      └─────────────────┘
```

**PostgreSQL is authoritative.** Tables model RiC classes + relations. Every mutation goes through a service layer that writes SQL and enqueues a materialise job.

**Fuseki is a projection.** A background worker (DB trigger → queue → consumer, or a simple post-commit hook) keeps Fuseki current. Lag target: under 5 seconds.

**Reads split by intent.** List and detail endpoints (`/records/{key}`, `/agents`, `/autocomplete`) hit PostgreSQL. Graph endpoints (`/graph`, `/sparql`, hierarchy walks) hit Fuseki. The client can't tell the difference.

**SHACL validation** runs at commit time against the about-to-materialise entity. A shape failure rolls back the SQL commit.

This is the topology [ric.theahg.co.za](https://ric.theahg.co.za) will migrate to once a PostgreSQL backend is in place; current deployment is a Phase 1 variant of Topology B.

---

## Topology B — Side-by-side with AtoM (retrofit)

Institution already running AtoM with a large existing catalogue. Curators are trained on AtoM. A flag-day cutover is not politically feasible.

**Recommended approach: strangler pattern over three phases.**

### Phase 1 — Read-only projection

```
┌──────────────┐  SQL reads  ┌──────────────────┐  reads  ┌──────────────────┐
│  AtoM UI     │────────────▶│  AtoM MySQL DB   │◀────────│  OpenRiC API     │
│ (unchanged)  │             │  (unchanged)     │         │  (read-only      │
└──────────────┘             └──────────────────┘         │  RiC projection) │
                                                          └──────────────────┘
```

AtoM stays authoritative. OpenRiC reads AtoM's MySQL directly and serialises as RiC-O over HTTP. No writes through OpenRiC. **Zero risk to the existing AtoM workflow.** Curators notice nothing.

**Value delivered on day one:** the archive is addressable via `/api/ric/v1/*`, the graph viewer at [viewer.openric.org](https://viewer.openric.org) works against the AtoM dataset, federated discovery and OAI-PMH harvesting become possible, conformance tooling applies.

### Phase 2 — New writes go through OpenRiC

```
┌──────────────┐                                         ┌──────────────────┐
│  AtoM UI     │  (read-only mode for new catalogues)    │  OpenRiC         │
│              │                                         │  PostgreSQL      │
│              │                                         └────────┬─────────┘
│              │  ◀─ sync (AtoM schema fill) ──                    │
│              │                                                   │ + Fuseki
│              │  ┌──────────────────┐                             ▼
│              │─▶│  AtoM MySQL DB   │                    ┌──────────────────┐
│              │  │  (legacy data)   │                    │  OpenRiC UI +    │
└──────────────┘  └──────────────────┘                    │  capture client  │
                                                          └──────────────────┘
```

New accessions / catalogues are entered via OpenRiC's UI (or [capture.openric.org](https://capture.openric.org)). Writes land in OpenRiC's PostgreSQL. A back-sync populates AtoM's MySQL so AtoM's search index and reports continue to cover all records, old and new, for users still on the AtoM side.

### Phase 3 — AtoM decommissioned

Historical AtoM records migrated into OpenRiC PostgreSQL (one-off ETL). AtoM UI retired. OpenRiC is authoritative for everything.

Typical timeline: **6 to 18 months**, depending on catalogue size and institutional change-appetite.

---

## Topology C — Consumer with its own UI (Heratio-style)

An existing platform has its own modern admin UI and its own database. It wants to keep its UX — forms, workflows, reports, compliance modules — while delegating RiC data ownership to OpenRiC.

Heratio is the canonical example; any GLAM platform (Access to Memory 3.x, ArchivesSpace, or a custom Laravel app) could adopt the same shape.

```
┌─────────────────────┐   HTTP   ┌──────────────────────┐
│ Consumer admin UI   │─────────▶│  OpenRiC Reference   │
│ (Bootstrap, React,  │  writes  │  API                 │
│  whatever — stays   │          │  (PostgreSQL +       │
│  unchanged)         │          │   Fuseki)            │
│                     │          └──────────┬───────────┘
│                     │                     │
│                     │                     │ webhooks or periodic ETL
│                     │                     │
│                     │  reads   ┌──────────▼───────────┐
│                     │◀─────────│  Consumer's local    │
│                     │  (fast)  │  read-cache DB       │
│                     │          │  (materialised from  │
│                     │          │  OpenRiC on write)   │
└─────────────────────┘          └──────────────────────┘
```

**OpenRiC is the source of truth for RiC data.** Every mutation from the consumer's UI is an HTTP POST/PATCH/DELETE to `/api/ric/v1/*`. The consumer holds no authoritative RiC state.

**The consumer's local database becomes a read-cache**, kept current by OpenRiC webhooks (or, for simpler setups, periodic ETL). This is what protects the UI from HTTP round-trips on every list page.

**Non-RiC features stay entirely local** — compliance modules, workflow engines, ticketing, galleries, IIIF viewers — none of that is RiC, none of it touches OpenRiC.

**Migration path** for a platform adopting this topology:

1. **Split the codebase** into "RiC-touching" and "not". Usually the RiC-touching surface is smaller than it looks.
2. **Rewire each RiC-touching write controller** to call OpenRiC HTTP instead of writing to the local database.
3. **Set up the read-cache sync.** Simplest: OpenRiC webhooks on write → listener → update local tables. Alternative: periodic ETL, every 5 minutes.
4. **Verify** with the conformance probe — `probe.sh --profile=round-trip-editing` against the OpenRiC backend — that every mutation works through the HTTP surface with no shortcuts.

Timeline: several weeks of focused work per controller, spread across releases. The UI doesn't change shape; only the I/O layer underneath.

---

## All three topologies on one codebase

Same OpenRiC server, three deployment plumbings:

| Deployment | Source of truth | Fuseki | Legacy DB | Primary UI |
|---|---|---|---|---|
| **A. Green-field standalone** | OpenRiC PostgreSQL | projection | — | OpenRiC admin / Capture |
| **B.1 AtoM retrofit, Phase 1** | AtoM MySQL | projection of AtoM | authoritative | AtoM UI (unchanged) + OpenRiC API readers |
| **B.2 AtoM retrofit, Phase 2–3** | OpenRiC PostgreSQL | projection | read-only, syncing back | AtoM (read-only) + OpenRiC UI |
| **C. Heratio-style consumer** | OpenRiC PostgreSQL | projection | read-cache, synced from HTTP | Consumer's own UI |

The HTTP contract — paths, JSON-LD shapes, SHACL validation, conformance-profile declaration — is identical in all four.

---

## How to choose

- **No legacy system to accommodate?** Topology A. Simplest, cleanest, green-field.
- **Running AtoM and can't stop?** Topology B, Phase 1 this quarter. The only risk is schema drift if AtoM gets updated independently — monitor that.
- **Have your own admin UI you want to keep?** Topology C. Make peace with the HTTP round-trip cost on writes; it's the price of single-source-of-truth correctness.
- **Green field but want future optionality?** Topology A, but design the write path behind a thin `RicWriteService` interface so swapping in HTTP-to-another-OpenRiC-server later is trivial. Means you *could* become a Topology C consumer of someone else's OpenRiC deployment if federation plans firm up.

---

## What this does *not* specify

OpenRiC doesn't prescribe:

- **The PostgreSQL schema.** Implementations are free to shape their relational model however they like. Several reference schemas are planned in the [spec](spec/) but none is normative.
- **The materialisation mechanism.** Background worker, DB triggers, post-commit hooks, message queues — all fine. The only contract is that the triplestore catches up in reasonable time.
- **The webhook format.** When the reference API fires write webhooks, their shape is implementation-defined for now. A standardised `openric:EntityChanged` webhook format is on the post-v1.0 roadmap.
- **SPARQL update.** The spec currently lists `/sparql` as experimental. Most implementations read-only. Write-through-SPARQL may be formalised in a future profile; today, writes are HTTP-only.

---

## Related reading

<div class="spec-docs">
  <a class="spec-doc" href="architecture.html">
    <strong>Architecture</strong>
    <span>How the four public deployments (spec, reference API, clients, consumers) fit together at the network level.</span>
  </a>
  <a class="spec-doc" href="profiles.html">
    <strong>Profiles</strong>
    <span>The seven conformance profiles that scope what a given server claims to implement. Data management is orthogonal to profile.</span>
  </a>
  <a class="spec-doc" href="spec/">
    <strong>Specification</strong>
    <span>The normative HTTP contract. Read after picking a topology.</span>
  </a>
  <a class="spec-doc" href="conformance/">
    <strong>Conformance</strong>
    <span>How to verify your chosen topology actually implements the contract, via the probe.</span>
  </a>
</div>

## License

This page is part of the OpenRiC specification documentation, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Adaptations welcome; link back.
