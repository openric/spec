---
layout: default
title: OpenRiC Profiles
description: Profiles are named, bounded conformance targets. A server declares which profiles it supports; consumers know exactly what to expect.
---
{%- assign p_norm = site.data.profiles | where: "status", "normative" -%}
{%- assign p_draft = site.data.profiles | where: "status", "draft" -%}

# OpenRiC Profiles

**Last revised in:** v0.47.0

---

## 1. Purpose

A **profile** is a named subset of the OpenRiC spec a server can claim conformance to. Profiles bound expectations. Instead of a single monolithic "OpenRiC-conformant" claim (all endpoints, all entity types, all write verbs), each profile defines a capability axis with a fixed endpoint set, minimum field set, and SHACL shape set.

Design inspiration: the way [IIIF Presentation API](https://iiif.io/api/presentation/3.0/) separates into Level 0 / 1 / 2, and the way [OGC WMS](https://www.ogc.org/standards/wms) defines named conformance classes. Both patterns have the same effect - they let implementations opt in at their current capability without over-claiming.

## 2. Profiles are the conformance unit

A server declares the profiles it supports, each at a profile version. There is no second dimension: the four conformance levels (L1 to L4) of earlier versions are legacy, described only in the appendix of [Conformance](../conformance.html#appendix---legacy-conformance-levels). The {{ site.data.profiles | size }} profiles are listed in §6.

## 3. Composition rules

- **Profiles are additive, not hierarchical.** Authority & Context is *not* a superset of Core Discovery; they are orthogonal. A server may implement any subset.
- **Dependency declarations.** Some profiles have hard dependencies - for example, Provenance & Event depends on Authority & Context because Activity entities carry `rico:hasOrHadParticipant` references. A profile document lists its dependencies; declaring a profile without its dependencies is a conformance failure.
- **Forbidden-field rule.** A response under one profile MUST NOT emit fields from a profile the server does not claim. A Core-Discovery-only server that emits `rico:isOrWasSubjectOf` edges lies about its capabilities and fails conformance.

## 4. Versioning

Each profile has its own version, independent of the specification version (Core Discovery Q8). A profile's version changes only when the profile changes; the profile page and §6 show both the profile version and the specification release that last revised it. What a change bumps, and when a release may break a conformant server, is set by [change control](../change-control.html).

## 5. Declaration

Servers declare supported profiles in the service description at `GET /`:

```json
{
  "name": "Example Archive Catalogue",
  "version": "2.4.1",
  "openric_conformance": {
    "spec_version": "{{ site.data.version.version }}",
    "profiles": [
      {
        "id": "core-discovery",
        "version": "0.4.0",
        "conformance": "full"
      }
    ]
  }
}
```

| Field | Meaning |
|---|---|
| `id` | Profile identifier, kebab-case, from the profile catalogue below |
| `version` | Profile version the server targets |
| `conformance` | `"full"` or `"partial"`; if partial, a `"notes"` field is required |

Consumers MUST read this field before issuing any requests that depend on a specific profile's endpoints.

## 6. The profiles

| Profile | Status | Scope |
|---|---|---|
{% for p in site.data.profiles -%}
| [**{{ p.title }}**]({{ p.id }}.html) | **{{ p.status }}** · v{{ p.version }} | {{ p.scope }} |
{% endfor %}

**{{ p_norm.size }} profiles normative, {{ p_draft.size }} in draft.** Normative: {{ p_norm | map: "title" | join: ", " }}. Draft, open for comment: {{ p_draft | map: "title" | join: ", " }}. The v0.43 governance-line drafts were each ported from a working Heratio reference implementation. v1.0 freeze depends on the governance criteria (a second implementation, an external institution committing to deploy, non-maintainer contributors).

## 7. Conformance testing

The `conformance/probe.sh` script (shipped in this repo) supports profile-scoped testing:

```bash
BASE=https://ric.theahg.co.za/api/ric/v1 bash conformance/probe.sh --profile=core-discovery
```

The probe reads the server's declared profiles at `GET /`, runs the endpoint-specific checks for each, and emits a pass/fail report per profile per endpoint. A server that declares a profile but fails any of its required endpoints fails conformance for that profile, regardless of what it does elsewhere.

## 8. Why profiles matter strategically

Without profiles, OpenRiC is a fixed bar - "you implement all of it or you don't implement it." That suits exactly one kind of implementer (a fully featured GLAM platform) and turns away every other kind (aggregators who only harvest, authority services that only publish agents, viewers that only need read, legacy systems that can expose a subset).

With profiles, OpenRiC becomes a growth path. An institution with a legacy catalogue exposes Core Discovery and gets listed. Over time they add Authority & Context, then Provenance, then Digital Object Linkage. Each step is a small, reviewable, badgeable commitment rather than an all-or-nothing decision. That is how IIIF went from aspirational spec to eight-hundred-institution reality, and it is the shape OpenRiC is adopting deliberately.

---

*Copyright © 2026 The Archive and Heritage Digital Commons Group (Pty) Ltd and the OpenRiC contributors. Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Editor: Dr Johan Pieterse ([johan@theahg.co.za](mailto:johan@theahg.co.za)).*
