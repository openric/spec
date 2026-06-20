---
title: Modelling with the wizard
category: The model
order: 2
summary: The modelling wizard walks a real cataloguing decision step by step, explains why each entity fits, and creates the entities live — guided, or AI-assisted from your own description.
---

The **[modelling wizard](/wizard/)** is the fastest way to learn RiC modelling: it turns "how do I model this?" into a guided, branching walkthrough that creates the entities as you go.

## How it works

For each step the wizard gives you:

1. **A prompt** — a real decision (*"How do you represent the tape as a whole?"*).
2. **Choices** — the candidate entities, each with **why it fits / why it doesn't**.
3. **A capture** — the exact API call it produces, every field editable, run live.
4. **Branching** — your answer can change the path (a single letter → Record; a whole exchange → Record Set).

It ends in an assembled, citable model.

## Worked example: a magnetic tape

The flagship scenario models an ethnographic tape with mixed-provenance tracks:

1. The tape's content → **Record** (`POST /records`)
2. Each track → **Record Part** belonging to the tape (`POST /record-parts`, `parent_id` = the tape)
3. Each track's own creator → **Agent** + `has_creator` relation
4. The physical reel → **Instantiation**

Because per-track creators are relations on each Record Part, the tape carries genuinely mixed provenance.

## Describe your own material (AI-assisted)

The wizard has a **"describe your material"** box. Type something like *"a parish baptism register, 1881–1899, with hundreds of entries"* and it proposes a RiC model — every entity code and relation **validated against RiC-CM 1.0 before it's shown**, so it never suggests an invalid model. It proposes; you review and create. (Expect ~30s while the model thinks.)

## Sample capture (what a step sends)

```http
POST /api/ric/v1/record-parts
Content-Type: application/json

{ "title": "Track A — wedding songs, Epirus", "parent_id": 914120 }
```

## The library

There are 18 scenarios — magnetic tape, photographs, maps, oral history, registers, newspapers, family papers, email, web archives, and more. Pick one from the scenario dropdown.

## Next

- [The RiC entities & relations](/help/entities-and-relations/)
- [Creating data](/help/creating-data/) — the API behind the wizard's captures
