---
title: The RiC entities & relations
category: The model
order: 1
summary: The entity types you describe, the relations that connect them, and how to think about Record vs Record Set vs Record Part - with the live model navigator.
---

RiC describes archival material as **entities** joined by **relations**. Get these right and the rest follows.

## Entities you'll use most

| Entity | Code | Use it for |
|---|---|---|
| **Record** | RiC-E04 | One unit of recorded content (a letter, a recording, a file) |
| **Record Set** | RiC-E03 | An aggregation - fonds, series, collection, a run of volumes |
| **Record Part** | RiC-E05 | A component of a record (a track, a register entry, an attachment) |
| **Agent** | RiC-E07 | A creator/actor - **Person** (E08), **Family** (E10), **Corporate Body** (E11) |
| **Activity** | RiC-E15 | Something done - a business process, a recording session, a crawl |
| **Place** | RiC-E22 | A bounded, named location |
| **Instantiation** | RiC-E06 | A carrier of a record - the paper, the file, the print, the scan |
| **Rule** | RiC-E16 | A mandate, statute or retention policy governing records |

Browse every entity, attribute and relation in the **[RiC-CM navigator](https://ric.theahg.co.za/reference/ric-cm/)** - it shows **declared vs inherited** members so you always know where an attribute comes from.

## Record vs Record Set vs Record Part

The decision people ask about most:

- **Record Set** - an *aggregation* of records grouped by shared attributes (a fonds, a series, an album, a newspaper title).
- **Record** - a single unit of content (one letter, one photograph, one issue).
- **Record Part** - a *component* of one record with its own content (a track on a tape, an entry in a register, an attachment on an email). Parts carry their **own** creator, place, date and subject - which is how a single carrier holds mixed provenance.

The [modelling wizard](/wizard/) walks this decision on real material.

## Relations connect them

Relations are how RiC becomes a graph. The common ones (server relation codes):

| Relation code | Links | Meaning |
|---|---|---|
| `has_creator` | record → agent | who created it |
| `has_or_had_location` | record → place | where |
| `has_or_had_subject` | record → agent/concept | what it's about |
| `has_instantiation` | record → instantiation | its carrier(s) |
| `has_derived_instantiation` | instantiation → instantiation | a surrogate's lineage |
| `results_from` / `performed_by` | record → activity → agent | provenance chain |
| `is_child_of` / `has_family_member` | agent → agent | kinship |
| `is_regulated_by` | record → rule | governing mandate |

Per-entity provenance lives on **relations**, not on free-text fields - that's what makes it queryable.

## Next

- [Modelling with the wizard](/help/modelling-with-the-wizard/)
- [Creating data](/help/creating-data/) - turn this model into live entities
