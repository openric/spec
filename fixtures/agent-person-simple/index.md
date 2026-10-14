---
layout: default
title: "Fixture: agent-person-simple"
description: "Minimal rico:Agent / rico:Person payload — conformance fixture for the authority-context profile."
---

# Fixture: `agent-person-simple`

A single Agent response (in this case resolved as `rico:Agent` because the underlying actor has no `entity_type_id`). Exercises: `@context` prefix bindings, `@id` / `@type` / `name` minimal Agent payload, schema selection by `@type`, SHACL `AgentShape` with `rico:name` shorthand.

**Profile:** `authority-context` · **Status:** done

**Source:** [`https://heratio.theahg.co.za/api/ric/v1/agents/d6mh-ktzy-h6qz`](https://heratio.theahg.co.za/api/ric/v1/agents/d6mh-ktzy-h6qz)

**Validation:** [`expected.jsonld`](./expected.jsonld) MUST validate against the schema selected by its `@type`.

## Files

- [`expected.jsonld`](./expected.jsonld) — canonical JSON-LD output
- [`notes.md`](./notes.md) — human-readable notes
- [`source-url.txt`](./source-url.txt) — live reference endpoint

## See also

- [All fixtures](../) - the {{ site.data.inventory.fixtures }}-case conformance pack
- [Conformance probe](/conformance/) — runs this fixture against a server
- [Proof of implementation](/proof.html) — where this fixture is cited
