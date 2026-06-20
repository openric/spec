---
title: What is Records in Contexts?
category: Getting started
order: 1
summary: RiC is the ICA's model that connects records to the people, activities, places and dates around them — replacing four older standards with one linked picture.
---

**Records in Contexts (RiC)** is the International Council on Archives' next-generation model for archival description. It replaces four separate standards — **ISAD(G)** (records), **ISAAR(CPF)** (creators), **ISDF** (functions) and **ISDIAH** (institutions) — with a single, connected model.

## The shift: from documents to a graph

The older standards described records, their creators, the functions they served, and their holding institutions as **separate documents**. RiC treats them as **one connected web** of entities joined by relationships.

So instead of describing a fonds in isolation, you describe the record *and* who created it *and* the activity that produced it *and* where and when — and the links between them all. That lets you ask questions a flat catalogue cannot answer:

- *everything this person created or touched*
- *every record produced by this activity*
- *how these two collections relate*

## The building blocks

RiC is built from a small set of entity types. The ones you meet most:

| Entity | RiC-CM code | What it is |
|---|---|---|
| Record | RiC-E04 | The unit of recorded content |
| Record Set | RiC-E03 | An aggregation — fonds, series, collection |
| Record Part | RiC-E05 | A component of a record (a track, an entry, an attachment) |
| Agent | RiC-E07 | A Person (E08), Family (E10) or Corporate Body (E11) |
| Activity | RiC-E15 | Something done — a business process, an event |
| Place | RiC-E22 | A bounded, named location |
| Instantiation | RiC-E06 | A physical/digital carrier of a record |
| Rule | RiC-E16 | A mandate, law or policy that governs records |

Browse them all, with their attributes and relations, in the live **[RiC-CM navigator](https://ric.theahg.co.za/reference/ric-cm/)**.

## Two layers: RiC-CM and RiC-O

- **RiC-CM** — the *conceptual model* (the entities and relations above).
- **RiC-O** — the *ontology*: RiC-CM expressed in OWL/RDF so it can be published as linked data.

OpenRiC targets **RiC-CM 1.0 / RiC-O 1.1**.

## Next

- [What is OpenRiC?](/help/what-is-openric/) — how OpenRiC turns RiC into a working contract.
- [The RiC entities & relations](/help/entities-and-relations/) — the model in practical detail.
- Try the [modelling wizard](/wizard/) to see RiC applied to real material.
