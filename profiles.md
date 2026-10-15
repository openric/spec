---
layout: default
title: OpenRiC Profiles
description: Named, bounded conformance targets. Implementers pick the profiles that match their capability; consumers know exactly what to expect.
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Profiles</div>
    <h1>Implement the subset you can support. Nothing more, nothing less.</h1>
    <p class="hero-lede">
      OpenRiC profiles are named, bounded conformance targets. Each profile defines a fixed endpoint set, minimum field set, and SHACL shape set. A server declares which profiles it supports; consumers know exactly what to expect - and nothing more.
    </p>
    <div class="hero-cta">
      <a class="btn-primary" href="{{ '/spec/profiles/' | relative_url }}">Read the profile framework ↗</a>
      <a class="btn-ghost" href="{{ '/spec/profiles/core-discovery.html' | relative_url }}">Core Discovery profile ↗</a>
    </div>
  </div>
</div>

## Why profiles

Before profiles, OpenRiC conformance was all-or-nothing - implement every endpoint and every entity type, or don't claim OpenRiC at all. That suits exactly one kind of implementer: a fully-featured GLAM platform. It turns away everyone else - aggregators, authority services, viewers, legacy catalogues with a read-only window.

Profiles fix this. Each profile is a small, reviewable, badgeable commitment. An institution with a legacy catalogue claims Core Discovery and gets listed today. Over time they add Authority & Context, then Provenance, then Digital Object Linkage - every step a public, verifiable capability upgrade.

This is the pattern that turned IIIF from aspirational spec to eight-hundred-institution reality. OpenRiC is adopting it deliberately.

## Profile catalogue

<div class="surfaces">
{%- for p in site.data.profiles %}
  <a class="surface-card" href="{{ '/spec/profiles/' | append: p.id | append: '.html' | relative_url }}">
    <span class="surface-icon">{{ p.icon }}</span>
    <h3>{{ p.title | replace: '&', '&amp;' }} <span class="status-pill {% if p.status == 'normative' %}live{% else %}draft{% endif %}">v{{ p.version }} {{ p.status }}</span></h3>
    <div class="url">{{ p.surface }}</div>
    <p>{% if p.card %}{{ p.card }}{% else %}{{ p.scope | markdownify | remove: '<p>' | remove: '</p>' | strip }}{% endif %}</p>
  </a>
{%- endfor %}
</div>

## How profiles compose

Profiles are **orthogonal**, not hierarchical. A server can claim any subset - there is no "you must implement Core Discovery before you can claim Export-Only." Some profiles have **dependencies** (Provenance depends on Authority & Context because activities reference agents), but within the dependency graph any combination is valid.

## Declaring a profile

Servers advertise supported profiles in the service description at `GET /`:

```json
{
  "name": "Your Service",
  "version": "2.4.1",
  "openric_conformance": {
    "spec_version": "{{ site.data.version.version }}",
    "profiles": [
      { "id": "core-discovery", "version": "0.4.0", "conformance": "full" }
    ]
  }
}
```

The conformance probe reads this field, runs the profile-specific test subset, and emits a pass/fail report:

```bash
BASE=https://your-server/api/ric/v1 bash conformance/probe.sh --profile=core-discovery
```

See [Conformance](spec/conformance.html) for the full testing model.

## What's next

{%- assign p_norm = site.data.profiles | where: "status", "normative" -%}{%- assign p_draft = site.data.profiles | where: "status", "draft" -%}
**{{ p_norm.size }} profiles are normative and {{ p_draft.size }} are in draft.** Normative: {{ p_norm | map: "title" | join: ", " }}. Draft, open for comment: {{ p_draft | map: "title" | join: ", " }}. The normative set is stable; the drafts are open for comment. The path to v1.0 runs through the governance gates (a second independent implementation, an external institution committing to deploy, sustained non-maintainer contributors), not through more profile definitions. Provenance & Event is the one profile where the reference implementation's serializer can emit the required shape but the backing data has gaps; see its §9 Q5 and the drift log for the honest accounting.

Comments on the profile framework or any profile are welcome at the [GitHub Discussions](https://github.com/openric/spec/discussions).
