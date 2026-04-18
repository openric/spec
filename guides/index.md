---
layout: default
title: OpenRiC — Guides
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Guides</div>
    <h1>Use OpenRiC, don't just read about it</h1>
    <p class="hero-lede">Practical how-tos for the three public tools in the OpenRiC ecosystem — the viewer you embed, the capture client you paste a key into, and the reference API you POST to.</p>
  </div>
</div>

<div class="surfaces">
  <a class="surface-card" href="viewer.html">
    <span class="surface-icon">🗺</span>
    <h3>Viewer guide</h3>
    <p>Embed <code>@openric/viewer</code> in your own page, in any framework or none, driving any OpenRiC-conformant server.</p>
  </a>
  <a class="surface-card" href="capture.html">
    <span class="surface-icon">✍</span>
    <h3>Capture guide</h3>
    <p>Walkthrough of <a href="https://capture.openric.org">capture.openric.org</a> — connect to a server, mint a key, create entities, link relations.</p>
  </a>
  <a class="surface-card" href="api.html">
    <span class="surface-icon">🔌</span>
    <h3>API client guide</h3>
    <p>How to call <code>/api/ric/v1/*</code> from <code>curl</code>, Python, JavaScript, or any HTTP-speaking tool. Auth, pagination, errors.</p>
  </a>
</div>

## Before you dive in

If you haven't yet, the two-page orientation pieces are [**Home**](../) (what OpenRiC is + live status) and [**Architecture**](../architecture.html) (where the four public surfaces fit and how they talk to each other). Read those first if you're new.

## Reference material, not step-by-step

These guides assume you want to *do something*. Reference material for each endpoint or primitive lives in the [Spec](../spec/):

- Full endpoint catalog: [Viewing API](../spec/viewing-api.html)
- JSON-LD shapes / property tables: [Mapping](../spec/mapping.html)
- Viewer rendering model: [Graph Primitives](../spec/graph-primitives.html)
- Conformance testing: [Conformance](../spec/conformance.html)
