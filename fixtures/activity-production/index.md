---
layout: default
title: "Fixture: activity-production"
description: "A rico:Activity activity with a date range — conformance fixture for the authority-context profile."
---

# Fixture: `activity-production`

A rico:Activity activity (type_id=production) with a date range. Exercises: production branch of the activity schema's `@type` pattern; [mapping spec §6.5](/spec/mapping.html#_6-5-activity-type-mapping) `production → Production`.

**Profile:** `authority-context` · **Status:** done

**Source:** [`https://heratio.theahg.co.za/api/ric/v1/activities/910378`](https://heratio.theahg.co.za/api/ric/v1/activities/910378)

**Validation:** [`expected.jsonld`](./expected.jsonld) MUST validate against the schema selected by its `@type`.

## Files

- [`expected.jsonld`](./expected.jsonld) — canonical JSON-LD output
- [`notes.md`](./notes.md) — human-readable notes
- [`source-url.txt`](./source-url.txt) — live reference endpoint

## See also

- [All fixtures](../) - the {{ site.data.inventory.fixtures }}-case conformance pack
- [Conformance probe](/conformance/) — runs this fixture against a server
- [Proof of implementation](/proof.html) — where this fixture is cited
