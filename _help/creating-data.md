---
title: Creating entities
category: Using the API
order: 2
summary: Create records, record parts, record sets, agents, places and relations with POST - the request shapes, how parts and relations work, and the API key they need. With curl samples.
---

Writes are `POST` to the same `/api/ric/v1` base. Reads are public; writes need a write-scoped `X-API-Key`, on the reference server as on your own. The reference server ran an anonymous open-write window until 14 October 2026; it was closed because entities created that way landed in a production database. You can request a key from the reference service, or run the [modelling wizard](/wizard/) and copy the requests it builds.

## Create a record

```bash
curl -X POST https://ric.theahg.co.za/api/ric/v1/records \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"title":"Field recording - Reel 12","level":"item"}'
# → 201 { "id": 914120, "slug": "...", "type": "record", "href": "/api/ric/v1/records/..." }
```

## Create a record part (a component of a record)

A Record Part needs a **`parent_id`** - the record it belongs to:

```bash
curl -X POST https://ric.theahg.co.za/api/ric/v1/record-parts \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"title":"Track A - wedding songs","parent_id":914120}'
```

`POST /record-sets` works the same way (optional `level`, default `collection`).

## Create an agent, then relate it

Per-entity provenance is a **relation**, not a field. Create the agent, then link it:

```bash
# 1) the creator
curl -X POST https://ric.theahg.co.za/api/ric/v1/agents \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"name":"M. Papadopoulou"}'         # → { "id": 914121, ... }

# 2) the record has that creator
curl -X POST https://ric.theahg.co.za/api/ric/v1/relations \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"subject_id":914120,"object_id":914121,"relation_type":"has_creator"}'
```

Other entity types: `POST /places`, `/rules`, `/activities`, `/instantiations`, `/agents`, `/repositories`, `/functions`.

## Valid relation codes

`has_creator`, `has_or_had_location`, `has_or_had_subject`, `has_instantiation`, `has_derived_instantiation`, `results_from`, `performed_by`, `is_regulated_by`, `is_child_of`, `has_family_member`, `held_by`, … - see `GET /api/ric/v1/relation-types`.

## On your own server (key required)

```bash
curl -X POST https://your-host/api/ric/v1/records \
  -H "X-API-Key: <write-scoped key>" -H "Content-Type: application/json" \
  -d '{"title":"…"}'
```

Edits and deletes (`PATCH`/`DELETE`) always require a key - there is no anonymous edit/delete.

## Next

- [Conformance & profiles](/help/conformance-and-profiles/) - the Round-Trip Editing profile
- [Reading data](/help/using-the-api/)
