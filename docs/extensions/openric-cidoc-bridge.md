---
layout: default
title: OpenRiC-CIDOC-Bridge — extension proposal (strawman)
permalink: /docs/extensions/openric-cidoc-bridge.html
---

# OpenRiC-CIDOC-Bridge — extension proposal

**Status:** Strawman draft, post-v1.0
**Authors:** OpenRiC project (proposed; co-authorship with Damigos / Ionian University to be discussed per [outreach](../outreach/damigos-second-implementation.md))
**Last updated:** 2026-04-25
**Depends on:** OpenRiC `core-discovery` profile (any v0.37+) + the work in Damigos et al. (ICADL 2023, ["RiC-CM ↔ CIDOC-CRM mapping"](https://link.springer.com/))

---

## 1. Purpose

OpenRiC-CIDOC-Bridge is a proposed extension that **expresses an OpenRiC-served RiC-O graph in CIDOC-CRM-equivalent form** for cross-domain interoperability with the museum / cultural-heritage / Spectrum community.

OpenRiC's core spec is RiC-O-1.1-aligned and archive-focused. It maps cleanly to ISAD(G) / ISAAR(CPF) / ISDIAH / ISDF source data. CIDOC-CRM is the parallel modelling stack for museum collections (Spectrum, ICOM, Linked.Art). The two communities frequently need to query across both — a researcher tracking provenance through a museum holding and an archival fonds, an institution that holds both archival and museum collections, a federated catalogue spanning libraries / archives / museums (LAM).

A direct RiC-O ↔ CIDOC-CRM bridge **inside OpenRiC** lets archive-side data be queried with CIDOC-CRM idioms without each adopter having to invent the mapping. The mapping work is largely already done — Damigos's group at Ionian University published the foundational paper at ICADL 2023.

## 2. Scope

### 2.1 In scope

- A new spec document `spec/profiles/cidoc-bridge.md` declaring how OpenRiC servers MAY emit a CIDOC-CRM-shaped projection of their RiC-O graph.
- Property-level mappings between RiC-O 1.1 and CIDOC-CRM 7.1.x for the entity types covered by `core-discovery` (Records, Agents, Repositories) and `authority-context` (Places, Rules, Activities).
- A new endpoint `/api/ric/v1/{kind}/{id}/cidoc` that returns the same entity in CIDOC-CRM-equivalent JSON-LD (or Turtle / RDF/XML per content negotiation).
- SHACL shapes validating the CIDOC-CRM projection.
- One fixture per entity type pinning a canonical mapping output.

### 2.2 Out of scope

- Changes to RiC-O 1.1 itself — the bridge is a **projection**, not a remodelling.
- Spectrum-specific fields (those go in a future `OpenRiC-Spectrum` extension if pursued).
- Bidirectional CIDOC-CRM → RiC-O ingest (the inverse direction is left to per-institution import scripts).
- The full CIDOC-CRM hierarchy. The bridge covers the subset of E1-E70 / P1-P150 actually needed for the OpenRiC core profile data; further coverage is added as adopters request it.

## 3. Dependencies

- OpenRiC `core-discovery` profile (any v0.37+).
- CIDOC-CRM 7.1.3 or later (the version stable as of mid-2026).
- The Ionian group's RiC-CM ↔ CIDOC-CRM mapping work (Damigos et al., ICADL 2023). This proposal is **explicitly downstream** of that work and would be co-authored / co-attributed if the Ionian group is willing.

## 4. Worked example

A RiC-O Person record like:

```turtle
<.../agent/smuts-jc> a rico:Person ;
    rico:name "Smuts, Jan Christian" ;
    rico:hasBeginningDate "1870-05-24"^^xsd:date ;
    rico:hasEndDate "1950-09-11"^^xsd:date .
```

projects to CIDOC-CRM-equivalent form (illustrative — exact properties pending the bridge mapping):

```turtle
<.../agent/smuts-jc> a crm:E21_Person ;
    crm:P1_is_identified_by [
        a crm:E41_Appellation ;
        rdfs:label "Smuts, Jan Christian"
    ] ;
    crm:P98i_was_born [
        a crm:E67_Birth ;
        crm:P4_has_time-span [ a crm:E52_Time-Span ;
            crm:P82_at_some_time_within "1870-05-24"^^xsd:date ]
    ] ;
    crm:P100i_died_in [
        a crm:E69_Death ;
        crm:P4_has_time-span [ a crm:E52_Time-Span ;
            crm:P82_at_some_time_within "1950-09-11"^^xsd:date ]
    ] .
```

The two graphs describe the same person; an archive consumer reads the rico:* form, a museum / Linked.Art consumer reads the crm:* form, both consume from the same OpenRiC server.

## 5. Open questions

- **Q1.** Co-authorship with Damigos / Ionian — pursue or decline? Lead question for the [outreach](../outreach/damigos-second-implementation.md).
- **Q2.** Endpoint pattern — `/api/ric/v1/{kind}/{id}/cidoc` (separate URL) or content negotiation on the canonical entity URL with `Accept: application/ld+json; profile="https://www.cidoc-crm.org/cidoc-crm/"` (no separate URL)? The semantic-URI-vs-API-endpoint pattern documented in [`spec/viewing-api.md` §3.1](../../spec/viewing-api.html) prefers content negotiation; this proposal should follow that.
- **Q3.** SHACL coverage — full or partial? Full validation of the CIDOC-CRM output requires the CIDOC-CRM SHACL shapes themselves, which Linked.Art has begun publishing but are not stable. Start with OpenRiC-defined SHACL covering only the bridge-specific obligations (every projected E21_Person has a P1 appellation and so on); defer general CIDOC-CRM compliance.
- **Q4.** Bidirectional? Currently scoped one-way (RiC-O → CIDOC-CRM). The reverse direction is harder — CIDOC-CRM has more types of agent than RiC-O. Defer to a future `OpenRiC-CIDOC-Ingest` extension if there's demand.
- **Q5.** Linked.Art alignment — Linked.Art is a CIDOC-CRM profile widely used in art museums (J. Paul Getty, Yale, etc.). Should this bridge target raw CIDOC-CRM, or also Linked.Art? Probably raw CRM with a separate Linked.Art layer if pursued.

## 6. Why post-v1.0

The OpenRiC core spec is committed to v1.0 stability before any extension lands. The CIDOC-Bridge extension is one of three on the post-v1.0 roadmap, alongside OpenRiC-Rights (ODRL) and OpenRiC-Preservation (PREMIS-equivalent). Each represents a cross-domain bridge OpenRiC adopters have asked about; none is on the v1.0 critical path.

A pre-v1.0 strawman exists (this document) so the community can comment on direction. **No code lands until OpenRiC v1.0 is frozen.**

## 7. References

- Damigos, M., Mitrou, E., Sasse, M. A., et al. "RiC-CM ↔ CIDOC-CRM mapping." ICADL 2023. (Foundational mapping paper.)
- [Damigos / Ionian University Lab on Digital Libraries](https://dlib.ionio.gr/)
- [CIDOC-CRM 7.1.3](https://www.cidoc-crm.org/)
- [Linked.Art profile](https://linked.art/)
- OpenRiC [Related Implementations page](../../related-implementations.html) — Damigos / Ionian section
- OpenRiC [Outreach draft for Damigos](../outreach/damigos-second-implementation.md)
