---
layout: default
title: OpenRiC - Specification
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Specification · v0.37.0 · 7 normative profiles + 1 draft</div>
    <h1>The spec - base documents + profiles</h1>
    <p class="hero-lede">OpenRiC is an open, implementation-neutral specification for serving ICA's Records in Contexts (RiC-CM / RiC-O 1.1) over HTTP. The spec is layered: four base documents define the contract, seven normative profiles target specific implementation surfaces, and one draft profile (SPARQL Access) extends the linked-data publication story.</p>
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
    <span>Profile-based conformance (L1–L4 retained as legacy). JSON Schemas, SHACL shape set, fixture pack, validator CLI.</span>
  </a>
</div>

### Profiles

| Profile | Status | Profile version | Spec version |
|---|---|---|---|
| [`core-discovery`](profiles/core-discovery.html) | Normative | 0.3.0 | 0.30.0 |
| [`authority-context`](profiles/authority-context.html) | Normative | 0.4.0 | 0.31.0 |
| [`graph-traversal`](profiles/graph-traversal.html) | Normative | 0.5.0 | 0.32.0 |
| [`digital-object-linkage`](profiles/digital-object-linkage.html) | Normative | 0.6.0 | 0.33.0 |
| [`round-trip-editing`](profiles/round-trip-editing.html) | Normative | 0.7.0 | 0.34.0 |
| [`provenance-event`](profiles/provenance-event.html) | Normative | 0.8.0 | 0.35.0 |
| [`export-only`](profiles/export-only.html) | Normative | 0.9.0 | 0.36.0 |
| [`sparql-access`](profiles/sparql-access.html) | Draft | 0.1.0 | 0.37.0 |

## Status

| Layer | Current version | Status |
|---|---|---|
| Base spec (mapping + viewing API + graph primitives + conformance) | **v0.37.0** | Active - RiC-O 1.1 namespace remediation complete (see [audit](../audit/ric-o-1.1-audit.html)) |
| Mapping spec | 0.1.0-draft → v0.37.0 (post-remediation) | Active |
| Profiles | per table above | 7 normative + 1 draft |
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
