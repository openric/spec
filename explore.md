---
layout: default
title: Explore
description: Open a real archival collection, follow the relationships between records, people, activities and places, and see worked examples - no setup, no API key.
permalink: /explore.html
---

# Explore

Everything here runs against live data. Nothing needs an account, a server address or an API key.

<div class="task-cards">
  <a class="task-card" href="{{ '/demo/browse/' | relative_url }}">
    <div class="task-card-icon">📚</div>
    <div class="task-card-title">Browse a collection</div>
    <p>A catalogue view of a real archival dataset - records, the people and organisations behind them, activities, places, rules and physical or digital versions. Search it, filter by type, open anything.</p>
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
    <p>Which parts are real and running, backed by an operating archival service with multi-jurisdiction holdings and live digital objects - and which parts are still draft.</p>
    <span class="task-card-go">Read the proof →</span>
  </a>
</div>

## What you are looking at

The data behind these tools is a working archive, not a demonstration fixture. That matters, because archival description only gets interesting where it is messy: records with more than one creator, custody that changed hands, a digitised copy that is not the original, an activity nobody recorded at the time.

If you want to understand *why* the data is shaped the way it is, that is the [model](/learn.html). If you want to publish your own this way, that is [Build](/for-developers.html).

## Connect your own server

Both tools are implementation-neutral - they talk to any conformant OpenRiC server, not just this one. Server selection lives under **Advanced** in each tool, because it is the thing almost nobody needs on a first visit.

If you are running your own implementation and want it listed, open a discussion on [the specification repository](https://github.com/openric/spec).
