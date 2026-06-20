---
title: Glossary
category: Reference
order: 2
summary: Short definitions of the terms used across OpenRiC — RiC, RiC-CM, RiC-O, the entities, profiles, levels, instantiation, conformance, SHACL and more.
---

**RiC** — Records in Contexts; the ICA's model replacing ISAD(G), ISAAR(CPF), ISDF, ISDIAH.

**RiC-CM** — the RiC *Conceptual Model* (entities + relations). OpenRiC targets **1.0**.

**RiC-O** — the RiC *Ontology*; RiC-CM in OWL/RDF. OpenRiC is **RiC-O 1.1**-conformant.

**OpenRiC** — the open HTTP contract for publishing/exchanging RiC data; spec + reference API + clients.

**Record (RiC-E04)** — one unit of recorded content.

**Record Set (RiC-E03)** — an aggregation of records (fonds, series, collection).

**Record Part (RiC-E05)** — a component of a record, with its own content and provenance (a track, an entry, an attachment).

**Agent (RiC-E07)** — a Person (E08), Family (E10) or Corporate Body (E11) that creates or acts on records.

**Activity (RiC-E15)** — something done; a business process or event that produces records.

**Place (RiC-E22)** — a bounded, named location.

**Instantiation (RiC-E06)** — a physical or digital *carrier* of a record (the paper, the file, the print, a scan). One record can have many.

**Rule (RiC-E16)** — a mandate, law or retention policy governing records.

**Relation** — a typed link between entities (`has_creator`, `has_or_had_location`, …); how RiC becomes a graph.

**Profile** — a named, bounded conformance target a server can claim (Core Discovery, Export-Only, …). See the [profiles tree](/help/profiles-tree/).

**Level (L1–L4)** — how rigorously a profile's endpoints conform: L1 mapping, L2 API, L3 graph, L4 full.

**Conformance probe** — the bash + jq tool that tests a server against the spec.

**SHACL** — the shape language used to validate published RiC graphs; in the [Governance profile](/spec/profiles/governance.html) it's a merge gate.

**Instantiation vs Record** — the *content* is the Record; each *carrier* is an Instantiation. A scan is not a new record — it's another Instantiation.

**JSON-LD / Turtle / RDF-XML** — the interchangeable serialisations RiC data is exported in; they round-trip.

**OAI-PMH** — the standard harvest protocol aggregators use; the Export-Only profile exposes it.

## Next

- [The RiC entities & relations](/help/entities-and-relations/)
- [FAQ](/help/faq/)
