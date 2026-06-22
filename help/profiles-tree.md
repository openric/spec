---
layout: default
title: OpenRiC profiles tree
description: The OpenRiC conformance profiles as a capability tree - seven normative, five draft - each a named, bounded target a server can claim. Click any profile to read it.
permalink: /help/profiles-tree/
---

<style>
  .diagram-wrap { border: 1px solid var(--border); border-radius: 10px; background: var(--surface); overflow: hidden; margin: 1rem 0; }
  .diagram-wrap .mermaid { padding: 1rem; height: 460px; background: var(--bg); color: var(--fg); }
  .diagram-wrap .mermaid svg { width: 100%; height: 100%; max-width: none; display: block; touch-action: none; }
  .legend { font-size: .9rem; color: var(--muted-2); }
</style>

<p style="font-size:.85rem;color:var(--muted);"><a href="{{ '/help/' | relative_url }}">← Help home</a></p>

# Profiles tree

<p class="legend">A <strong>profile</strong> is a named, bounded conformance target - a server declares which it supports and consumers know exactly what to expect. Profiles are additive, not hierarchical. <strong>Click any profile to open its specification; drag to pan, controls to zoom.</strong></p>

<div class="diagram-wrap">
<pre class="mermaid">
flowchart LR
  classDef norm fill:#eafaf1,stroke:#10b981,color:#065f46;
  classDef draft fill:#fff7ed,stroke:#f59e0b,color:#92400e;
  ROOT([OpenRiC conformance]):::norm

  subgraph N [Normative]
    CD["Core Discovery<br/>read records, agents, vocab"]:::norm
    AC["Authority &amp; Context<br/>places, rules, activities"]:::norm
    GT["Graph Traversal<br/>/graph · /relations · /hierarchy"]:::norm
    DOL["Digital Object Linkage<br/>instantiations · functions"]:::norm
    RTE["Round-Trip Editing<br/>POST/PATCH/DELETE + audit"]:::norm
    PE["Provenance &amp; Event<br/>activity shapes"]:::norm
    EX["Export-Only<br/>OAI-PMH · JSON-LD/Turtle"]:::norm
  end

  subgraph D [Draft - v0.43 governance line]
    SP["SPARQL Access<br/>read-only /sparql"]:::draft
    GOV["Governance<br/>IRI policy · SHACL gate"]:::draft
    PORT["Portability<br/>round-trip · DCAT/VoID"]:::draft
    IP["Inferred-Provenance<br/>AI vs documented fact"]:::draft
    GG["Graph-Grounding<br/>/ground for RAG"]:::draft
  end

  ROOT --> CD --> AC --> GT --> DOL --> RTE --> PE --> EX
  ROOT --> SP
  GOV --> PORT
  GOV --> IP
  CD --> GG

  click CD "/spec/profiles/core-discovery.html"
  click AC "/spec/profiles/authority-context.html"
  click GT "/spec/profiles/graph-traversal.html"
  click DOL "/spec/profiles/digital-object-linkage.html"
  click RTE "/spec/profiles/round-trip-editing.html"
  click PE "/spec/profiles/provenance-event.html"
  click EX "/spec/profiles/export-only.html"
  click SP "/spec/profiles/sparql-access.html"
  click GOV "/spec/profiles/governance.html"
  click PORT "/spec/profiles/portability.html"
  click IP "/spec/profiles/inferred-provenance.html"
  click GG "/spec/profiles/graph-grounding.html"
</pre>
</div>

## The profiles

**Normative (claimable today):**

- **Core Discovery** - read-only records, agents, repositories, vocabulary, autocomplete. The minimum "I can be queried" claim.
- **Authority & Context** - places, rules, activities as first-class entities.
- **Graph Traversal** - `/graph`, `/relations`, `/hierarchy` cross-entity walks.
- **Digital Object Linkage** - instantiations (carriers) + ISDF functions.
- **Round-Trip Editing** - the full write surface with an audit trail.
- **Provenance & Event** - tightened activity shapes (results, participants, dates).
- **Export-Only** - OAI-PMH harvest + per-record JSON-LD / Turtle / RDF-XML.

**Draft (open for comment):**

- **SPARQL Access** - a read-only SPARQL 1.1 endpoint.
- **Governance** - pinned standards, the two-layer IRI policy, deprecate-not-delete, SHACL as a merge gate.
- **Portability** - lossless round-trip + a DCAT/VoID dataset descriptor + validate-on-export.
- **Inferred-Provenance** - AI-asserted edges are visibly distinguishable from documented fact.
- **Graph-Grounding** - a `/ground` endpoint so RAG agents disambiguate against the graph.

See [Conformance & profiles](/help/conformance-and-profiles/) for how to claim and test them.

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
