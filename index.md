---
layout: default
title: OpenRiC
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">OpenRiC · v0.2.0 · 46 endpoints, OAI-PMH, API Explorer, conformance suite live</div>
    <h1>Records in Contexts, served over HTTP — implementation-neutral, IIIF-inspired.</h1>
    <p class="hero-lede">
      OpenRiC is an open specification for how archival descriptions map to RiC-CM / RiC-O, how that data is served over HTTP for both reading and writing, and how graph-based interfaces can render it consistently across any conformant server. Not a product. A contract anyone can implement.
    </p>
    <div class="hero-cta">
      <a class="btn-primary" href="guides/getting-started.html">Get started in 15 min →</a>
      <a class="btn-ghost" href="spec/">Read the spec ↗</a>
      <a class="btn-ghost" href="api-explorer/">Try the API ↗</a>
      <a class="btn-ghost" href="https://github.com/openric/spec/discussions">Discussions ↗</a>
    </div>
  </div>
</div>

<div class="plain-lede">
  <p><strong>In plain language:</strong> OpenRiC lets different archival systems publish, exchange, validate, and explore RiC-based archival data in a consistent way. It's a shared contract — like IIIF for images, but for archival description. Any system that implements it can be read, written to, and graph-walked the same way.</p>
</div>

## How the pieces fit together

<div class="boundary-grid">
  <div class="boundary-cell spec">
    <div class="boundary-label">Specification</div>
    <div class="boundary-title">OpenRiC</div>
    <p>Four documents, JSON Schemas, SHACL shapes, a 27-case fixture pack, an OpenAPI 3.0 contract, and a black-box conformance probe. CC-BY 4.0. Versioned; <code>v0.2.0</code> is current.</p>
    <div class="boundary-where"><a href="https://openric.org/">openric.org</a></div>
  </div>
  <div class="boundary-cell impl">
    <div class="boundary-label">Implementation</div>
    <div class="boundary-title">Reference API</div>
    <p>One Laravel service that implements the OpenRiC contract. Real archival data behind it. 46 endpoints across full 8-entity CRUD (Records, Agents, Places, Rules, Activities, Instantiations, Repositories, Functions), OAI-PMH, auto-generated OpenAPI. AGPL-3.0. Anyone can run their own.</p>
    <div class="boundary-where"><a href="https://ric.theahg.co.za/">ric.theahg.co.za</a></div>
  </div>
  <div class="boundary-cell tools">
    <div class="boundary-label">Clients</div>
    <div class="boundary-title">Viewer, Capture, Explorer</div>
    <p>Three pure-browser apps that talk to any conformant server — not just the reference. 2D + 3D graph rendering, data capture, Swagger UI. No privileged access; they use the same HTTP contract adopters see.</p>
    <div class="boundary-where"><a href="https://viewer.openric.org">viewer</a> · <a href="https://capture.openric.org">capture</a> · <a href="api-explorer/">api-explorer</a></div>
  </div>
  <div class="boundary-cell consumer">
    <div class="boundary-label">Operational consumer</div>
    <div class="boundary-title">Heratio</div>
    <p>An existing GLAM platform that consumes the Reference API over HTTP for every mutating admin action — no special shortcut. Proves the contract is sufficient for a real, production archive. Independent AGPL project.</p>
    <div class="boundary-where"><a href="https://heratio.theahg.co.za/">heratio.theahg.co.za</a></div>
  </div>
</div>

<div class="callout">
  <p><strong>If you only remember one thing:</strong> <em>OpenRiC is the contract; Heratio is one consumer of that contract.</em> The contract is deliberately designed so that any archival system — not just Heratio — can speak it.</p>
</div>

## Who is this for?

<div class="audience-grid">
  <a class="audience-card" href="guides/getting-started.html">
    <div class="audience-icon">🧑‍💻</div>
    <div class="audience-title">Developers</div>
    <p>You want to read data, write data, or build a client. Start with the 15-min walkthrough, then the API Explorer.</p>
    <div class="audience-next">Getting-started guide →</div>
  </a>
  <a class="audience-card" href="for-institutions.html">
    <div class="audience-icon">🏛️</div>
    <div class="audience-title">Institutions + decision-makers</div>
    <p>You're evaluating whether OpenRiC is worth adopting, requesting from vendors, or endorsing. Non-technical 3-min brief.</p>
    <div class="audience-next">Institutional brief →</div>
  </a>
  <a class="audience-card" href="spec/">
    <div class="audience-icon">📚</div>
    <div class="audience-title">Archivists + standards-adjacent</div>
    <p>You care about ISAD(G) / ISAAR / ISDF / ISDIAH → RiC mapping. Read the mapping doc first, then the graph primitives.</p>
    <div class="audience-next">Specification →</div>
  </a>
  <a class="audience-card" href="governance.html">
    <div class="audience-icon">🤝</div>
    <div class="audience-title">Implementers + contributors</div>
    <p>You want to build a conformant server, submit a spec change, or steward the project. See how governance + conformance work.</p>
    <div class="audience-next">Governance →</div>
  </a>
</div>

## Start here — evaluate OpenRiC in 5 minutes

<div class="evaluate-grid">
  <a class="evaluate-step" href="guides/getting-started.html">
    <div class="step-num">1</div>
    <div class="step-title">Read the 15-min walkthrough</div>
    <p>Zero to working integration: reads, writes, graph, harvest, embed.</p>
  </a>
  <a class="evaluate-step" href="demo/browse/">
    <div class="step-num">2</div>
    <div class="step-title">Browse the live data</div>
    <p>Full 8-entity CRUD (46 endpoints): Records, Agents, Places, Rules, Activities, Instantiations, Repositories, Functions.</p>
  </a>
  <a class="evaluate-step" href="demo/">
    <div class="step-num">3</div>
    <div class="step-title">Walk the graph</div>
    <p>Click any node to drill into its RiC-O neighbourhood. Same data, visual.</p>
  </a>
  <a class="evaluate-step" href="api-explorer/">
    <div class="step-num">4</div>
    <div class="step-title">Try the API</div>
    <p>Swagger UI over the OpenAPI 3.0 spec. "Try it out" on every endpoint with your own key.</p>
  </a>
  <a class="evaluate-step" href="conformance/">
    <div class="step-num">5</div>
    <div class="step-title">Probe a server for conformance</div>
    <p>Pure bash + jq. Point at any OpenRiC server; get a pass/fail report across every required endpoint.</p>
  </a>
  <a class="evaluate-step" href="spec/">
    <div class="step-num">6</div>
    <div class="step-title">Read the spec</div>
    <p>Four short documents: mapping, viewing API, graph primitives, conformance.</p>
  </a>
</div>

## Four public deployments

These are the four independently-hosted, separately-licensed, interoperable surfaces that make up the OpenRiC ecosystem. Any one of them can be replaced by a third-party implementation without touching the others — that is the point.

<div class="surfaces">
  <a class="surface-card" href="spec/">
    <span class="surface-icon">📖</span>
    <h3>Specification <span class="status-pill live">live</span></h3>
    <div class="url">openric.org</div>
    <p>Four documents, 19 JSON Schemas, SHACL shapes, 27-case fixture pack, validator CLI, conformance probe, OpenAPI 3.0 contract. CC-BY 4.0.</p>
  </a>
  <a class="surface-card" href="https://viewer.openric.org">
    <span class="surface-icon">🗺</span>
    <h3>Viewer <span class="status-pill live">live</span></h3>
    <div class="url">viewer.openric.org</div>
    <p>2D + 3D graph rendering for any conformant server. Drives Heratio's reference API <em>and</em> a non-Heratio static-fixture backend in the same page.</p>
  </a>
  <a class="surface-card" href="https://capture.openric.org">
    <span class="surface-icon">✍</span>
    <h3>Capture <span class="status-pill live">live</span></h3>
    <div class="url">capture.openric.org</div>
    <p>Pure-browser data-entry client. Paste a server URL + API key, create Places, Rules, Activities, Instantiations, relations.</p>
  </a>
  <a class="surface-card" href="https://ric.theahg.co.za/">
    <span class="surface-icon">🔌</span>
    <h3>Reference API <span class="status-pill live">live</span></h3>
    <div class="url">ric.theahg.co.za</div>
    <p>Independently-deployed Laravel service backed by a real archival database. 46 endpoints across read/write/OAI-PMH with full 8-entity CRUD, <code>X-API-Key</code> auth, auto-generated OpenAPI at <code>/api/ric/v1/openapi.json</code>. Also hosts a live RiC-CM reference navigator at <code>/reference/ric-cm/</code> — SPARQL-backed, declared-vs-inherited separation, versioned URLs.</p>
  </a>
</div>

## Pages on openric.org

These live inside the specification site itself — interactive tools, reference material, and evidence pages layered on top of the four deployments above.

<div class="surfaces">
  <a class="surface-card" href="api-explorer/">
    <span class="surface-icon">🧪</span>
    <h3>API Explorer <span class="status-pill live">live</span></h3>
    <div class="url">openric.org/api-explorer</div>
    <p>Interactive Swagger UI. Point at any OpenRiC server, paste an API key, try every endpoint live from the browser.</p>
  </a>
  <a class="surface-card" href="conformance/">
    <span class="surface-icon">✅</span>
    <h3>Conformance Suite <span class="status-pill live">live</span></h3>
    <div class="url">openric.org/conformance</div>
    <p>Black-box probe: point at any server, get a pass/fail report across every documented endpoint. Pure bash + jq.</p>
  </a>
  <a class="surface-card" href="demo/browse/">
    <span class="surface-icon">📇</span>
    <h3>Browse demo <span class="status-pill live">live</span></h3>
    <div class="url">openric.org/demo/browse</div>
    <p>Live catalogue view — cards, per-type filters, pagination. Points at any OpenRiC server; click-through to the graph viewer.</p>
  </a>
  <a class="surface-card" href="proof.html">
    <span class="surface-icon">🧾</span>
    <h3>Proof of implementation <span class="status-pill live">live</span></h3>
    <div class="url">openric.org/proof</div>
    <p>Real numbers, end-to-end walkthrough, ISAD(G)&nbsp;→&nbsp;RiC-O mapping, one live example per RiC-O type. The evidence the contract works.</p>
  </a>
  <a class="surface-card" href="profiles.html">
    <span class="surface-icon">🧩</span>
    <h3>Profiles <span class="status-pill live">v0.3-draft</span></h3>
    <div class="url">openric.org/profiles</div>
    <p>Named, bounded conformance targets. Implement the subset you can support — Core Discovery is the minimum. Five more profiles planned.</p>
  </a>
</div>

## Condensed roadmap

<div class="phases">
  <div class="phase-card done">
    <div class="phase-num">Phase 1</div>
    <h4>Spec v0.1.0 frozen <span class="status-pill live">done</span></h4>
    <p>Four documents, 12 JSON Schemas, 20-case fixture pack, validator CLI, CI green. Tagged &amp; published.</p>
  </div>
  <div class="phase-card done">
    <div class="phase-num">Phase 2</div>
    <h4>Beyond the reference <span class="status-pill live">done</span></h4>
    <p>Viewer on npm, capture client shipped, reference API split into its own deployment. Portability proven on both read and write sides.</p>
  </div>
  <div class="phase-card done">
    <div class="phase-num">Phase 2.5</div>
    <h4>Spec v0.2.0 frozen <span class="status-pill live">done</span></h4>
    <p>Agent + Record write endpoints, OAI-PMH v2.0, OpenAPI 3.0 spec + Swagger UI, conformance probe, self-service API key flow, getting-started walkthrough. Tagged 2026-04-18.</p>
  </div>
  <div class="phase-card done">
    <div class="phase-num">Phase 3</div>
    <h4>Proof + Profiles draft <span class="status-pill live">done</span></h4>
    <p><a href="proof.html">Proof-of-implementation page</a> with live numbers, 7-step use case, ISAD(G)→RiC-O mapping. <a href="profiles.html">Profiles framework</a> defining six named capability axes; <a href="spec/profiles/core-discovery.html">Core Discovery Profile v0.3-draft</a> normative doc landed for review. Tagged 2026-04-19.</p>
  </div>
  <div class="phase-card current">
    <div class="phase-num">Phase 4</div>
    <h4>Governance &amp; review <span class="status-pill pending">current</span></h4>
    <p>Invite external spec editors. Engage EGAD-adjacent reviewers on the Core Discovery draft's open questions. Ratify profile framework. Attract a second, non-reference implementation.</p>
  </div>
  <div class="phase-card done">
    <div class="phase-num">Phase 5</div>
    <h4>v0.3.0 freeze <span class="status-pill live">done</span></h4>
    <p>All 7 Core Discovery design questions resolved (Q6 RFC 7807 mandated and migrated in reference impl; ContactPoint shape pinned to <code>rico:ContactPoint</code>). Profile-scoped SHACL includes <code>:ContactPointShape</code>. Core Discovery Profile flipped from Draft to <strong>Normative</strong>. Tagged 2026-04-21.</p>
  </div>
  <div class="phase-card">
    <div class="phase-num">Phase 6+</div>
    <h4>Additional profiles &amp; v1.0 <span class="status-pill draft">planned</span></h4>
    <p>Define Authority &amp; Context, Provenance &amp; Event, Digital Object Linkage, Export-Only, Round-Trip Editing — each when an implementer is ready. Freeze <strong>v1.0</strong> when a second implementation passes conformance on any profile.</p>
  </div>
  <div class="phase-card">
    <div class="phase-num">Beyond v1.0</div>
    <h4>Extensions <span class="status-pill draft">planned</span></h4>
    <p>OpenRiC-Rights (ODRL). OpenRiC-Preservation (PREMIS-equivalent). Jurisdictional extensions — decoupled from the core.</p>
  </div>
</div>

## Read next

<div class="spec-docs">
  <a class="spec-doc" href="spec/">
    <strong>Specification</strong>
    <span>Four documents: mapping, viewing API, graph primitives, conformance.</span>
  </a>
  <a class="spec-doc" href="architecture.html">
    <strong>Architecture</strong>
    <span>How the four public deployments fit together and talk to each other.</span>
  </a>
  <a class="spec-doc" href="data-management.html">
    <strong>Data management</strong>
    <span>Where RiC data lives in the backing store. Green-field, AtoM retrofit, consumer-with-own-UI — three topologies, one contract.</span>
  </a>
  <a class="spec-doc" href="guides/">
    <strong>Guides</strong>
    <span>How to embed the viewer, use the capture client, and call the API from code.</span>
  </a>
  <a class="spec-doc" href="for-institutions.html">
    <strong>For institutions</strong>
    <span>3-min executive brief for directors, IT leads, and procurement officers.</span>
  </a>
  <a class="spec-doc" href="governance.html">
    <strong>Governance</strong>
    <span>Stewardship, change process, compatibility policy, how to contribute.</span>
  </a>
  <a class="spec-doc" href="demo/">
    <strong>Live demo</strong>
    <span>Open it, drag nodes, watch subjects expand into records.</span>
  </a>
</div>

## Engagement

Three seed Discussions are open — feedback of any shape is welcome.

- **[#1 · Announcement](https://github.com/openric/spec/discussions/1)** — the v0.1.0 introduction.
- **[#2 · Second-implementer questions](https://github.com/openric/spec/discussions/2)** — what would make it tractable to emit `/api/ric/v1/*` from your platform?
- **[#3 · Mapping sanity-check](https://github.com/openric/spec/discussions/3)** — where does the ISAD(G) → RiC-O mapping feel wrong to you?
- **[#4 · Progress update](https://github.com/openric/spec/discussions/4)** — capture app live, reference impl now a consumer of its own API.

## Licence

Specification: [Creative Commons Attribution 4.0](https://creativecommons.org/licenses/by/4.0/). Reference implementation, viewer, capture client: [GNU AGPL 3.0](https://www.gnu.org/licenses/agpl-3.0.html).

## Contact

Johan Pieterse — [johan@theahg.co.za](mailto:johan@theahg.co.za) · The Archive and Heritage Group (Pty) Ltd.
