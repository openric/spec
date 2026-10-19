---
layout: default
title: Explore
description: Browse an archival collection, follow the relationships between records, people, activities and places, and see worked examples - no setup, no API key.
permalink: /explore.html
---

# Explore

Three kinds of thing live under OpenRiC, and they are for different people. Public discovery needs no account and no key. The archivist workspace is planned. Developer tools are for people building or testing an implementation.

If you would rather be shown than go wandering, [OpenRiC in five minutes](/five-minutes/) follows a single object all the way through - catalogue record, the activities and laws around it, a 3D file, and a machine-readable export.

## Public discovery

Read-only. Nothing here can change the data.

<div class="task-cards">
  <a class="task-card" href="{{ '/demo/browse/' | relative_url }}">
    <div class="task-card-icon">📚</div>
    <div class="task-card-title">Browse a collection</div>
    <p>A catalogue view of the reference service's data - records, the people and organisations behind them, activities, places, rules and physical or digital versions. Search it, filter by type, open anything.</p>
    <span class="task-card-go">Open Browse →</span>
  </a>
  <a class="task-card" href="https://viewer.openric.org/">
    <div class="task-card-icon">🗺</div>
    <div class="task-card-title">Follow the graph</div>
    <p>The same data as a picture. Start at a record and walk outwards to its creator, the activity that produced it, where it happened and when - the connections archival description usually leaves implicit.</p>
    <span class="task-card-go">Open the Graph Explorer ↗</span>
  </a>
  <a class="task-card" href="{{ '/proof.html' | relative_url }}">
    <div class="task-card-icon">🔍</div>
    <div class="task-card-title">See the evidence</div>
    <p>What is running and what is still draft, with each example labelled as real, derived or synthetic demonstration data.</p>
    <span class="task-card-go">Read the proof →</span>
  </a>
</div>

### Three places to start

- **[Egyptian Boat](https://viewer.openric.org/?start=/informationobject/egyptian-boat)** - a record set with its places, repository, four activities and two laws around it. The [five-minute tour](/five-minutes/) walks through it.
- **[Gilded dining suite](https://viewer.openric.org/?start=/informationobject/gilded-dining-suite-ai-generated-3d-model)** - a record with a 3D model attached as a digital instantiation. The model was generated with AI by AHG; the record says so.
- **[Egypt](https://viewer.openric.org/?start=/place/912150)** - a place, seen from the other side: what refers to it.

All three are synthetic demonstration records.

## Archivist workspace - planned

Describing, arranging, reviewing and publishing records will happen in [OpenRiC Workspace](/application/), an application in development. It does not exist yet. Until it does, archivists can try modelling with the [modelling wizard](/wizard/), which shows the RiC requests a description would produce without saving anything to the public service.

## Developer tools

For implementers and testers. These need a server address, and some need an API key with write scope.

- The [API explorer](/api-explorer/) lists every endpoint and lets you try it.
- The [capture client](https://capture.openric.org/) creates and edits records on a server you have a key for.
- The [conformance probe](/conformance/) tests a server against a profile.
- Browse and the graph explorer can point at any conformant server; the server setting sits under **Developer tools** in Browse and **Advanced** in the viewer.

## What you are looking at

{% include evidence.html kind="demonstration" %}

The reference service reads the database of Heratio, the maintainers' archival platform. Much of what is there is demonstration and test material, and it is not a curated showcase, so expect some messy records. Where a page uses a record as evidence, it labels what kind of record it is.

If you want to understand *why* the data is shaped the way it is, that is the [model](/learn.html). If you want to publish your own this way, see [Developers](/for-developers.html).

If you are running your own implementation and want it listed, open a discussion on [the specification repository](https://github.com/openric/spec).
