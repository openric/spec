---
title: The modelling wizard
category: The clients
order: 2
summary: A guided, branching tool that turns a cataloguing decision into steps with rationale and live entity creation - plus an AI-assisted "describe your material" mode.
---

The **[modelling wizard](/wizard/)** (openric.org/wizard) teaches RiC by doing. See also [Modelling with the wizard](/help/modelling-with-the-wizard/) in *The model*.

## What you get per step

- a **prompt** (a real decision),
- **choices** with **why each fits or doesn't**,
- a **capture** - the actual API call, every field editable, run live,
- **branching** - different valid paths based on your answer.

## Two ways to use it

1. **Pick a scenario** - 21 worked examples. Eighteen are organised by material (magnetic tape, photographs, maps, oral history, registers, newspapers, family papers, email, web archives, …); three by modelling problem instead, and those apply whatever you hold - an unknown creator, a chain of custody, a closed record. Each is a citable, branching walkthrough.
2. **Describe your own material** - type a sentence; an AI proposes a model. Every entity code and relation is **validated against RiC-CM 1.0 before display**, so it never shows an invalid model. It proposes; you review it. (≈30s while it generates.)

## Live creation

The wizard shows, for every step, the exact requests that would create the records. Since 14 October 2026 it no longer sends them to the public reference service (`ric.theahg.co.za`): anonymous saving there was switched off, because entities created that way were written into a production database rather than an isolated sandbox. Use **Copy the requests** to keep your model, or set the server field to your own OpenRiC server and the wizard will create the records there.

## Accuracy

Scenarios are validated in CI (`bin/validate-scenarios.mjs`) for structure, branch integrity, valid relation codes, and **entity-code↔label consistency** - the same check that keeps "Place = RiC-E22" honest.

## Next

- [The RiC entities & relations](/help/entities-and-relations/)
- [Creating entities](/help/creating-data/) - the API behind the captures
