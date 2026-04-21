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
  <a class="surface-card" href="getting-started.html">
    <span class="surface-icon">🚀</span>
    <h3>Getting started</h3>
    <p>Zero-to-working in 15 minutes. Read, request a key, write, link, probe, embed, harvest. Start here if OpenRiC is new to you.</p>
  </a>
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
  <a class="surface-card" href="triplestore-choice.html">
    <span class="surface-icon">🗄</span>
    <h3>Choosing a triplestore</h3>
    <p>Fuseki (the reference), Oxigraph, GraphDB, Virtuoso, QLever, and friends. Scale bands, performance notes, when to migrate. OpenRiC is triplestore-agnostic.</p>
  </a>
</div>

## Before you dive in

If you haven't yet, the two-page orientation pieces are [**Home**](../) (what OpenRiC is + live status) and [**Architecture**](../architecture.html) (where the four public deployments fit and how they talk to each other). Read those first if you're new.

For evidence that the contract actually works in production — live numbers, a real end-to-end use case, and one example of every RiC-O type — see [**Proof of implementation**](../proof.html).

## Reference material, not step-by-step

These guides assume you want to *do something*. Reference material for each endpoint or primitive lives in the [Spec](../spec/):

- Full endpoint catalog: [Viewing API](../spec/viewing-api.html)
- JSON-LD shapes / property tables: [Mapping](../spec/mapping.html)
- Viewer rendering model: [Graph Primitives](../spec/graph-primitives.html)
- Conformance testing: [Conformance](../spec/conformance.html)
