---
layout: default
title: OpenRiC system map
description: How the OpenRiC pieces fit together - the specification, the reference API, the browser clients, the modelling wizard, and the consumers - as one navigable diagram.
permalink: /help/system-map/
---

<style>
  .diagram-wrap { border: 1px solid var(--border); border-radius: 10px; background: var(--surface); overflow: hidden; margin: 1rem 0; }
  .diagram-wrap .mermaid { padding: 1rem; height: 420px; background: var(--bg); color: var(--fg); }
  .diagram-wrap .mermaid svg { width: 100%; height: 100%; max-width: none; display: block; touch-action: none; }
  .diagram-hint { font-size: .85rem; color: var(--muted); margin: .4rem 0 0; }
  .legend { font-size: .9rem; color: var(--muted-2); }
</style>

<p style="font-size:.85rem;color:var(--muted);"><a href="{{ '/help/' | relative_url }}">← Help home</a></p>

# System map

<p class="legend">OpenRiC is a set of independently-deployed, interoperable surfaces around one open contract. <strong>Scroll/drag to pan, use the controls to zoom, and click any node to open it.</strong></p>

<div class="diagram-wrap">
<pre class="mermaid">
flowchart TB
  classDef spec fill:#eff4fb,stroke:#1f5fa8,color:#0f3e75;
  classDef impl fill:#eafaf1,stroke:#10b981,color:#065f46;
  classDef client fill:#fff7ed,stroke:#f59e0b,color:#92400e;
  classDef consumer fill:#f3effd,stroke:#8b5cf6,color:#5b21b6;

  subgraph S [Specification - openric.org]
    SPEC["📖 Spec documents<br/>mapping · viewing API · graph primitives"]:::spec
    PROF["🧩 Profiles<br/>12 conformance targets"]:::spec
    SHAPES["✅ JSON Schemas + SHACL"]:::spec
  end

  subgraph I [Reference implementation - ric.theahg.co.za]
    API["🔌 Reference API<br/>/api/ric/v1 · 8-entity CRUD · OAI-PMH"]:::impl
    SPARQL["🔎 SPARQL endpoint"]:::impl
    NAV["🧭 RiC-CM navigator<br/>/reference/ric-cm"]:::impl
  end

  subgraph C [Browser clients]
    VIEW["🗺 Viewer<br/>2D/3D graph"]:::client
    CAP["✍ Capture<br/>data entry"]:::client
    WIZ["🧙 Modelling wizard<br/>guided + AI-assisted"]:::client
  end

  HER["🏛 Heratio<br/>production consumer"]:::consumer
  AGG["📡 Aggregators / RAG agents"]:::consumer

  SPEC --> API
  PROF --> API
  SHAPES --> API
  API --> VIEW
  API --> CAP
  API --> NAV
  WIZ --> API
  API --> HER
  SPARQL --> AGG
  API --> AGG

  click SPEC "/spec/" "Read the specification"
  click PROF "/spec/profiles/" "Conformance profiles"
  click NAV "https://ric.theahg.co.za/reference/ric-cm/" "RiC-CM navigator"
  click VIEW "https://viewer.openric.org/" "Graph viewer"
  click CAP "https://capture.openric.org/" "Capture client"
  click WIZ "/wizard/" "Modelling wizard"
  click API "/help/using-the-api/" "Using the API"
  click HER "https://heratio.theahg.co.za/" "Heratio"
</pre>
</div>
<p class="diagram-hint">Diagram renders with Mermaid. If it doesn't load, the same structure is described in <a href="{{ '/for-developers.html' | relative_url }}">For developers → how the pieces fit together</a>.</p>

## In words

- The **Specification** (openric.org) defines the contract: the mapping documents, the [profiles](/spec/profiles/), and the JSON Schemas + SHACL shapes that make conformance testable.
- The **Reference API** (ric.theahg.co.za) implements that contract over real archival data - read/write CRUD for all eight RiC entity types, SPARQL, OAI-PMH, and the SPARQL-backed [RiC-CM navigator](https://ric.theahg.co.za/reference/ric-cm/).
- The **clients** - [viewer](https://viewer.openric.org/), [capture](https://capture.openric.org/), and the [modelling wizard](/wizard/) - are pure-browser apps that talk to *any* conformant server, not just the reference.
- **Consumers** - Heratio (a production GLAM platform) and aggregators / RAG agents - use the same public contract; no privileged back door.

The point of the diagram: every box can be replaced by a third-party implementation of the same contract without touching the others.

<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/svg-pan-zoom@3.6.1/dist/svg-pan-zoom.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/hammerjs@2.0.8/hammer.min.js"></script>
<script>
  // svg-pan-zoom has no built-in touch support, so two-finger pinch/pan on mobile
  // needs Hammer.js wired through a custom events handler (the library's own mobile
  // recipe). Touch coexists with the default mouse-wheel/drag handlers on desktop.
  var mobileEventsHandler = {
    haltEventListeners: ['touchstart', 'touchend', 'touchmove', 'touchleave', 'touchcancel'],
    init: function (options) {
      var instance = options.instance, initialScale = 1, pannedX = 0, pannedY = 0;
      this.hammer = Hammer(options.svgElement, {
        inputClass: Hammer.SUPPORT_POINTER_EVENTS ? Hammer.PointerEventInput : Hammer.TouchInput
      });
      this.hammer.get('pinch').set({ enable: true });
      this.hammer.on('doubletap', function () { instance.zoomIn(); });
      this.hammer.on('panstart panmove', function (ev) {
        if (ev.type === 'panstart') { pannedX = 0; pannedY = 0; }
        instance.panBy({ x: ev.deltaX - pannedX, y: ev.deltaY - pannedY });
        pannedX = ev.deltaX; pannedY = ev.deltaY;
      });
      this.hammer.on('pinchstart pinchmove', function (ev) {
        if (ev.type === 'pinchstart') { initialScale = instance.getZoom(); }
        instance.zoomAtPoint(initialScale * ev.scale, { x: ev.center.x, y: ev.center.y });
      });
      options.svgElement.addEventListener('touchmove', function (e) { e.preventDefault(); });
    },
    destroy: function () { this.hammer.destroy(); }
  };
  mermaid.initialize({ startOnLoad: false, securityLevel: 'loose', theme: 'neutral' });
  mermaid.run({ querySelector: '.mermaid' }).then(function () {
    document.querySelectorAll('.diagram-wrap svg').forEach(function (svg) {
      // Mermaid 10 pins the SVG small via an inline max-width and leaves height auto;
      // svg-pan-zoom then can't resolve a real size and the diagram collapses into the
      // top-left corner. Force the SVG to fill its sized container before initialising.
      svg.removeAttribute('width');
      svg.removeAttribute('height');
      svg.style.maxWidth = 'none';
      svg.style.width = '100%';
      svg.style.height = '100%';
      if (window.svgPanZoom) {
        try {
          var pz = svgPanZoom(svg, {
            controlIconsEnabled: true, fit: true, center: true, minZoom: 0.4, contain: true,
            customEventsHandler: (window.Hammer ? mobileEventsHandler : undefined)
          });
          requestAnimationFrame(function () { pz.resize(); pz.fit(); pz.center(); });
        } catch (e) {}
      }
    });
  });
</script>
