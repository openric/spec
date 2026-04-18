---
layout: default
title: OpenRiC
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">OpenRiC · v0.2.0 · ~40 endpoints, OAI-PMH, API Explorer, conformance suite live</div>
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

## Four public surfaces

<div class="surfaces">
  <a class="surface-card" href="spec/">
    <span class="surface-icon">📖</span>
    <h3>Specification <span class="status-pill live">live</span></h3>
    <div class="url">openric.org</div>
    <p>Four documents, 12 JSON Schemas, SHACL shapes, 20-case conformance fixture pack, validator CLI. CC-BY 4.0.</p>
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
    <p>Independently-deployed Laravel service backed by a real archival database. ~40 endpoints across read/write/OAI-PMH, <code>X-API-Key</code> auth, auto-generated OpenAPI at <code>/api/ric/v1/openapi.json</code>.</p>
  </a>
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
</div>

<div class="callout">
  <p><strong>Noteworthy:</strong> the reference implementation consumes its own public API. <a href="https://heratio.theahg.co.za">Heratio</a> — the operational GLAM platform backing this ecosystem — calls <code>ric.theahg.co.za/api/ric/v1/*</code> for every mutating admin action, same surface any third-party client uses. No privileged shortcut. If the API is sufficient for Heratio, it's sufficient for anyone.</p>
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
  <div class="phase-card current">
    <div class="phase-num">Phase 3</div>
    <h4>Governance &amp; review <span class="status-pill pending">current</span></h4>
    <p>Invite external spec editors. Engage EGAD-adjacent reviewers. Attract a second, non-reference implementation. Freeze <strong>v1.0</strong> when one passes conformance.</p>
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
    <span>How the four public surfaces fit together and talk to each other.</span>
  </a>
  <a class="spec-doc" href="guides/">
    <strong>Guides</strong>
    <span>How to embed the viewer, use the capture client, and call the API from code.</span>
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
