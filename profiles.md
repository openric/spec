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
      OpenRiC profiles are named, bounded conformance targets. Each profile defines a fixed endpoint set, minimum field set, and SHACL shape set. A server declares which profiles it supports; consumers know exactly what to expect — and nothing more.
    </p>
    <div class="hero-cta">
      <a class="btn-primary" href="{{ '/spec/profiles/' | relative_url }}">Read the profile framework ↗</a>
      <a class="btn-ghost" href="{{ '/spec/profiles/core-discovery.html' | relative_url }}">Core Discovery profile ↗</a>
    </div>
  </div>
</div>

## Why profiles

Before profiles, OpenRiC conformance was all-or-nothing — implement every endpoint and every entity type, or don't claim OpenRiC at all. That suits exactly one kind of implementer: a fully-featured GLAM platform. It turns away everyone else — aggregators, authority services, viewers, legacy catalogues with a read-only window.

Profiles fix this. Each profile is a small, reviewable, badgeable commitment. An institution with a legacy catalogue claims Core Discovery and gets listed today. Over time they add Authority & Context, then Provenance, then Digital Object Linkage — every step a public, verifiable capability upgrade.

This is the pattern that turned IIIF from aspirational spec to eight-hundred-institution reality. OpenRiC is adopting it deliberately.

## Profile catalogue

<div class="surfaces">
  <a class="surface-card" href="{{ '/spec/profiles/core-discovery.html' | relative_url }}">
    <span class="surface-icon">🔍</span>
    <h3>Core Discovery <span class="status-pill live">v0.3.0 normative</span></h3>
    <div class="url">Records · Agents · Repositories · Vocabulary · Autocomplete</div>
    <p>The minimum "I can be queried" claim. Ten read-only endpoints, three entity types, no graph traversal. Every OpenRiC server starts here.</p>
  </a>
  <a class="surface-card" href="{{ '/spec/profiles/authority-context.html' | relative_url }}">
    <span class="surface-icon">🏛</span>
    <h3>Authority &amp; Context <span class="status-pill live">v0.4.0 normative</span></h3>
    <div class="url">Places · Rules · Activities as first-class</div>
    <p>Reconciliation-friendly identifiers for places, rules, and activities. The profile that turns a catalogue into a knowledge graph.</p>
  </a>
  <div class="surface-card" style="opacity: 0.65; cursor: default;">
    <span class="surface-icon">📜</span>
    <h3>Provenance &amp; Event <span class="status-pill" style="background: var(--pending); color: #fff;">planned</span></h3>
    <div class="url">Production · Accumulation · full event model</div>
    <p>Activity subclasses with the full event model — who did what, when, under which rule. Depends on Authority &amp; Context.</p>
  </div>
  <div class="surface-card" style="opacity: 0.65; cursor: default;">
    <span class="surface-icon">🗄</span>
    <h3>Digital Object Linkage <span class="status-pill" style="background: var(--pending); color: #fff;">planned</span></h3>
    <div class="url">Instantiations · MIME · checksums · IIIF</div>
    <p>Surface instantiations of records — digital files, physical copies, checksums, MIME types, IIIF manifest pointers.</p>
  </div>
  <div class="surface-card" style="opacity: 0.65; cursor: default;">
    <span class="surface-icon">📦</span>
    <h3>Export-Only <span class="status-pill" style="background: var(--pending); color: #fff;">planned</span></h3>
    <div class="url">OAI-PMH · JSON-LD dumps</div>
    <p>Harvest-friendly batch export for aggregators. Independent of every other profile — no discovery endpoints required.</p>
  </div>
  <div class="surface-card" style="opacity: 0.65; cursor: default;">
    <span class="surface-icon">✍</span>
    <h3>Round-Trip Editing <span class="status-pill" style="background: var(--pending); color: #fff;">planned</span></h3>
    <div class="url">POST · PATCH · DELETE with provenance</div>
    <p>Full write surface with provenance-aware write-back rules. The hardest profile. Depends on Core Discovery + Authority &amp; Context.</p>
  </div>
  <a class="surface-card" href="{{ '/spec/profiles/graph-traversal.html' | relative_url }}">
    <span class="surface-icon">🕸</span>
    <h3>Graph Traversal <span class="status-pill live">v0.5.0 normative</span></h3>
    <div class="url">/graph · /relations · /hierarchy</div>
    <p>Cross-entity walks keyed to a root URI + depth. Plus full-graph SHACL shapes for hygiene: orphaned records, unlinked agents, duplicate identifiers, typed-link mismatches.</p>
  </a>
</div>

## How profiles compose

Profiles are **orthogonal**, not hierarchical. A server can claim any subset — there is no "you must implement Core Discovery before you can claim Export-Only." Some profiles have **dependencies** (Provenance depends on Authority & Context because activities reference agents), but within the dependency graph any combination is valid.

Profiles are also **independent from conformance levels**. A server can be Level 2 (API conformance) on Core Discovery and Level 1 (mapping conformance only) on Authority & Context. See [Conformance §2](spec/conformance.html#2-conformance-levels) for levels.

## Declaring a profile

Servers advertise supported profiles in the service description at `GET /`:

```json
{
  "name": "Your Service",
  "version": "1.0",
  "openric_conformance": {
    "spec_version": "0.3.0",
    "profiles": [
      { "id": "core-discovery", "version": "0.3.0", "level": "L2", "conformance": "full" }
    ]
  }
}
```

The conformance probe reads this field, runs the profile-specific test subset, and emits a pass/fail report:

```bash
./probe.sh --profile core-discovery https://your-server/api/ric/v1
```

See [Conformance](spec/conformance.html) for the full testing model.

## What's next

**Core Discovery**, **Authority & Context**, and **Graph Traversal** are normative as of v0.5.0. The remaining four profiles will be defined one at a time as implementation demand surfaces them. This is intentional — defining seven profiles up front and having most go unimplemented is exactly how standards lose credibility. Each profile is drafted, reviewed, and frozen only when at least one independent implementer is ready to target it (or the reference implementation already exercises the full shape, as was the case for the three landed to date).

Comments on the profile framework or the Core Discovery draft are welcome at the [GitHub Discussions](https://github.com/ArchiveHeritageGroup/openric-spec/discussions).
