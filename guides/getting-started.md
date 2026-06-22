---
layout: default
title: OpenRiC - Getting started
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Getting started</div>
    <h1>From zero to a working OpenRiC integration in 15 minutes</h1>
    <p class="hero-lede">You just landed on openric.org. This walks you through reading data, getting an API key, writing your first entity, embedding the viewer, and verifying your own server - the whole stack, end to end, using the live reference deployment as the backend.</p>
  </div>
</div>

## What you'll need

- A terminal with `curl` and `jq` installed (`apt install jq` / `brew install jq`).
- An email address (for step 3, if you want to write data).
- About 15 minutes.

That's it. No framework, no build step, no signup unless you want to write.

---

## Step 1 - Read something, no auth

OpenRiC reads are public. Confirm the reference server is up:

```bash
curl -s https://ric.theahg.co.za/api/ric/v1/health | jq
```

You should see `{"status":"ok","service":"RIC-O Linked Data API","version":"1.0"}`.

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
curl -s "https://ric.theahg.co.za/api/ric/v1/graph?uri=https://ric.theahg.co.za/place/912324&depth=2" | jq

# Harvester entrypoint (OAI-PMH v2.0, XML)
curl -s "https://ric.theahg.co.za/api/ric/v1/oai?verb=Identify"
```

The full catalogue is in the [API Explorer](https://ric.theahg.co.za/api/ric/v1/docs) - `Try it out` works on every endpoint.

---

## Step 2 - Explore interactively

Two in-browser tools:

- **[API Explorer](/api-explorer/)** (this site) - Swagger UI over any OpenRiC server. Paste a base URL + optional API key, click `Try it out`.
- **[Viewer](https://viewer.openric.org)** - 2D + 3D graph viewer. Pick a starting entity and drill through the RiC graph visually. Supports both the reference API and a bundled static fixture backend so you can see it working offline.

The viewer has a **Browse ▾** button that lists real entities from whichever server you connect to. Use it when you don't know where to start.

---

## Step 3 - Get an API key (for writes)

Reads are free. To create, update, or delete entities you need an `X-API-Key`.

Request one at:

> **<https://ric.theahg.co.za/api/ric/v1/keys/request>**

Fill in your email + organization + a sentence describing what you plan to do with the key. An admin reviews; you'll get an email with the key within a business day.

Keys carry scopes (`read`, `write`, `delete`) and a rate limit. You can always ask for a scope bump later.

Running your own OpenRiC server? The exact same page ships on every conformant deployment - just swap the host.

---

## Step 4 - Write your first entity

Once you have a key, export it:

```bash
export OPENRIC_KEY=paste-your-key-here
export OPENRIC_BASE=https://ric.theahg.co.za/api/ric/v1
```

Create a `rico:Place`:

```bash
curl -s -X POST "$OPENRIC_BASE/places" \
  -H "X-API-Key: $OPENRIC_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"My First OpenRiC Place","description":"Created via the getting-started guide."}' | jq
```

You'll get back `{"id": 912999, "slug": "my-first-openric-place", "type": "place", "href": "/api/ric/v1/places/..."}`.

Read it back:

```bash
curl -s "$OPENRIC_BASE/places/912999" | jq
```

Delete it:

```bash
curl -s -X DELETE "$OPENRIC_BASE/places/912999" -H "X-API-Key: $OPENRIC_KEY" | jq
```

The same CRUD pattern works for `records`, `agents`, `rules`, `activities`, `instantiations`, and `relations`. See the [API Explorer](https://ric.theahg.co.za/api/ric/v1/docs) for full request / response schemas.

---

## Step 5 - Create a linked graph

The point of RiC is *context*. Create a `rico:Record`, attach an `rico:Instantiation` (e.g. a digital image), link them with a relation:

```bash
# 1. Create the Record
REC_ID=$(curl -s -X POST "$OPENRIC_BASE/records" \
  -H "X-API-Key: $OPENRIC_KEY" -H "Content-Type: application/json" \
  -d '{"title":"Test record","scope_and_content":"A demo record for the getting-started guide."}' | jq -r '.id')
echo "Record id: $REC_ID"

# 2. Upload an image + create an Instantiation
#    (one-shot via the capture client's "Attach image" wizard, or manually:)
URL=$(curl -s -X POST "$OPENRIC_BASE/upload" \
  -H "X-API-Key: $OPENRIC_KEY" \
  -F "file=@./my-image.jpg" | jq -r '.url')

INST_ID=$(curl -s -X POST "$OPENRIC_BASE/instantiations" \
  -H "X-API-Key: $OPENRIC_KEY" -H "Content-Type: application/json" \
  -d "{\"title\":\"Digital scan\",\"content_url\":\"$URL\",\"mime_type\":\"image/jpeg\"}" | jq -r '.id')

# 3. Link them
curl -s -X POST "$OPENRIC_BASE/relations" \
  -H "X-API-Key: $OPENRIC_KEY" -H "Content-Type: application/json" \
  -d "{\"subject_id\":$REC_ID,\"object_id\":$INST_ID,\"relation_type\":\"hasInstantiation\"}" | jq
```

Now view the subgraph:

```bash
curl -s "$OPENRIC_BASE/graph?uri=https://ric.theahg.co.za/recordset/$REC_ID&depth=2" | jq
```

Or click it in the [viewer](https://viewer.openric.org) - paste `/recordset/<your-id>` into the Start field and hit Load.

---

## Step 6 - Probe your own server

If you're running OpenRiC yourself (or evaluating whether a server conforms), run the conformance probe:

```bash
git clone https://github.com/openric/spec
BASE=https://your.server/api/ric/v1 \
KEY=your-write-key \
bash spec/conformance/probe.sh
```

You'll get a green/red report across every documented endpoint. Exit code 0 = conformant. Drop this into CI and you have a regression guard.

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
  const graph = await fetch(`${base}/graph?uri=${base.replace('/api/ric/v1','')}/place/912324&depth=2`).then(r=>r.json());
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
