---
layout: default
title: OpenRiC — Live Demo
---

<link rel="stylesheet" href="css/demo.css">

# Live Demo

This page runs **inside your browser** and fetches live RiC-O data from the reference API at [`ric.theahg.co.za/api/ric/v1`](https://ric.theahg.co.za/api/ric/v1/health) over the OpenRiC Viewing API. Nothing on `openric.org` proxies or caches — the spec site and the API are genuinely independent. That is the point.

> **Prefer a catalogue view?** [/demo/browse/](browse/) renders the same data as a responsive card grid with per-type filters — useful for evaluating the shape of a dataset before drilling into the graph.

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

    // Drill into this node's subgraph — re-root the graph at the clicked entity.
    if (id) {
      uriInput.value = id;
      load(id);
    }
  }

  // Hover tooltip (v0.2.0 style — the demo predates the viewer package's own
  // tooltip support; this is a drop-in that works with whatever viewer version
  // unpkg currently resolves to).
  var tooltipEl = null;
  function ensureTooltip() {
    if (tooltipEl) return tooltipEl;
    tooltipEl = document.createElement('div');
    tooltipEl.setAttribute('role', 'tooltip');
    tooltipEl.style.cssText =
      'position:fixed; pointer-events:none; z-index:10000;' +
      'background:rgba(15,23,42,0.97); color:#e5e7eb;' +
      'border:1px solid #334155; border-radius:6px;' +
      'padding:0.55rem 0.75rem; font-size:0.82rem; line-height:1.4;' +
      'max-width:360px; box-shadow:0 4px 12px rgba(0,0,0,0.35);' +
      'font-family:system-ui,sans-serif; display:none;';
    document.body.appendChild(tooltipEl);
    return tooltipEl;
  }
  function renderTooltipHtml(node) {
    if (!node) return '';
    var shortType = node.type || 'Unknown';
    var ricoType = /^rico:|:\/\//.test(shortType) ? shortType : ('rico:' + shortType);
    var colour = OpenricViewer.getColour(node.type);
    var known = { id:1, label:1, name:1, type:1, color:1, colour:1, val:1, x:1, y:1, z:1, vx:1, vy:1, vz:1, fx:1, fy:1, fz:1, index:1, __indexColor:1, __threeObj:1, __lineObj:1 };
    var extras = '';
    Object.keys(node).forEach(function (k) {
      if (known[k]) return;
      var v = node[k]; if (v == null || v === '' || typeof v === 'object') return;
      extras += '<dt>' + escapeHtml(k) + '</dt><dd>' + escapeHtml(v) + '</dd>';
    });
    return '<div style="font-weight:600;font-size:0.92rem;margin-bottom:0.25rem;word-break:break-word;">' + escapeHtml(node.label || node.name || 'Unknown') + '</div>' +
      '<span style="display:inline-block;padding:0.05rem 0.45rem;border-radius:999px;font-size:0.7rem;margin-bottom:0.4rem;color:#fff;background:' + colour + ';">' + escapeHtml(shortType) + '</span>' +
      '<dl style="margin:0.3rem 0 0;display:grid;grid-template-columns:auto 1fr;gap:0.15rem 0.6rem;">' +
      '<dt style="color:#9ca3af;font-size:0.72rem;">RiC-O type</dt><dd style="margin:0;font-family:monospace;font-size:0.72rem;">' + escapeHtml(ricoType) + '</dd>' +
      '<dt style="color:#9ca3af;font-size:0.72rem;">id</dt><dd style="margin:0;font-family:monospace;font-size:0.72rem;word-break:break-all;">' + escapeHtml(node.id) + '</dd>' +
      (extras ? extras : '') +
      '</dl>' +
      '<div style="margin-top:0.45rem;color:#9ca3af;font-size:0.72rem;font-style:italic;">Click to drill into this node\'s subgraph</div>';
  }
  var lastMouse = { x: window.innerWidth/2, y: window.innerHeight/2 };
  window.addEventListener('mousemove', function (e) { lastMouse = { x: e.clientX, y: e.clientY }; });
  function showTooltip(node) {
    var el = ensureTooltip();
    el.innerHTML = renderTooltipHtml(node);
    el.style.display = 'block';
    var pad = 14, w = el.offsetWidth, h = el.offsetHeight;
    var x = lastMouse.x + pad, y = lastMouse.y + pad;
    if (x + w > window.innerWidth  - 10) x = lastMouse.x - w - pad;
    if (y + h > window.innerHeight - 10) y = lastMouse.y - h - pad;
    el.style.left = Math.max(4, x) + 'px';
    el.style.top  = Math.max(4, y) + 'px';
  }
  function hideTooltip() { if (tooltipEl) tooltipEl.style.display = 'none'; }

  function attachHover(instance, payload) {
    if (!instance) return;
    var nodeById = {};
    (payload['openric:nodes'] || payload.nodes || []).forEach(function (n) { nodeById[n.id] = n; });
    if (instance.on && typeof instance.on === 'function') {
      // cytoscape (2D)
      instance.on('mouseover', 'node', function (evt) {
        var id = evt.target.data('id');
        showTooltip(nodeById[id] || evt.target.data());
      });
      instance.on('mouseout', 'node', hideTooltip);
    } else if (typeof instance.onNodeHover === 'function') {
      // ForceGraph3D (3D)
      instance.onNodeHover(function (node) {
        if (node) showTooltip(nodeById[node.id] || node); else hideTooltip();
      });
    }
  }

  function render(payload) {
    clearGraph();

    hideTooltip();
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
    attachHover(currentGraph, payload);

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
