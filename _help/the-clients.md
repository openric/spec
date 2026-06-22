---
title: The clients - viewer, capture, navigator
category: The clients
order: 1
summary: Three browser apps that talk to any conformant OpenRiC server - the 2D/3D graph viewer, the data-entry capture client, and the RiC-CM model navigator.
---

OpenRiC ships pure-browser clients that work against **any** conformant server, not just the reference - they use the same public HTTP contract adopters see.

## Viewer - [viewer.openric.org](https://viewer.openric.org/)

A 2D + 3D graph renderer. Point it at a server, click any node (record, agent, activity, place) to expand its neighbourhood. Drives the reference API *and* a non-Heratio static-fixture backend in the same page - proof the rendering is contract-driven, not implementation-specific.

## Capture - [capture.openric.org](https://capture.openric.org/)

A pure-browser data-entry client. Paste a server URL + API key, then create entities and relations directly from the browser. Good for quick authority/instantiation entry without a full admin UI.

## RiC-CM navigator - [ric.theahg.co.za/reference/ric-cm](https://ric.theahg.co.za/reference/ric-cm/)

The conceptual model itself, browsable: every entity, attribute and relation, with **declared vs inherited** clearly separated, and stable, citable, versioned URLs (e.g. `/reference/ric-cm/1.0/entities/RiC-E05`). The reference for "what does this entity actually carry?"

## Modelling wizard - [openric.org/wizard](/wizard/)

Guided, branching modelling that creates entities live - covered in [The modelling wizard](/help/the-modelling-wizard/).

## They're swappable

Each client is one box on the [system map](/help/system-map/) and can be replaced by a third-party tool speaking the same contract - that is the point of OpenRiC.

## Next

- [The modelling wizard](/help/the-modelling-wizard/)
- [Reading data](/help/using-the-api/)
