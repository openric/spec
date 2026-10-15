---
layout: default
title: OpenRiC - Specification
---
{%- assign p_norm = site.data.profiles | where: "status", "normative" -%}
{%- assign p_draft = site.data.profiles | where: "status", "draft" -%}

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Specification · v{{ site.data.version.version }} · {{ p_norm.size }} normative profiles + {{ p_draft.size }} draft</div>
    <h1>The spec - base documents + profiles</h1>
    <p class="hero-lede">OpenRiC is an open, implementation-neutral specification for serving ICA's Records in Contexts (RiC-CM / RiC-O 1.1) over HTTP. The spec is layered: four base documents define the contract, {{ p_norm.size }} normative profiles target specific implementation surfaces, and {{ p_draft.size }} draft profiles, open for comment, extend it: SPARQL Access and the v0.43 governance line.</p>
  </div>
</div>

### Base documents

<div class="spec-docs">
  <a class="spec-doc" href="mapping.html">
    <strong>1 · Mapping</strong>
    <span>ISAD(G) · ISAAR(CPF) · ISDIAH · ISDF → RiC-CM / RiC-O 1.1 class &amp; property tables. Includes Systems-and-Mechanisms (§10).</span>
  </a>
  <a class="spec-doc" href="viewing-api.html">
    <strong>2 · Viewing API</strong>
    <span>REST + JSON-LD contract. 46 endpoints, auth model, pagination policy, content-negotiation roadmap.</span>
  </a>
  <a class="spec-doc" href="graph-primitives.html">
    <strong>3 · Graph Primitives</strong>
    <span>Node · Edge · Cluster · Drill · LayoutHint. Six invariants any conformant server must hold.</span>
  </a>
  <a class="spec-doc" href="conformance.html">
    <strong>4 · Conformance</strong>
    <span>Profile-based conformance (L1-L4 retained as legacy). JSON Schemas, SHACL shape set, fixture pack, validator CLI.</span>
  </a>
  <a class="spec-doc" href="/contract/openapi.json">
    <strong>5 · API contract</strong>
    <span>OpenAPI 3.1, version {{ site.data.version.version }}: every operation the profiles define, tagged with its profile, typed by the JSON Schemas and illustrated by the fixtures. CI validates each example against its schema.</span>
  </a>
</div>

### Profiles

| Profile | Status | Profile version | Last revised in spec |
|---|---|---|---|
{% for p in site.data.profiles -%}
| [`{{ p.id }}`](profiles/{{ p.id }}.html) | {{ p.status | capitalize }} | {{ p.version }} | {{ p.revised }} |
{% endfor %}

## Status

| Layer | Current version | Status |
|---|---|---|
| Base spec (mapping + viewing API + graph primitives + conformance) | **v{{ site.data.version.version }}** | Active - RiC-O 1.1 namespace remediation complete (see [audit](../audit/ric-o-1.1-audit.html)) |
| Mapping spec | last revised in v0.38.1 | Active |
| Profiles | per table above | {{ p_norm.size }} normative + {{ p_draft.size }} draft |
| RiC-O ontology target | 1.1 (2025-05-22) | Tracked |
| Extension namespace | `openricx: <https://openric.org/ns/ext/v1#>` | Declared, ontology stub at [/ns/ext/v1.html](/ns/ext/v1.html) |

The previous "v0.1.0 frozen" / "v0.2.0 pending" framing referenced the original four-document base spec. After the v0.30.0 → v0.36.0 profile-freeze series and the v0.37.0 RiC-O 1.1 remediation, the base-spec version tracks the spec repository as a whole. Profile versions remain independent (per [Q8 in core-discovery.md](profiles/core-discovery.html)).

## Licence

[Creative Commons Attribution 4.0 (CC-BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Fork it, adapt it, build implementations against it.

## See also

- [Architecture](../architecture.html) - how the four public OpenRiC deployments fit together
- [Guides](../guides/) - user-facing how-tos for the viewer and capture client
- [Discussions](https://github.com/openric/spec/discussions) - spec feedback, second-implementer Q&A, mapping sanity checks
- [Live demo](../demo/) - open it, drag nodes, hit the reference API
