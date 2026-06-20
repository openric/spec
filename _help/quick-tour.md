---
title: A 5-minute tour
category: Getting started
order: 3
summary: Six things to try in five minutes — the wizard, the model navigator, the live graph, the API, the conformance probe, and the spec.
---

The fastest way to understand OpenRiC is to poke at the live surfaces. None of these need an account.

## 1. Model something in the wizard

Open the **[modelling wizard](/wizard/)**, pick a scenario (or describe your own material), and walk the decisions. It explains *why* each RiC entity fits, and creates the entities live. Start here — it teaches the model by doing.

## 2. Explore the model

Open the **[RiC-CM navigator](https://ric.theahg.co.za/reference/ric-cm/)** and click into an entity (say [Record Part](https://ric.theahg.co.za/reference/ric-cm/1.0/entities/RiC-E05)). Note the **declared vs inherited** attributes and relations.

## 3. Walk the live graph

Open the **[viewer](https://viewer.openric.org/)** against a real archival dataset. Click any node to expand its neighbourhood — same data, visual.

## 4. Call the API

```bash
curl -s https://ric.theahg.co.za/api/ric/v1/records | head
curl -s https://ric.theahg.co.za/api/ric/v1/health
```

Every read endpoint returns `application/ld+json`. See [Using the API](/help/using-the-api/).

## 5. Probe a server for conformance

```bash
BASE=https://ric.theahg.co.za/api/ric/v1 ./conformance/probe.sh
```

Pure bash + jq; points at any OpenRiC server and reports pass/fail across every required endpoint. See [Conformance & profiles](/help/conformance-and-profiles/).

## 6. Read the spec

Four short documents — [mapping, viewing API, graph primitives, conformance](/spec/) — plus the [profiles](/spec/profiles/).

## Where next

- Archivist? → [The RiC entities & relations](/help/entities-and-relations/)
- Developer? → [Using the API](/help/using-the-api/)
- Evaluating adoption? → [For institutions](/help/for-institutions/)
