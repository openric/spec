---
layout: default
title: OpenRiC — Specification
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Specification · v0.1.0</div>
    <h1>The spec, in four documents</h1>
    <p class="hero-lede">OpenRiC is an open, implementation-neutral specification for serving ICA's Records in Contexts (RiC-CM / RiC-O) over HTTP. It's made of four short documents — a mapping table, an HTTP API, a graph-render model, and a conformance test suite.</p>
  </div>
</div>

<div class="spec-docs">
  <a class="spec-doc" href="mapping.html">
    <strong>1 · Mapping</strong>
    <span>ISAD(G) · ISAAR(CPF) · ISDIAH → RiC-CM / RiC-O class &amp; property tables.</span>
  </a>
  <a class="spec-doc" href="viewing-api.html">
    <strong>2 · Viewing API</strong>
    <span>REST + JSON-LD contract. 21 read endpoints, 9 write endpoints, auth model.</span>
  </a>
  <a class="spec-doc" href="graph-primitives.html">
    <strong>3 · Graph Primitives</strong>
    <span>Node · Edge · Cluster · Drill · LayoutHint. Six invariants any conformant server must hold.</span>
  </a>
  <a class="spec-doc" href="conformance.html">
    <strong>4 · Conformance</strong>
    <span>Four levels (L1–L4), 12 JSON Schemas, SHACL shape set, fixture pack, validator CLI.</span>
  </a>
</div>

## Status

v0.1.0 is frozen — implementations can claim conformance against that tag. The `Unreleased` section of the [CHANGELOG](https://github.com/openric/spec/blob/main/CHANGELOG.md) captures progress since (capture app, split, 10 new read endpoints, write surface) — these will be rolled into v0.2.0 once a second implementation is in sight.

## Licence

[Creative Commons Attribution 4.0 (CC-BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Fork it, adapt it, build implementations against it.

## See also

- [Architecture](../architecture.html) — how the four public OpenRiC surfaces fit together
- [Guides](../guides/) — user-facing how-tos for the viewer and capture client
- [Discussions](https://github.com/openric/spec/discussions) — spec feedback, second-implementer Q&A, mapping sanity checks
- [Live demo](../demo/) — open it, drag nodes, hit the reference API
