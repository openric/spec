---
layout: default
title: OpenRiC — Viewer guide
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Guide · Viewer</div>
    <h1>Embed the OpenRiC viewer</h1>
    <p class="hero-lede"><code>@openric/viewer</code> is a ~5 KB vanilla-JS library that renders any OpenRiC <code>openric:Subgraph</code> response as an interactive 2D or 3D graph. Works with or without a bundler; no framework; AGPL-3.0.</p>
    <div class="hero-cta">
      <a class="btn-primary" href="https://viewer.openric.org">Try the demo ↗</a>
      <a class="btn-ghost" href="https://www.npmjs.com/package/@openric/viewer">npm ↗</a>
      <a class="btn-ghost" href="https://github.com/openric/viewer">Source ↗</a>
    </div>
  </div>
</div>

## Quickest path — drop three script tags

```html
<!-- Peer deps (bring your own version if you're already using them) -->
<script src="https://unpkg.com/cytoscape@3"></script>
<script src="https://unpkg.com/three@0.160"></script>
<script src="https://unpkg.com/three-spritetext@1"></script>
<script src="https://unpkg.com/3d-force-graph@1"></script>

<!-- The viewer itself -->
<script src="https://unpkg.com/@openric/viewer@0.1/dist/openric-viewer.umd.js"></script>

<div id="my-graph" style="width:100%; height:500px;"></div>

<script>
  const { mount } = window.OpenricViewer;

  mount(document.getElementById('my-graph'), {
    server: 'https://ric.theahg.co.za/api/ric/v1',
    start: '/informationobject/egyptian-boat',
    mode: '2d',          // or '3d'
    depth: 2,
    onNodeClick: (node) => console.log('clicked:', node),
  });
</script>
```

That's the whole integration. The viewer handles fetching, rendering, layout, pan/zoom, click-to-drill, and responsive resize.

## Install via npm (bundler / framework)

```bash
npm install @openric/viewer
# peer deps — pick what you need
npm install cytoscape                         # for 2D
npm install 3d-force-graph three three-spritetext  # for 3D
```

```js
import { mount } from '@openric/viewer';
// or the lower-level primitives:
import { init2D, init3D, fetchSubgraph, getColour, COLOURS } from '@openric/viewer';
```

Peer deps aren't required upfront — `init2D` works with just `cytoscape`; `init3D` needs the three-graph trio. Try to load only what the user's chosen mode needs.

## Configuration

The `mount(element, config)` call accepts:

| Option | Type | Default | What it does |
|---|---|---|---|
| `server` | `string` (required) | — | Base URL for the OpenRiC API, e.g. `https://ric.theahg.co.za/api/ric/v1`. Relative paths like `/api/static-ric` resolve against `window.location.origin`. |
| `start` | `string` (required) | — | Root URI to draw. Can be a full URL (`https://…/informationobject/slug`) or a path (`/informationobject/slug`). |
| `mode` | `'2d' \| '3d'` | `'2d'` | Rendering engine. 2D is cytoscape (fast, readable). 3D is ForceGraph3D (WebGL, spatial). |
| `depth` | `number` | `2` | How many hops out from `start` to pull. Server side enforces a max. |
| `onNodeClick` | `function(node)` | — | Called with the clicked node's data. Use this to drill down (call `handle.setRoot(newUri)`) or open your own side panel. |
| `libs` | `{ cytoscape?, ForceGraph3D?, SpriteText? }` | reads from `window` | Inject specific library instances instead of relying on globals. Useful in module-only builds. |

`mount()` returns a **handle** with three methods:

- `handle.setRoot(uri)` — re-render at a new root URI without unmounting/remounting. Used for drill-through.
- `handle.setMode('2d' \| '3d')` — switch rendering engine.
- `handle.unmount()` — tear down cytoscape / ForceGraph3D and clear the container.

## Driving it from your own UI

You probably want to keep your own controls (dropdown of example URIs, mode toggle, search field). Common pattern:

```js
const handle = mount(el, { server: API, start: initialUri, onNodeClick });

// your own "Load" button
myButton.addEventListener('click', () => handle.setRoot(uriInput.value));

// your own 2D/3D toggle
modeRadios.forEach(r => r.addEventListener('change', () => handle.setMode(r.value)));

function onNodeClick(node) {
  // update your breadcrumb / side panel / whatever
  myInfoPanel.textContent = `${node.label} (${node.type})`;
  // then drill
  handle.setRoot(node.id.replace(/^https?:\/\/[^/]+/, ''));
}
```

## Making the viewer work against *any* server

The viewer doesn't care who serves the subgraph, as long as the response is shape-correct. Three ways to point it elsewhere:

1. **Another OpenRiC-conformant server** — set `server` to their `/api/ric/v1` base URL.
2. **A service worker that fakes a server** — `viewer.openric.org` does this for its "Static fixtures" demo backend. The SW intercepts `/api/static-ric/*` and replays fixture JSON from the conformance pack. Useful for demos + offline / CI use.
3. **A runtime JSON blob** — call `init2D(element, subgraphObject, {onNodeClick})` directly, bypassing `mount()`'s fetch step. The `subgraphObject` just needs `{"openric:nodes":[...], "openric:edges":[...]}`.

## CSS + sizing

The viewer fills its container. Give the container explicit dimensions (`height` in particular — cytoscape and ForceGraph3D both need a non-zero height to render).

```css
#my-graph { width: 100%; height: 60vh; background: #0f172a; border-radius: 8px; }
```

Dark backgrounds look best — the node colours (see `COLOURS`) are picked for contrast against slate-900.

## Colours and types

Every node's colour is derived from its RiC-O type (`rico:Place`, `rico:Person`, …). Access the palette:

```js
import { COLOURS, getColour } from '@openric/viewer';

COLOURS.Place       // '#fd7e14'
getColour('rico:Person')  // '#dc3545'
getColour('https://www.ica.org/standards/RiC/ontology#Person')  // same
```

Use these to build a legend that always matches the rendered graph.

## Hover tooltips (demo-level, not in the package)

The viewer package exposes the underlying cytoscape/ForceGraph3D instance (returned by `init2D`/`init3D`). The [`viewer.openric.org`](https://viewer.openric.org) demo uses that to attach rich hover tooltips with RiC-O type + extras. Source is in `github.com/openric/viewer/docs/index.html` — copy the tooltip DOM + `attachHoverForCy` / `attachHoverForForceGraph` helpers verbatim if you want the same.

## Versioning

- `0.1.0` — initial npm release
- `0.1.1` — fix `fetchSubgraph` for relative server bases
- Next (`0.1.2` or `0.2.0`) — pending tag; tracks `main` at [github.com/openric/viewer](https://github.com/openric/viewer)

Breaking changes bump the minor; API stability is informally maintained within a minor line.

## Licence

AGPL-3.0-or-later. Same as the reference implementation. Source at [github.com/openric/viewer](https://github.com/openric/viewer).
