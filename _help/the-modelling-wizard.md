---
title: The modelling wizard
category: The clients
order: 2
summary: A guided, branching tool that turns a cataloguing decision into steps with rationale and live entity creation — plus an AI-assisted "describe your material" mode.
---

The **[modelling wizard](/wizard/)** (openric.org/wizard) teaches RiC by doing. See also [Modelling with the wizard](/help/modelling-with-the-wizard/) in *The model*.

## What you get per step

- a **prompt** (a real decision),
- **choices** with **why each fits or doesn't**,
- a **capture** — the actual API call, every field editable, run live,
- **branching** — different valid paths based on your answer.

## Two ways to use it

1. **Pick a scenario** — 18 worked examples (magnetic tape, photographs, maps, oral history, registers, newspapers, family papers, email, web archives, …). Each is a citable, branching walkthrough.
2. **Describe your own material** — type a sentence; an AI proposes a model. Every entity code and relation is **validated against RiC-CM 1.0 before display**, so it never shows an invalid model. It proposes; you review and create. (≈30s while it generates.)

## Live creation

The wizard's captures create real entities against the configured server (default `ric.theahg.co.za`, currently open for input — no key). Created entities are sandbox-isolated from the live catalogue, so the demo doesn't pollute the archive.

## Accuracy

Scenarios are validated in CI (`bin/validate-scenarios.mjs`) for structure, branch integrity, valid relation codes, and **entity-code↔label consistency** — the same check that keeps "Place = RiC-E22" honest.

## Next

- [The RiC entities & relations](/help/entities-and-relations/)
- [Creating entities](/help/creating-data/) — the API behind the captures
