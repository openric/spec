---
layout: default
title: OpenRiC - Round-Trip Editing Profile
description: The write surface - POST/PATCH/DELETE across every writable entity, with an audit trail that lets a client confirm its mutation was persisted the way it intended. The hardest profile. Depends on Core Discovery and Authority & Context.
---

# Round-Trip Editing Profile

**Profile id:** `round-trip-editing`
**Profile version:** 0.7.0
**Spec version:** 0.34.0
**Status:** Normative
**Dependencies:** Core Discovery + Authority & Context (a client that can write entities it cannot read, or entities with no authority context, cannot meaningfully round-trip).
**Last updated:** 2026-04-21

---

## 1. Purpose

Round-Trip Editing is the profile for **creating, updating, and deleting RiC entities over the API, with a persistent audit trail that lets a client confirm the mutation was accepted the way it intended**. Where Core Discovery answers *what does the server know about this record*, Round-Trip Editing answers *can I change what the server knows, and can I verify the change stuck?*

A server implementing this profile commits to four things:

1. **Expose write verbs** (POST, PATCH/PUT, DELETE) on every RiC entity type: agents, records, repositories, functions, places, rules, activities, instantiations, and the relations between them.
2. **Gate those verbs behind an API-key-authenticated scope** (`write` for create/update, `delete` or equivalent for destructive ops). Reads remain public.
3. **Return deterministic response envelopes** - `201 Created` with `{id, slug, type, href}` on POST; `200 OK` with `{success: true, id}` on PATCH/DELETE and relation writes. Errors follow RFC 7807 per Core Discovery §4.
4. **Record every successful mutation to an audit log** and expose that log via `GET /{type}/{id}/revisions` as an `openric:RevisionList`. This is the "round-trip" closure: a client that POSTed or PATCHed an entity can query the revision endpoint and see its own mutation recorded with `actor`, `created_at`, and (optionally) the redacted payload.

Round-Trip Editing depends on Core Discovery and Authority & Context - a client writing entities it cannot fetch back, or writing Activities without Places/Rules to bind them to, cannot meaningfully round-trip. Claiming Round-Trip Editing without the two dependencies is a conformance failure.

## 2. Scope

### 2.1 Required write endpoints

For each entity type `{t}` (one of `agents`, `records`, `repositories`, `functions`, `places`, `rules`, `activities`, `instantiations`):

| Verb | Path | Returns |
|---|---|---|
| POST | `/api/ric/v1/{t}` | `201 Created` - create envelope |
| PATCH or PUT | `/api/ric/v1/{t}/{id}` | `200 OK` - success envelope |
| DELETE | `/api/ric/v1/{t}/{id}` | `200 OK` - success envelope |

A server MUST accept PATCH; accepting PUT as an alias is RECOMMENDED (same body shape; PUT is less commonly used but still in the wild).

### 2.2 Required relation endpoints

| Verb | Path | Returns |
|---|---|---|
| POST | `/api/ric/v1/relations` | `201 Created` - create envelope (no `slug`) |
| PATCH or PUT | `/api/ric/v1/relations/{id}` | `200 OK` - success envelope |
| DELETE | `/api/ric/v1/relations/{id}` | `200 OK` - success envelope |

### 2.3 Required revision endpoint

| Verb | Path | Returns |
|---|---|---|
| GET | `/api/ric/v1/{type}/{id}/revisions` | `openric:RevisionList` |

**Public-read default - operator-configurable** (revised v0.37): audit revision endpoints MUST exist for every writable entity. **Public visibility of revision metadata is the default**, but implementations MAY require authentication for sensitive fields. Sensitive keys (passwords, API keys, tokens) MUST be redacted at write time before the payload is stored.

| Audit field | Default public visibility | Operator may restrict |
|---|---|---|
| Revision exists (`id`, `action`) | Public | Coarsen to row count |
| Timestamp (`created_at`) | Public | Coarsen to date precision |
| Actor (api-key id, user id) | **Redacted-or-role-only by default** | - |
| IP address (`ip`) | **Not public by default** | - |
| Payload (full JSON diff) | **Not public by default** | Operator opt-in for full payload |

The "round-trip closure" (a client confirms its own mutation persisted) only requires `id`, `action`, `created_at`, and the entity's stable `@id`. The richer fields (full payload, actor IP) are governance metadata; their visibility is an operator/jurisdiction decision (POPIA §14, GDPR Art. 5/6, etc.), not an OpenRiC normative requirement.

### 2.4 Optional endpoints

| Verb | Path | Purpose |
|---|---|---|
| DELETE | `/api/ric/v1/entities/{id}` | Type-agnostic destructive delete. For implementations whose backing store identifies entities globally by integer ID. |

### 2.5 Forbidden without additional profile claims

- **File uploads on write** (`POST /upload`) - that is Digital Object Linkage §2.2.
- **Bulk imports** (`POST /import`) - out of scope here; implementations that offer bulk import do so outside any profile's normative surface.
- **Write without audit** - a server that mutates entities without recording to `openric_audit_log` (or an equivalent) breaks the round-trip contract.

### 2.6 Content types

- **Request bodies:** `application/json` for all write verbs. Implementations MAY additionally accept `application/ld+json` (identical semantics; the `@context` is ignored on write).
- **Success responses:** `application/json` (the create + success envelopes are pure JSON, not JSON-LD - see §3.1 and §9 Q1).
- **Revision responses:** `application/json` with `@type: openric:RevisionList` (see §3.3).
- **Error responses:** `application/problem+json` per Core Discovery §4.

## 3. Response shapes

### 3.1 Create envelope - `201 Created`

Returned by every successful `POST /{t}` (and `POST /relations`).

```json
{
  "id":   912401,
  "slug": "cradle-of-humankind",
  "type": "place",
  "href": "/api/ric/v1/places/cradle-of-humankind"
}
```

**Required:** `id` (the assigned integer identifier).

**Optional but normative when present:**

- `slug` - present for entity types whose show-endpoint supports slug URLs (`places`, `rules`, `records`, `agents`, `repositories`, `functions`). May be `null` for types without slugs (`activities`, `instantiations`, `relations`).
- `type` - singular form of the URL segment (`place`, `rule`, `activity`, `instantiation`, `agent`, `record`, `repository`, `function`). Omit on `POST /relations`.
- `href` - path of the show endpoint for the new entity. The server MAY additionally set `Location:` to the same value.

Validated by `/schemas/write-response.schema.json` `$defs/create`. Fixture: [`write-response-create`](../../fixtures/write-response-create/).

### 3.2 Success envelope - `200 OK`

Returned by every successful `PATCH/PUT /{t}/{id}`, `DELETE /{t}/{id}`, and relation write.

```json
{ "success": true, "id": 912401 }
```

**Required:** `success` (literal `true`, not just truthy), `id` (the mutated entity's identifier).

Validated by `/schemas/write-response.schema.json` `$defs/success`. Fixture: [`write-response-success`](../../fixtures/write-response-success/).

### 3.3 Revision list - `GET /{t}/{id}/revisions`

The audit trail for one entity, newest-first.

```json
{
  "@type": "openric:RevisionList",
  "entity": { "type": "places", "id": 912401 },
  "total": 3,
  "items": [
    {
      "id":         104712,
      "action":     "update",
      "entity":     { "type": "place", "id": 912401 },
      "actor":      "api_key:14",
      "ip":         "203.0.113.42",
      "payload":    { "openricx:description": "Updated to clarify UNESCO status." },
      "created_at": "2026-04-20T14:22:07Z"
    }
  ]
}
```

**RevisionList required fields:** `@type` (MUST be `openric:RevisionList`), `entity`, `total` (non-negative integer), `items` (array, MAY be empty).

**RevisionEntry required fields:** `id`, `action` (one of `create`, `update`, `delete`), `entity`, `actor` (pattern `api_key:<n>` | `session` | `anonymous`), `created_at` (ISO-8601 datetime).

**RevisionEntry optional fields:** `ip`, `payload` (redacted request-body snapshot; implementations MAY omit for privacy).

Validated by `:RevisionListShape` + `:RevisionEntryShape` in `shapes/profiles/round-trip-editing.shacl.ttl`. Fixture: [`revision-list`](../../fixtures/revision-list/).

### 3.4 Pagination on revisions

`GET /{t}/{id}/revisions?limit=N` - default 50, maximum 200. Paging past `limit` (deep audit history) is not in this profile's normative surface; a server that exposes it SHOULD do so via a separate audit-export endpoint.

## 4. Authentication & authorisation

### 4.1 API-key header

All write verbs REQUIRE a `X-API-Key: <key>` header. The key is authenticated by the server-side middleware (`api.auth:<scope>` in the reference implementation).

### 4.2 Scopes

| Scope | Permits |
|---|---|
| `write` | POST, PATCH, PUT on every entity type and relations |
| `delete` | DELETE on every entity type and relations (a key with only `write` scope MUST NOT be able to delete) |

A key MAY hold both scopes. Implementations MAY define additional scopes (`admin`, `write:records`) - any scope outside this table is outside the profile's normative surface.

### 4.3 Error paths

- Missing/invalid key on a write verb → `401 authentication-required`
- Valid key without the needed scope → `403 forbidden`
- Both returned as `application/problem+json` per Core Discovery §4.

## 5. SHACL shapes

Round-Trip Editing ships three shapes in `shapes/profiles/round-trip-editing.shacl.ttl`. The write-request and write-response envelopes are pure JSON (not JSON-LD) and are validated by JSON Schema at `/schemas/write-response.schema.json`; SHACL covers the revision-list response, which is JSON-LD-adjacent.

| Shape | Target | Severity model |
|---|---|---|
| `:RevisionListShape` | `openric:RevisionList` | `sh:Violation` on missing `@type`, `entity`, `total`, or non-integer `total`; each `items` entry validated as `:RevisionEntryShape` |
| `:RevisionEntryShape` | inline on `openric:items` values | `sh:Violation` on missing `id`, `action`, `entity`, `actor`, `created_at`; `sh:Violation` if `action` is not `create` / `update` / `delete`; `sh:Info` on optional `ip` / `payload` |
| `:AuditedActionShape` | any subject with an `openric:action` predicate | Stand-alone constraint on the action enum, reusable outside the RevisionList envelope (e.g. audit-log exports) |

Cross-entity checks ("every audit row references a live entity") are deliberately deferred to Graph Traversal's full-graph shapes - they require the whole store and produce false positives on a single revision-list response.

## 6. Conformance testing

A server claims `round-trip-editing` when, holding a valid API key with `write` + `delete` scopes:

1. `POST /api/ric/v1/places` with a valid body returns `201 Created` with the create envelope; the `href` path dereferences to the newly-created Place.
2. `PATCH /api/ric/v1/places/{id}` with a partial body returns `200 OK` with the success envelope; a subsequent `GET /places/{id}` reflects the change.
3. `DELETE /api/ric/v1/places/{id}` returns `200 OK`; a subsequent `GET /places/{id}` returns `404 not-found`.
4. `GET /api/ric/v1/places/{id}/revisions` returns an `openric:RevisionList` including at least the `create`, `update`, and `delete` rows from steps 1-3, with `actor` matching `api_key:{n}` for the key that performed them.
5. Steps 1-4 repeated for every required entity type (records, agents, repositories, functions, rules, activities, instantiations) and for relations.
6. `POST /api/ric/v1/places` without `X-API-Key` returns `401 authentication-required` (`application/problem+json`).
7. `DELETE /api/ric/v1/places/{id}` with a key holding only `write` scope (not `delete`) returns `403 forbidden`.
8. Deletion that would violate a referential constraint (e.g. deleting a Record with descendants) returns `409 conflict` per Core Discovery §4.1.
9. Bodies that fail validation (missing `rico:name` on a Place) return `422 validation-failed`.

Run the conformance probe with `--profile=round-trip-editing` (it will prompt for an API key) to exercise all nine checks against a live server.

## 7. Fixture pack

The manifest declares these four fixtures as normative for `round-trip-editing`:

| Fixture | Status | What it pins |
|---|---|---|
| `entity-write-place` | done | POST /places - request body + expected create-envelope response |
| `write-response-create` | done | Canonical `201` create envelope shape (reusable across all POSTs) |
| `write-response-success` | done | Canonical `200` success envelope shape (reusable across PATCH/DELETE/relation writes) |
| `revision-list` | done | `openric:RevisionList` response with `create` + `update` × 2 rows |

Fixtures outside this list are NOT required for profile conformance.

## 8. Implementation checklist

- [ ] Wire write routes for all 8 entity types + relations under a middleware that enforces `X-API-Key` + scope
- [ ] POST returns `201 Created` with `{id, slug?, type?, href?}` - at minimum `id`
- [ ] PATCH/PUT returns `200 OK` with `{success: true, id}`
- [ ] DELETE returns `200 OK` with `{success: true, id}`
- [ ] Every successful mutation writes one row to the audit log (action, entity, actor, timestamp, payload)
- [ ] Sensitive keys (passwords, API keys) redacted in the stored payload before insert
- [ ] `GET /{t}/{id}/revisions` returns `openric:RevisionList` per §3.3 - minimal fields (`id`, `action`, `created_at`, `entity`) public by default; richer fields (`actor`, `ip`, `payload`) operator-gated per §2.3 visibility table
- [ ] Revision response validates against `:RevisionListShape` - 0 Violations
- [ ] 401 on missing/invalid key; 403 on scope mismatch - both `application/problem+json`
- [ ] 409 on referential-integrity conflicts; 422 on body validation failures
- [ ] Add `round-trip-editing` to `openric_conformance.profiles` in `GET /`
- [ ] All 4 shipped fixtures pass the conformance probe at `--profile=round-trip-editing`
- [ ] `/conformance/badge?profile=round-trip-editing` returns shields.io JSON

## 9. Design decisions

Six questions were flagged during drafting; all six carry resolutions.

### Q1 - Write envelopes as pure JSON or JSON-LD?

**Resolution**: **Pure JSON.**

**Rationale**: Create and success envelopes are confirmations, not RiC data. They carry identifiers and routing hints (`href`), not ontology-bearing facts. Wrapping them in JSON-LD with an `@context` would force every write response to declare prefix bindings for data that doesn't use them. This matches the pattern already set by Graph Traversal §3.3 (`/relations`, `/hierarchy` are compact JSON) and by IIIF Image API's non-LD responses. LD-native clients can still parse the envelopes - they're valid JSON.

### Q2 - Optimistic concurrency control (ETags / If-Match)?

**Resolution**: **Not required in v0.7. Last-write-wins with audit trail.**

**Rationale**: The audit log provides *reactive* concurrency - a client that wants to detect "someone else wrote while I was editing" can `GET /revisions` before and after its PATCH and look for intervening entries. That is enough for the common case (catalogue curation rarely has racing writers on the same entity). ETag / If-Match *proactive* concurrency is a real v1.0+ candidate for high-concurrency scenarios, but adding it in v0.7 would change every implementation's storage layer and every client's write code for a problem most implementers don't yet have. Implementations that need it now MAY emit ETags - clients MUST tolerate their absence.

### Q3 - Audit log: public or gated?

**Resolution**: **Public read, with redaction at write time.**

**Rationale**: Audit transparency is load-bearing for the "round-trip" contract - a client that cannot read the audit log cannot verify its own mutation landed. Gating audit reads would effectively require every consuming client to hold an API key just to confirm a write, which defeats the point. The cost is that audit payloads are public, so implementations MUST redact sensitive keys (passwords, API keys, tokens, anything that would leak creds) at write time, before storing the payload. This puts the burden on the server (redact on write) rather than on every audit reader (filter on read), which is strictly safer.

### Q4 - Deep audit pagination: in-profile or out-of-scope?

**Resolution**: **Out of scope. `?limit=N` ≤ 200 is the normative ceiling.**

**Rationale**: A pathological entity (a Record edited daily over a decade = 3,650 revisions) exceeds 200 rows. A profile that mandates deep pagination would push implementations to build a paging protocol (cursors? page tokens? offset?) for a problem that applies to a handful of long-lived entities. Instead, this profile caps at 200 and punts deeper history to a separate audit-export endpoint (out of the profile's normative surface). Implementations MAY expose such an endpoint under their own prefix; a future v1.0+ profile revision may promote it.

### Q5 - Scope granularity: coarse (`write` / `delete`) or fine (`write:records`, `delete:places`)?

**Resolution**: **Coarse in v0.7. Fine-grained scopes are implementation-specific.**

**Rationale**: Coarse scopes (write / delete) cover the 80% case: a catalogue curator holds both, a bulk-ingest key holds only write. Mandating fine-grained scopes would force every implementation to implement per-entity-type scope checking, which many don't need. The profile's minimum is the coarse pair; implementations MAY add fine-grained scopes under their own names (`write:records`, `delete:activities`, etc.) - those are outside the profile's normative surface but do not break conformance. A client given only a narrow scope and attempting a broader operation simply gets `403 forbidden`.

### Q6 - PUT as PATCH alias, or full-replacement semantics?

**Resolution**: **PUT and PATCH are aliases - both partial-update.**

**Rationale**: HTTP orthodoxy says PUT = full replacement, PATCH = partial update. In an archival catalogue, full replacement is actively dangerous: a client that PUTs a Record without every field it previously had would erase data by omission. Treating both verbs as partial-update matches how every actual RiC implementation uses them (the reference server's `Route::match(['patch', 'put'], ...)` is deliberate) and prevents data loss from a common client mistake. Implementations that want true PUT replacement MAY expose it under a different path (`/{t}/{id}/replace`) - not in this profile.
