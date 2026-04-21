---
layout: default
title: OpenRiC — Choosing a triplestore
description: Fuseki, GraphDB, Oxigraph, Virtuoso, Qlever, Blazegraph, Neptune — what to run RiC data on, at what scale, and when to switch.
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Implementer guide</div>
    <h1>Choosing a triplestore for an OpenRiC server</h1>
    <p class="hero-lede">OpenRiC is triplestore-agnostic — the reference implementation ships with Apache Jena Fuseki, but anything that speaks SPARQL 1.1 and supports SHACL validation can back an OpenRiC server. This guide walks through the real options, the scales they handle cleanly, and the points at which each one starts to hurt.</p>
  </div>
</div>

## TL;DR

| Store | Best for | Watch out for |
|---|---|---|
| **Apache Jena Fuseki** (reference) | Getting started fast; small–medium archives up to ~10–50 M triples | Slows noticeably past ~100 M triples; single-node; GC pauses on large heaps |
| **Oxigraph** | Single-machine speed; RiC catalogues that fit in RAM | Young project (Rust-based); clustering is not on the roadmap |
| **GraphDB Free / SE** | Mid-sized institutions that need reasoning + SHACL at speed | Java-heavy; free edition caps at 2 concurrent queries |
| **Virtuoso Open Source** | Large-scale deployments (50 M–1 B+ triples) | Operational quirks (SQL-like config); steeper learning curve |
| **QLever** | Read-heavy, huge catalogues; Wikidata-scale SPARQL | Newer; thinner ecosystem; write support less mature |
| **Blazegraph** | Legacy installs already running it | **Effectively unmaintained since 2020**; not a new-deploy choice |
| **Amazon Neptune** | "I don't want to run a server" | Vendor lock-in; pricing grows with connections; SHACL support via external tools only |

**If you're starting today:** Fuseki. It's what the reference implementation uses, the documentation assumes it, and up to a few million triples you will not notice any performance issue. Revisit when your store crosses ~50 M triples, your queries regularly exceed 2 seconds, or you need RDFS/OWL inference that Fuseki's default configuration doesn't handle.

## Scale bands

What counts as "large" depends on your write-read mix. For the archival read-heavy pattern OpenRiC expects:

| Triples | Archive size analogy | Comfortable stores |
|---|---|---|
| < 1 M | One fonds, fully described | Any store on this list |
| 1–10 M | A small institution's full catalogue | Fuseki, Oxigraph, GraphDB Free |
| 10–50 M | A medium regional archive | Fuseki (with TDB2, tuned heap), GraphDB SE, Oxigraph |
| 50–200 M | A national archive's public tier | Virtuoso, GraphDB Enterprise, Stardog |
| 200 M+ | Federated / aggregator tier | Virtuoso, QLever, custom clusters |

OpenRiC's reference deployment at ric.theahg.co.za currently runs under 5 million triples on Fuseki with default JVM settings — well inside the comfortable band, no tuning needed.

## The options in detail

### Apache Jena Fuseki (reference)

- **Licence:** Apache 2.0
- **Runtime:** Java
- **Storage backend:** TDB2 (persistent, single-node) or in-memory
- **SHACL:** Supported via the `jena-shacl` module
- **Write model:** transactional; good for the OpenRiC write profile (Round-Trip Editing)

**Why we default to it**: it's free, standards-compliant, ships as an executable JAR with a web UI, and every SPARQL tutorial on the planet assumes it. The reference implementation's `TriplestoreService` is written against Fuseki's HTTP protocol (SPARQL Update + SPARQL Query + Graph Store Protocol) so switching to another SPARQL-1.1-compliant store is a config change, not a code change.

**When it gets slow**: the usual complaints are:

1. **Heap pressure** — the default `-Xmx` on packaged distributions is modest (1–2 GB). Bump it to at least 4 GB for anything past a million triples; 8–16 GB is normal for medium catalogues. GC tuning (G1GC, longer young-generation) helps more than most config knobs.
2. **TDB2 compaction lag** — writes that go faster than the background compactor can keep up (bulk imports, migrations) leave the store in a state that reads slower. Schedule a `tdb2.tdbcompact` in a maintenance window after large imports.
3. **No query planner beyond basics** — complex joins over large property paths don't get optimised the way they would in a commercial store. Rewrite the SPARQL rather than expect the planner to save you.
4. **Single-node, no sharding** — past ~100 M triples on one box you're fighting physics, not Jena.

**When to migrate off Fuseki**: not the triple count, but the p95 query latency. If your typical `/graph` response takes over 2 seconds after indexing + heap tuning, look at Oxigraph (same surface, faster engine) or GraphDB (more memory, real planner).

### Oxigraph

- **Licence:** Apache 2.0 / MIT
- **Runtime:** Rust (single binary; no JVM)
- **Storage backend:** RocksDB (persistent) or in-memory
- **SHACL:** Currently limited — full SHACL validation via external tools (pyshacl, or shipping through the conformance probe) rather than in-database

**Why consider it**: dramatically lower memory overhead than Fuseki at the same triple count, faster cold-start, and a much simpler deployment story (single static binary, no JVM tuning). For a catalogue that fits comfortably in RAM, Oxigraph can be 3–10× faster than Fuseki on comparable hardware.

**Caveats**: the project is younger (first public release 2019 vs Jena's 2000); write concurrency is less battle-tested; clustering isn't a roadmap item. SHACL validation lives outside the engine, so an OpenRiC server using Oxigraph would validate at the service layer (which is fine — the reference already does this for profile-scoped shapes).

**Good fit**: institutions that want a Fuseki-class SPARQL endpoint without the Java operational burden, and whose catalogues are stable (not on a growth ramp past tens of millions of triples).

### GraphDB (Ontotext)

- **Licence:** Proprietary, three editions (Free / Standard / Enterprise)
- **Free edition limits**: 2 concurrent queries, 5 concurrent write connections — fine for a single-archive read-heavy server, pinching for a shared multi-tenant deployment
- **Reasoning:** best-in-class RDFS+ and OWL-Horst inference; SHACL natively supported with rule chaining

**Why consider it**: if your catalogue uses RiC-O's class hierarchy meaningfully (e.g., queries that say "give me all `rico:Agent` subclasses" and expect RDFS-inferred answers), GraphDB handles this an order of magnitude better than Fuseki. Also has a real query planner that optimises join orders — helpful when you start writing complex provenance walks.

**Caveats**: proprietary, so a lock-in cost if you later want to port to an open store. Free edition's concurrent-query cap is real at traffic past demo-scale. Enterprise is priced for institutional buyers.

**Good fit**: a national or research archive with reasoning-heavy use cases and a budget line for SE or Enterprise licences.

### Virtuoso Open Source Edition

- **Licence:** GPLv2 (OSE) / proprietary (Commercial)
- **Storage backend:** column-store RDBMS with an RDF layer
- **Scale target:** large — this is what powers DBpedia (~1 B triples), OpenCitations, and a large chunk of public linked-open-data deployments
- **SHACL:** partial; needs external tooling for full conformance

**Why consider it**: when your catalogue passes 50 M triples and Fuseki + Oxigraph start to struggle, Virtuoso is the obvious next step. Its column-store backing gives excellent compression (RiC catalogues compress ~8–12× vs raw turtle) and its SPARQL planner handles long joins competently.

**Caveats**: operational complexity is real. Config is SQL-shaped (Virtuoso started as an RDBMS and bolted RDF on), so tuning feels unfamiliar if you come from Jena. Commercial edition has features (column-clustering, faster bulk loads) that the OSE lacks. Community support is thinner than Fuseki's — plan on reading source or paying OpenLink for complex questions.

**Good fit**: national archives, cross-institutional aggregators, anyone publishing to LOD Cloud.

### QLever

- **Licence:** Apache 2.0
- **Runtime:** C++ (single binary)
- **Scale target:** extreme — designed from scratch to query Wikidata-scale stores (15 B+ triples) on a single machine
- **Write model:** not its strength; QLever is read-optimised with batch-load semantics

**Why consider it**: if you're building an OpenRiC-compatible AGGREGATOR rather than a per-institution server (e.g., "the South African federated archive index"), QLever's query speed at scale is hard to match. The team behind it cares about SPARQL compliance and has been grinding through edge cases for years.

**Caveats**: still younger than Fuseki, smaller ecosystem, thin write-path story (expects bulk loads rather than drip-fed updates). Not a good fit for a catalogue with Round-Trip Editing as its primary use case.

**Good fit**: read-only or write-rarely deployments at very large scale.

### Blazegraph

- **Licence:** GPLv2 / commercial
- **Status:** **effectively abandoned since 2020** (last meaningful release 2020-11; the Wikidata team who was its primary user has split to QLever + WDQS Graph Split as of 2024)

**Why it's listed here at all**: you may inherit a Blazegraph install (it was the Wikidata Query Service for years, so it's widely deployed) and need to know what to do. The answer: migrate off it within the next 12-18 months. It still works, but new deployments should pick something maintained.

### Amazon Neptune

- **Licence:** AWS managed service (commercial)
- **Pricing:** per-instance + storage + I/O; connection-bound not query-bound
- **SPARQL:** supported; SHACL not native (run validation outside the store)

**Why consider it**: if your organisation is already AWS-heavy and "I don't want to run a database" is worth paying for, Neptune lets you skip triplestore ops entirely. Point OpenRiC's `TriplestoreService` at the Neptune endpoint via its SPARQL HTTP protocol and you're done.

**Caveats**: vendor lock-in on a niche managed service that Amazon has kept at arm's length from its mainstream RDS/Aurora lineup. Pricing is opaque — scaling for bursty query load costs more than an equivalent self-hosted Fuseki. SHACL validation sits outside the store, which is fine but means you can't push validation responsibility to the DB.

**Good fit**: cloud-native teams who need RDF but not the full self-managed database experience.

## Migrating between stores

Because OpenRiC's service layer talks to its triplestore over SPARQL 1.1 HTTP, migrating is a two-step dance:

1. **Dump** — `curl https://your-server/api/ric/v1/records/all/export?format=ttl > store.ttl` (or a more direct triplestore-native dump if the store supports it, e.g. `tdb2.tdbdump` for Fuseki, `ISQL` for Virtuoso).
2. **Load** — point the new store at `store.ttl` with its bulk-loader (`tdb2.tdbloader` for Fuseki, `LOAD` statement in Oxigraph, `ld_dir` for Virtuoso).
3. **Re-point** — update `TRIPLESTORE_URL` (or equivalent) in the OpenRiC service's `.env` and restart.

Test the full conformance probe (`bin/probe --profile=core-discovery`, then each other profile) against the new store before cutting production traffic over. A full-profile probe catches most migration issues — especially SHACL validation differences (GraphDB is stricter than Fuseki on OWL disjointness; Oxigraph is less tolerant of malformed date literals).

## What the reference implementation actually does

At ric.theahg.co.za (the openric/service deployment):

- **Store**: Fuseki 5.x with TDB2, 4 GB heap, default G1GC
- **Triples**: ~3.5 M
- **p95 query latency**: ~80 ms for `GET /records/{slug}`, ~220 ms for `GET /graph?uri=&depth=2`
- **Compaction**: run weekly via cron; takes ~30 s on current store size

This sits comfortably in Fuseki's "no reason to migrate" band. If and when it crosses 50 M triples or the `/graph` p95 climbs past 2 seconds, Oxigraph is the likely first move — same SPARQL surface, roughly 5× faster on our query mix in informal benchmarks, and zero Java ops overhead.

## What OpenRiC itself requires

None of this is normative. The OpenRiC conformance contract is defined over the HTTP API surface, not over the backing store. A conformant server can:

- Run on any triplestore above (or one we haven't listed).
- Run on a relational database with an RDF abstraction layer.
- Run on a custom in-memory graph structure for small catalogues.
- Run on a mix (e.g., hot data in Oxigraph, cold archive in Virtuoso).

The spec cares that `/records/{slug}` returns conformant JSON-LD and that SHACL validates. Where the triples live is up to you.

---

**See also:**

- [Data management patterns](../data-management.html) — how to organise your triples across named graphs, whether to shard by fonds, backup strategies.
- [Conformance probe](../conformance/) — how to verify a store switch didn't break anything.
- [Viewing API §4.8 SPARQL](../spec/viewing-api.html#48-sparql-non-normative--outside-the-openric-contract) — why OpenRiC doesn't mandate a SPARQL endpoint, and where implementations MAY expose one.
