---
layout: default
title: OpenRiC — Live Demo
---

<link rel="stylesheet" href="css/demo.css">

# Live Demo

This page runs **inside your browser** and fetches live RiC-O data from the reference API at [`ric.theahg.co.za/api/ric/v1`](https://ric.theahg.co.za/api/ric/v1/health) over the OpenRiC Viewing API. Nothing on `openric.org` proxies or caches — the spec site and the API are genuinely independent. That is the point.

> **About the reference backend.** [`ric.theahg.co.za/api/ric/v1`](https://ric.theahg.co.za/) is a standalone Laravel service backed by [Heratio](https://heratio.theahg.co.za)'s archival database. Heratio itself is a consumer of this API — every mutating admin action calls `/api/ric/v1/*` with an `X-API-Key`, same surface you're using here. No privileged shortcut.

<div class="demo-controls">
  <label for="demo-example">Try:</label>
  <select id="demo-example">
    <option value="https://heratio.theahg.co.za/informationobject/egyptian-boat">Egyptian Boat — RecordSet w/ subjects</option>
    <option value="https://heratio.theahg.co.za/informationobject/cat-in-arms">Cat in Arms — multilingual Record</option>
    <option value="https://heratio.theahg.co.za/actor/binneman-family">Binneman Family — Agent w/ creator events</option>
    <option value="https://heratio.theahg.co.za/actor/mobrey-family">Mobrey Family — Agent</option>
    <option value="https://heratio.theahg.co.za/place/912150">Egypt — Place</option>
  </select>

  <input id="demo-uri" type="text" placeholder="Or paste any Heratio entity URI…" />

  <span class="view-toggle">
    <button id="view-2d" class="active">2D</button>
    <button id="view-3d">3D</button>
  </span>

  <button id="demo-load">Load</button>

  <span id="demo-status" class="demo-status info">Ready.</span>
</div>

<div class="demo-stage">
  <div id="openric-graph"></div>

  <aside class="demo-side-panel">
    <h3>About this view</h3>
    <p>
      A 2-hop subgraph rooted at the URI you selected, served by
      <code>GET /api/ric/v1/graph?uri=&lt;uri&gt;&amp;depth=2</code>.
    </p>
    <p><strong>Click a node</strong> to see its RiC-O JSON-LD and the endpoint it was fetched from.</p>

    <h3>Selected node</h3>
    <div id="node-info">
      <p style="color:#6b7280;">No node selected.</p>
    </div>

    <h3>Source URI</h3>
    <div id="demo-source-uri" style="font-family: monospace; font-size: 0.8em; word-break: break-all;"></div>
  </aside>
</div>

<div class="demo-legend" id="demo-legend"></div>

### What the demo proves

- The **spec** (served by openric.org) and the **reference API** (served by ric.theahg.co.za) live on separate infrastructure.
- The viewer is ported straight from Heratio's UI and re-used here with a one-line adapter from `openric:Subgraph` → viewer's `{nodes, edges}`. Any other server implementing the OpenRiC Viewing API can swap in — same viewer, different backend.
- Every edge carries a canonical `rico:*` predicate as per [Graph Primitives §3.3](../spec/graph-primitives.html#33-edge).

---

<!-- Peer deps (the @openric/viewer npm package declares these as peerDeps). -->
<script src="https://unpkg.com/cytoscape@3.28.1/dist/cytoscape.min.js"></script>
<script src="https://unpkg.com/three@0.160.1/build/three.min.js"></script>
<script src="https://unpkg.com/three-spritetext@1.8.1/dist/three-spritetext.min.js"></script>
<script src="https://unpkg.com/3d-force-graph@1.73.3/dist/3d-force-graph.min.js"></script>

<!-- The viewer itself, loaded from the published npm package via CDN.
     This is the decoupling proof: openric.org no longer ships a viewer of its own. -->
<script src="https://unpkg.com/@openric/viewer@0.1/dist/openric-viewer.umd.js"></script>

<script>
(function () {
  'use strict';

  var API_BASE = 'https://ric.theahg.co.za/api/ric/v1';

  var exampleSelect = document.getElementById('demo-example');
  var uriInput      = document.getElementById('demo-uri');
  var loadButton    = document.getElementById('demo-load');
  var statusEl      = document.getElementById('demo-status');
  var graphEl       = document.getElementById('openric-graph');
  var nodeInfoEl    = document.getElementById('node-info');
  var sourceUriEl   = document.getElementById('demo-source-uri');
  var legendEl      = document.getElementById('demo-legend');
  var view2dBtn     = document.getElementById('view-2d');
  var view3dBtn     = document.getElementById('view-3d');

  var currentMode   = '2d';
  var currentGraph  = null;
  var lastPayload   = null;

  function setStatus(msg, cls) {
    statusEl.className = 'demo-status ' + (cls || 'info');
    statusEl.textContent = msg;
  }

  function renderLegend() {
    var types = ['RecordSet', 'Record', 'Person', 'CorporateBody', 'Family',
                 'Place', 'Production', 'Accumulation', 'Instantiation', 'Rule', 'Thing'];
    legendEl.innerHTML = types.map(function (t) {
      return '<span><span class="swatch" style="background:' +
             OpenricViewer.getColour(t) + '"></span>' + t + '</span>';
    }).join('');
  }

  function clearGraph() {
    if (currentGraph && typeof currentGraph.destroy === 'function') {
      try { currentGraph.destroy(); } catch (e) {}
    }
    graphEl.innerHTML = '';
    currentGraph = null;
  }

  function escapeHtml(s) {
    return String(s || '').replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function apiUrlForNode(data) {
    // Derive the matching /api/ric/v1/{entity} URL from the node's type + atomUrl + id.
    var id = data.id || '';
    var atomUrl = data.atomUrl || '';
    var type = data.type || '';
    var apiBase = 'https://ric.theahg.co.za/api/ric/v1';

    // Slug-based endpoints — pull slug from atomUrl.
    var slug = atomUrl ? atomUrl.replace(/^\/+/, '').split('/').pop() : '';

    // Id-based endpoints — pull numeric id from the canonical URI tail.
    var tailId = id.replace(/\/$/, '').split('/').pop();

    switch (type) {
      case 'RecordSet': case 'Record': case 'RecordPart':
        return slug ? apiBase + '/records/' + slug : null;
      case 'Person': case 'CorporateBody': case 'Family': case 'Agent':
        return slug ? apiBase + '/agents/' + slug : null;
      case 'Place':
        return /^\d+$/.test(tailId) ? apiBase + '/places/' + tailId : null;
      case 'Production': case 'Accumulation': case 'Activity':
        return /^\d+$/.test(tailId) ? apiBase + '/activities/' + tailId : null;
      case 'Rule':
        return /^\d+$/.test(tailId) ? apiBase + '/rules/' + tailId : null;
      case 'Instantiation':
        return /^\d+$/.test(tailId) ? apiBase + '/instantiations/' + tailId : null;
      default:
        return null;
    }
  }

  function onNodeClick(data) {
    // data may come from cytoscape (flat) or from ForceGraph3D (node object).
    var label = data.label || data.name || 'Unknown';
    var id = data.id || '';
    var type = data.type || '—';
    var atomUrl = data.atomUrl || '';
    var heratioHost = 'https://heratio.theahg.co.za';
    var archiveLink = atomUrl ? heratioHost + atomUrl : null;
    var jsonLdLink = apiUrlForNode(data);

    var html = '<div><strong>' + escapeHtml(label) + '</strong></div>' +
               '<div style="color:#6b7280; font-size:0.85em; margin:0.3rem 0;">' +
               'type: <code>' + escapeHtml(type) + '</code></div>';

    if (archiveLink) {
      html += '<div style="margin:0.5rem 0;"><a href="' + escapeHtml(archiveLink) +
              '" target="_blank" rel="noopener">↗ Open in archive</a></div>';
    }
    if (jsonLdLink) {
      html += '<div style="margin:0.4rem 0;"><a href="' + escapeHtml(jsonLdLink) +
              '" target="_blank" rel="noopener">↗ View JSON-LD</a></div>';
    }

    html += '<div style="margin-top:0.6rem; font-size:0.8em; color:#6b7280;">' +
            'Canonical <code>@id</code> (SPARQL subject IRI, not a browseable page):<br>' +
            '<span style="word-break:break-all; font-family:monospace;">' + escapeHtml(id) + '</span></div>';

    nodeInfoEl.innerHTML = html;
  }

  function render(payload) {
    clearGraph();

    if (currentMode === '3d') {
      currentGraph = OpenricViewer.init3D(graphEl, payload, { onNodeClick: onNodeClick });
      if (!currentGraph) {
        setStatus('✗ 3D viewer failed to initialise (see browser console)', 'err');
        return;
      }
    } else {
      currentGraph = OpenricViewer.init2D(graphEl, payload, { onNodeClick: onNodeClick });
      if (!currentGraph) {
        setStatus('✗ 2D viewer failed to initialise (see browser console)', 'err');
        return;
      }
    }

    var nodeCount = (payload['openric:nodes'] || payload.nodes || []).length;
    var edgeCount = (payload['openric:edges'] || payload.edges || []).length;
    setStatus('✓ Loaded ' + nodeCount + ' nodes / ' + edgeCount + ' edges', 'ok');
  }

  function load(uri) {
    if (!uri) return;
    setStatus('Fetching…', 'info');
    var url = API_BASE + '/graph?uri=' + encodeURIComponent(uri) + '&depth=2';
    sourceUriEl.textContent = url;
    fetch(url, { headers: { Accept: 'application/ld+json' } })
      .then(function (r) {
        if (!r.ok) throw new Error('HTTP ' + r.status);
        return r.json();
      })
      .then(function (payload) {
        lastPayload = payload;
        render(payload);
      })
      .catch(function (e) {
        setStatus('✗ Fetch failed: ' + e.message, 'err');
        console.error(e);
      });
  }

  function setMode(mode) {
    currentMode = mode;
    view2dBtn.classList.toggle('active', mode === '2d');
    view3dBtn.classList.toggle('active', mode === '3d');
    if (lastPayload) render(lastPayload);
  }

  loadButton.addEventListener('click', function () {
    var uri = uriInput.value.trim() || exampleSelect.value;
    load(uri);
  });
  uriInput.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') { e.preventDefault(); loadButton.click(); }
  });
  view2dBtn.addEventListener('click', function () { setMode('2d'); });
  view3dBtn.addEventListener('click', function () { setMode('3d'); });

  renderLegend();
  // First load — the first example.
  load(exampleSelect.value);
})();
</script>
