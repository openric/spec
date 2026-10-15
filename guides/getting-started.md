---
layout: default
title: OpenRiC - Getting started
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Getting started</div>
    <h1>From zero to a working OpenRiC integration in 15 minutes</h1>
    <p class="hero-lede">You just landed on openric.org. This walks you through reading data from the public reference service, running a small server of your own, writing your first entities to it, checking it with the conformance probe, and embedding the viewer. Everything that writes runs against your own server, never the public one.</p>
  </div>
</div>

## What you'll need

- A terminal with `curl`, `jq`, `git` and Python 3 (`apt install jq` / `brew install jq`).
- About 15 minutes.

That's it. No framework, no build step, no signup, no API key for the public service.

> The public reference service is read-only for this tutorial. Commands that create, change or delete entities run against your own server, started in Step 3.

---

## Step 1 - Read something, no auth

OpenRiC reads are public. Confirm the reference server is up:

```bash
curl -s https://ric.theahg.co.za/api/ric/v1/health | jq
```

You should see `{"status":"ok", ...}`. The service description at `/` names the service's version and the specification version it verifies against.

Now fetch the first place:

```bash
curl -s "https://ric.theahg.co.za/api/ric/v1/places?limit=1" | jq '."openric:items"[0]'
```

That's a `rico:Place` in JSON-LD. Every list endpoint takes `?limit=` and `?page=`. Every show endpoint returns full RiC-O serialization. No key needed.

Other read endpoints to try:

```bash
# All agents (persons, corporate bodies, families)
curl -s "https://ric.theahg.co.za/api/ric/v1/agents?limit=5" | jq

# Subgraph walk - seeds the viewer
curl -s "https://ric.theahg.co.za/api/ric/v1/graph?uri=https://ric.theahg.co.za/informationobject/egyptian-boat&depth=2" | jq

# Harvester entrypoint (OAI-PMH v2.0, XML)
curl -s "https://ric.theahg.co.za/api/ric/v1/oai?verb=Identify"
```

The full catalogue is in the [API Explorer](https://ric.theahg.co.za/api/ric/v1/docs) - `Try it out` works on every endpoint.

---

## Step 2 - Explore interactively

Two in-browser tools:

- **[API Explorer](/api-explorer/)** (this site) - Swagger UI over any OpenRiC server. Paste a base URL + optional API key, click `Try it out`.
- **[Viewer](https://viewer.openric.org)** - 2D + 3D graph viewer. Pick a starting entity and drill through the RiC graph visually. Supports both the reference API and a bundled static fixture backend so you can see it working offline.

The viewer has a **Browse ▾** button that lists entities from whichever server you connect to. Use it when you don't know where to start. The reference service holds a [demonstration dataset](/explore.html#what-you-are-looking-at), not an institution's catalogue.

---

## Step 3 - Run your own server

The specification repository ships a [minimal server](https://github.com/openric/spec/tree/main/examples/minimal-server): one Python file, standard library only, with a small invented fonds in memory. It serves Core Discovery and takes writes, and everything you write is gone when you stop it.

```bash
git clone https://github.com/openric/spec
cd spec
python3 examples/minimal-server/server.py
```

Leave it running and open a second terminal in the same `spec` folder. Point the rest of this guide at it:

<!-- ci:sandbox:start -->
```bash
export OPENRIC_BASE=http://localhost:8080
export OPENRIC_KEY=example-write-key
curl -s "$OPENRIC_BASE/" | jq '.openric_conformance'
```

`example-write-key` is the minimal server's default; start it with `WRITE_KEY=...` to choose your own.

---

## Step 4 - Write your first entities

Create an agent, and keep the id the server assigns:

```bash
AGENT_ID=$(curl -s -X POST "$OPENRIC_BASE/agents" \
  -H "X-API-Key: $OPENRIC_KEY" -H "Content-Type: application/json" \
  -d '{"name":"Hendricks, Ada (my test agent)"}' | jq -r '.id')
echo "Agent id: $AGENT_ID"
```

Create a record with that agent as its creator:

```bash
REC_ID=$(curl -s -X POST "$OPENRIC_BASE/records" \
  -H "X-API-Key: $OPENRIC_KEY" -H "Content-Type: application/json" \
  -d "{\"title\":\"Letters to Ada (my test record)\",\"creator\":\"$AGENT_ID\",\"scope_and_content\":\"Created by the getting-started guide.\"}" | jq -r '.id')
echo "Record id: $REC_ID"
```

Read it back. The record now points at its creator with `rico:hasCreator`, and at the repository that holds it with `rico:hasOrHadHolder` - that is the context RiC is about:

```bash
curl -s "$OPENRIC_BASE/records/$REC_ID" | jq '{title: ."rico:title", creator: ."rico:hasCreator", holder: ."rico:hasOrHadHolder"}'
```

Change it, then see what the server says when something is wrong:

```bash
curl -s -X PATCH "$OPENRIC_BASE/records/$REC_ID" \
  -H "X-API-Key: $OPENRIC_KEY" -H "Content-Type: application/json" \
  -d '{"title":"Letters to Ada Hendricks (my test record)"}' | jq

# No key: 401, as an RFC 7807 problem document
curl -s -X POST "$OPENRIC_BASE/records" -H "Content-Type: application/json" -d '{"title":"x"}' | jq

# No title: 422
curl -s -X POST "$OPENRIC_BASE/records" -H "X-API-Key: $OPENRIC_KEY" \
  -H "Content-Type: application/json" -d '{}' | jq
```

Delete what you made, record first, because an agent that is still named as a creator cannot be deleted (409):

```bash
curl -s -X DELETE "$OPENRIC_BASE/records/$REC_ID" -H "X-API-Key: $OPENRIC_KEY" | jq
curl -s -X DELETE "$OPENRIC_BASE/agents/$AGENT_ID" -H "X-API-Key: $OPENRIC_KEY" | jq
```

The minimal server only takes writes on records and agents. The full write surface - every entity type, relations, file upload and the revision history - is the [Round-Trip Editing](/spec/profiles/round-trip-editing.html) profile, which the reference implementation ([openric/service](https://github.com/openric/service)) provides when you run your own copy of it.

---

## Step 5 - Probe a server

The conformance probe checks a server against the profiles it declares. Read-only, it is safe against any server; this checks your minimal server:

```bash
BASE=$OPENRIC_BASE bash conformance/probe.sh --profile=core-discovery
```
<!-- ci:sandbox:end -->

And this checks the public reference service, still read-only:

```bash
BASE=https://ric.theahg.co.za/api/ric/v1 bash conformance/probe.sh --profile=core-discovery
```

You'll get a pass, fail or skip line per check. Exit code 0 means every check for that profile passed. Add `KEY=...` only for a server whose data you may change; it then also runs the write, update and delete cycle. The [status page](/status/) shows the daily read-only run against the reference service.

---

## Step 6 - Write your own server

The minimal server is about 300 lines. Read it, then build yours: the [implementer guide](implement-a-server.html) walks through the contract, and [Core Discovery](/spec/profiles/core-discovery.html) is the profile to start with. Run the probe as you go; drop it into CI and you have a regression guard.

---

## Step 7 - Embed the viewer

Drop two script tags into any HTML page:

```html
<script type="importmap">
{ "imports": {
    "@openric/viewer":   "https://unpkg.com/@openric/viewer@0.2/dist/index.esm.js",
    "cytoscape":         "https://unpkg.com/cytoscape/dist/cytoscape.esm.min.js",
    "3d-force-graph":    "https://unpkg.com/3d-force-graph/dist/3d-force-graph.module.js"
}}
</script>
<div id="v" style="width:100%;height:500px;background:#111;"></div>
<script type="module">
  import { init2D } from '@openric/viewer';
  const base = 'https://ric.theahg.co.za/api/ric/v1';
  const graph = await fetch(`${base}/graph?uri=${base.replace('/api/ric/v1','')}/informationobject/egyptian-boat&depth=2`).then(r=>r.json());
  init2D(document.getElementById('v'), graph, {
    onNodeClick: n => console.log('clicked', n),
  });
</script>
```

No build step, no framework. Swap `init2D` for `init3D` if you want the 3-dimensional version. The [viewer guide](viewer.html) has the full API.

---

## Step 8 - Harvest via OAI-PMH

If you're an OAI harvester (ArchiveSpace, DPLA hub, institutional repository aggregator), point your harvester at:

```
https://ric.theahg.co.za/api/ric/v1/oai
```

Supports both `oai_dc` (Dublin Core) and `rico_ld` (RiC-O JSON-LD wrapped in CDATA) metadata prefixes. Records are segmented into sets by top-level fonds.

```bash
curl -s 'https://ric.theahg.co.za/api/ric/v1/oai?verb=ListMetadataFormats'
curl -s 'https://ric.theahg.co.za/api/ric/v1/oai?verb=ListRecords&metadataPrefix=oai_dc'
```

---

## Where to go from here

| You want to... | Read |
|---|---|
| Understand the data model | [Specification → Mapping](../spec/mapping.html) |
| Call the API from Python / JS | [API client guide](api.html) |
| Embed the viewer in a real app | [Viewer guide](viewer.html) |
| Let users capture data without building a UI | [Capture guide](capture.html) |
| See the surfaces wired together | [Architecture](../architecture.html) |
| Raise an issue or ask a question | [GitHub Discussions](https://github.com/openric/spec/discussions) |

---

## A note on AGPL

The reference implementation (API server, viewer, capture client, conformance probe, API explorer) is **AGPL-3.0-or-later**. You can run your own, fork it, modify it - but if you host a modified version publicly, you have to share your changes under the same licence.

The *specification* itself is **CC-BY 4.0**. Anyone can implement it under any licence. That's the point of a spec.

## Licence for this guide

CC-BY 4.0. Copy it, translate it, adapt it - just credit OpenRiC.
