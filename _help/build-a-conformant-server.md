---
title: Build a conformant server
category: For developers
order: 1
summary: What it takes to implement OpenRiC - pick a profile, map your data to RiC-O, serve the JSON-LD endpoints, declare your profiles, and pass the probe + SHACL. With pointers.
---

You don't implement "all of OpenRiC" - you pick a [profile](/help/profiles-tree/) and meet its contract. The smallest meaningful claim is **Core Discovery** (read-only).

## The shape of the work

1. **Map your catalogue to RiC-O.** Records → `rico:Record`/`RecordSet`/`RecordPart`, creators → `rico:Agent`, etc. See the [mapping document](/spec/mapping.html) and [entities & relations](/help/entities-and-relations/).
2. **Serve the endpoints** for your chosen profile, returning `application/ld+json`. For Core Discovery: `GET /api/ric/v1/{records,agents,repositories}`, `/{type}/{slug}`, `/vocabulary`, `/autocomplete`.
3. **Mint IRIs** per the [Governance profile](/spec/profiles/governance.html) two-layer policy - stable, environment-independent public IRIs (`https://<host>/ric/<type>/<slug>`).
4. **Declare your profiles** in the service description at `GET /api/ric/v1/`.
5. **Validate** - pass the conformance probe and the SHACL shapes.

## Validate against the schemas + probe

```bash
# JSON Schemas + SHACL shapes (the spec ships both)
#   schemas/*.schema.json   shapes/*.shacl.ttl
# Probe your server end-to-end:
BASE=https://your-host/api/ric/v1 ./conformance/probe.sh
KEY=<write-key> BASE=https://your-host/api/ric/v1 ./conformance/probe.sh   # + write surface
```

There's also a Python validator (`validator/`) that checks fixtures against the schemas, and an [API Explorer / OpenAPI](https://ric.theahg.co.za/api/ric/v1/docs) you can diff your server against.

## Reference implementation

The OpenRiC reference service (Laravel) is open source (AGPL-3.0) - use it as the canonical behaviour to match. The point of the spec is that a *second, independent* implementation can pass the same probe; that's a v1.0 freeze criterion.

## Writing & AI

- Implementing writes? See the **Round-Trip Editing** profile (POST/PATCH/DELETE + audit) and [Creating entities](/help/creating-data/).
- Surfacing AI-suggested data? The draft **[Inferred-Provenance profile](/spec/profiles/inferred-provenance.html)** requires machine-asserted edges to be visibly distinguishable from documented fact.

## Next

- [Conformance & profiles](/help/conformance-and-profiles/)
- The [system map](/help/system-map/) and [profiles tree](/help/profiles-tree/)
