---
title: Conformance & profiles
category: Conformance & profiles
order: 1
summary: How OpenRiC conformance works — the profile model, the four levels, the 12 profiles, declaring what you support, and running the conformance probe. With a sample run.
---

OpenRiC conformance is **profile-based**: a server declares which named capabilities it supports, and consumers know exactly what to expect — no all-or-nothing claim.

## Profiles and levels

Two independent dimensions:

- **Profile** — *which* endpoints/entities are exposed (Core Discovery, Authority & Context, …). See the [profiles tree](/help/profiles-tree/).
- **Level** — *how rigorously* (L1 mapping → L2 API → L3 graph → L4 full).

A server declares one or more profiles and the level it meets for each, e.g. *"Core Discovery at L2, Authority & Context at L1."*

## The 12 profiles

**Seven normative:** Core Discovery, Authority & Context, Graph Traversal, Digital Object Linkage, Round-Trip Editing, Provenance & Event, Export-Only.
**Five draft:** SPARQL Access, and the v0.43 governance line — [Governance](/spec/profiles/governance.html), [Portability](/spec/profiles/portability.html), [Inferred-Provenance](/spec/profiles/inferred-provenance.html), [Graph-Grounding](/spec/profiles/graph-grounding.html).

Full catalogue: [/spec/profiles/](/spec/profiles/).

## Declaring what you support

A server advertises its profiles in the service description at `GET /api/ric/v1/`:

```json
{
  "name": "Example Archive Catalogue",
  "openric_conformance": {
    "spec_version": "0.42.x",
    "profiles": [
      { "id": "core-discovery", "version": "0.3.0", "conformance": "full" }
    ]
  }
}
```

## Run the probe

The conformance probe is pure bash + jq — point it at any server:

```bash
BASE=https://ric.theahg.co.za/api/ric/v1 ./conformance/probe.sh
# → PASS GET /records [200] … Summary: 30 pass, 0 fail, 0 skip
# Scope to one profile:
BASE=https://ric.theahg.co.za/api/ric/v1 ./conformance/probe.sh --profile=core-discovery
```

It checks every documented endpoint and reports pass/fail; exit code 0 = conformant. With a `KEY=` it also exercises the write surface.

## SHACL

Beyond endpoints, published graphs are validated against the [SHACL shapes](/spec/). The draft [Governance profile](/spec/profiles/governance.html) makes SHACL a **merge gate**, wired into CI.

## Next

- [Build a conformant server](/help/build-a-conformant-server/)
- The [profiles tree](/help/profiles-tree/)
