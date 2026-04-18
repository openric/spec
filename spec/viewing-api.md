---
layout: default
title: OpenRiC Viewing API
---

# OpenRiC Viewing API

**Version:** 0.1.0-draft
**Status:** Draft — open for comment
**Last updated:** 2026-04-17

---

## 1. Purpose

The Viewing API defines a **REST + JSON-LD** contract that any OpenRiC-conformant server exposes so that viewers, aggregators, and downstream consumers can retrieve RiC data consistently regardless of the server's internal storage.

Design inspiration: the [IIIF Presentation API](https://iiif.io/api/presentation/3.0/). The server decides what to surface; the viewer decides how to render it. The contract between them is narrow and stable.

A reference implementation exists in the Heratio `ahg-ric` package's `LinkedDataApiController`. Where this spec and the reference implementation diverge, this spec is authoritative.

## 2. Conformance levels

| Level | Requirement |
|---|---|
| **L2-core** | `/vocabulary`, `/records`, `/records/{id}`, `/agents`, `/agents/{id}`, `/repositories`, `/repositories/{id}` |
| **L2-graph** | L2-core + `/graph`, `/records/{id}/export` |
| **L2-query** | L2-core + `/sparql`, `/validate` |
| **L2-full** | All of the above |

Level is advertised in the service description (§6).

## 3. Base URL

All endpoints live under:

```
{scheme}://{host}/api/ric/v1/
```

HTTPS is REQUIRED in production. Implementations MAY serve HTTP for local development.

## 4. Endpoints

### 4.1 Service description

```
GET /api/ric/v1/
```

Returns a JSON description of the server's capabilities, conformance level, and endpoint catalogue. MUST be returned without authentication.

```json
{
  "@context": "https://openric.org/ns/v1/context.jsonld",
  "@type": "openric:Service",
  "openric:version": "0.1.0",
  "openric:conformance": ["L2-core", "L2-graph"],
  "openric:endpoints": {
    "records": "/api/ric/v1/records",
    "agents":  "/api/ric/v1/agents",
    "graph":   "/api/ric/v1/graph",
    "sparql":  "/api/ric/v1/sparql"
  },
  "openric:implementation": {
    "name": "Heratio",
    "version": "0.93.119",
    "url": "https://github.com/ArchiveHeritageGroup/heratio"
  }
}
```

### 4.2 Vocabulary

```
GET /api/ric/v1/vocabulary
```

Returns the subset of RiC-O the server actually emits, plus any OpenRiC extension terms it supports. Allows clients to discover server capabilities before constructing queries.

### 4.3 Records (information objects)

| Method & path | Purpose |
|---|---|
| `GET /records` | Paginated list of records |
| `GET /records/{id}` | Single record as RiC-O JSON-LD |
| `GET /records/{id}/export` | Full RecordSet export (record + all descendants + related agents) |

**List parameters:**

| Param | Meaning | Default | Max |
|---|---|---|---|
| `page` | Page number (1-based) | `1` | — |
| `limit` | Items per page | `50` | `200` |
| `level` | Filter by level-of-description (`fonds`, `series`, `file`, `item`) | — | — |
| `q` | Free-text search on title + identifier | — | — |

**List response:**

```json
{
  "@context": "https://openric.org/ns/v1/context.jsonld",
  "@type": "rico:RecordSetList",
  "openric:total": 1423,
  "openric:page": 1,
  "openric:limit": 50,
  "openric:items": [
    { "@id": ".../AHG-A001", "@type": "rico:RecordSet",
      "rico:identifier": "AHG-A001", "rico:title": "Papers of JC Smuts" }
  ],
  "openric:next": ".../records?page=2&limit=50"
}
```

### 4.4 Agents (actors)

| Method & path | Purpose |
|---|---|
| `GET /agents` | Paginated list of agents |
| `GET /agents/{id}` | Single agent as RiC-O JSON-LD |

**List parameters:**

| Param | Meaning |
|---|---|
| `type` | `person`, `corporate body`, `family` |
| `q` | Free-text search on name |
| `page`, `limit` | Pagination |

### 4.5 Repositories

| Method & path | Purpose |
|---|---|
| `GET /repositories` | Paginated list of repositories |
| `GET /repositories/{id}` | Single repository (`rico:CorporateBody` per ISDIAH) |

### 4.6 Functions (optional — L2-full)

| Method & path | Purpose |
|---|---|
| `GET /functions` | Paginated list of ISDF functions |
| `GET /functions/{id}` | Single function as `rico:Function` |

### 4.7 Graph

```
GET /api/ric/v1/graph?uri={entity-uri}&depth={N}
```

Returns a subgraph rooted at `uri`, suitable for visualisation clients. Response shape defined in [Graph Primitives](graph-primitives.html):

```json
{
  "@context": "https://openric.org/ns/v1/context.jsonld",
  "@type": "openric:Subgraph",
  "openric:root": "https://archives.example.org/actor/smuts-jc",
  "openric:depth": 2,
  "openric:nodes": [
    { "id": ".../actor/smuts-jc", "type": "rico:Person",
      "label": "Smuts, Jan Christian" },
    { "id": ".../informationobject/AHG-A001", "type": "rico:RecordSet",
      "label": "Papers of JC Smuts" }
  ],
  "openric:edges": [
    { "source": ".../informationobject/AHG-A001",
      "target": ".../actor/smuts-jc",
      "predicate": "rico:hasCreator",
      "label": "created by" }
  ]
}
```

Parameters:

| Param | Meaning | Default | Max |
|---|---|---|---|
| `uri` | Root entity URI (REQUIRED) | — | — |
| `depth` | BFS depth from root | `1` | `3` |
| `direction` | `in`, `out`, `both` | `both` | — |
| `types` | Comma-separated filter of node RiC types | — | — |

### 4.8 SPARQL (optional — L2-query)

```
GET /api/ric/v1/sparql?query={urlencoded-SPARQL}
POST /api/ric/v1/sparql
```

Passes the query to the server's underlying triple store. Servers MAY impose query complexity limits. Results in standard SPARQL 1.1 Results JSON format.

### 4.9 Validate (optional — L2-query)

```
POST /api/ric/v1/validate
Content-Type: application/ld+json
Body: <candidate RiC-O JSON-LD>
```

Validates the candidate graph against the server's SHACL shapes. Returns a `ValidationReport`:

```json
{
  "@type": "sh:ValidationReport",
  "sh:conforms": false,
  "sh:result": [
    {
      "sh:focusNode": ".../records/xyz",
      "sh:resultPath": "rico:title",
      "sh:resultMessage": "RecordSet must have exactly one non-empty title",
      "sh:resultSeverity": "sh:Violation"
    }
  ]
}
```

### 4.10 Health

```
GET /api/ric/v1/health
```

Returns `{ "status": "ok" }` with HTTP 200 when the server is reachable and its backing store is healthy. Non-authenticated. Intended for monitoring.

### 4.11 RiC-native entities — Places, Rules, Activities, Instantiations

These four entity types are first-class RiC-O resources that exist independently of records. Each gets a list, a show, and (for Places) a flat-name-and-id endpoint suitable for parent pickers.

```
GET /api/ric/v1/places
GET /api/ric/v1/places/{id}
GET /api/ric/v1/places/flat?exclude_id={id}

GET /api/ric/v1/rules
GET /api/ric/v1/rules/{id}

GET /api/ric/v1/activities
GET /api/ric/v1/activities/{id}

GET /api/ric/v1/instantiations
GET /api/ric/v1/instantiations/{id}
```

List endpoints accept `page`, `per_page`, and OPTIONAL type filters matching the taxonomy (e.g. `?type_id=country`). Show endpoints return full `rico:Place` / `rico:Rule` / `rico:ProductionActivity` / `rico:Instantiation` serialisations with any `owl:sameAs` authority links.

`/places/flat` returns `{items: [{id, name}], count}` — small-payload parent-picker companion. Unpaginated; bounded by server-side policy.

### 4.12 Relations

```
GET /api/ric/v1/relations?q={query}&page={p}&per_page={n}
GET /api/ric/v1/relations-for/{entity-id}
GET /api/ric/v1/relation-types?domain={class}&range={class}
```

- `/relations` is the paginated global list. `q` matches against `rico:predicate`, `dropdown_code`, and evidence text.
- `/relations-for/{id}` returns `{outgoing: [...], incoming: [...], total, entity_id}` grouped by direction. Use this on entity show-pages.
- `/relation-types` returns the catalog of allowed relation predicates, optionally filtered by domain/range class.

### 4.13 Hierarchy walk

```
GET /api/ric/v1/hierarchy/{entity-id}?include=parent,children,siblings
```

For Places, returns parent + children + siblings from `ric_place.parent_id`. For other entity types, walks `ric_relation_meta.dropdown_code IN (has_part, includes, is_superior_of, is_part_of, is_included_in)`. Use `include` to restrict the walk.

### 4.14 Autocomplete

```
GET /api/ric/v1/autocomplete?q={query}&types={types}&limit={n}
```

Cross-entity name/title search. `types` is a comma-delimited subset of `place,rule,activity,instantiation,actor,io,repository,digital_object` — omit for all. Returns `[{id, label, type}]`, capped at `limit` (default 20, max 200).

### 4.15 Vocabulary (single-taxonomy)

```
GET /api/ric/v1/vocabulary/{taxonomy}
```

Returns `{taxonomy, items: [{code, label, color, icon, is_default, metadata}], count}`. `{taxonomy}` is a dropdown name like `ric_place_type`, `ric_rule_type`, `ric_activity_type`, `ric_carrier_type`, `ric_relation_type`, `certainty_level`. 404 when the taxonomy isn't defined.

### 4.16 Records — linked RiC entities

```
GET /api/ric/v1/records/{id}/entities?types={types}
```

Aggregates every RiC-native entity linked to a given record (via the `relation` table) into `{places: [...], rules: [...], activities: [...], instantiations: [...]}`. `types` is the same comma-delimited filter as `/autocomplete`.

### 4.17 Entity info card

```
GET /api/ric/v1/entities/{id}/info
```

Minimal JSON-LD entity card: `{id, class, slug, name, type, description}`. For popovers / hover tooltips / autocomplete result expansion. Cheap to fetch.

### 4.18 Write operations *(added post-v0.1.0; L3 conformance)*

All write operations require `X-API-Key` with a scope matching the operation. See §6 (Authentication) for details.

#### 4.18.1 Create / update / delete RiC-native entities

```
POST   /api/ric/v1/{type}              scope: write
PATCH  /api/ric/v1/{type}/{id}         scope: write
PUT    /api/ric/v1/{type}/{id}         scope: write  (alias of PATCH)
DELETE /api/ric/v1/{type}/{id}         scope: delete
```

`{type}` ∈ `places | rules | activities | instantiations`. Body keys match the DB schema for the entity (e.g. for Place: `name`, `type_id`, `latitude`, `longitude`, `authority_uri`, `parent_id`, `address`, `description`). Type picker values come from `/vocabulary/{taxonomy}`.

Success responses:

| Operation | Status | Body |
|---|---|---|
| POST | 201 Created | `{id, slug, type, href}` |
| PATCH/PUT | 200 OK | `{success: true, id}` |
| DELETE | 200 OK | `{success: true, id}` |

#### 4.18.2 Create / update / delete relations

```
POST   /api/ric/v1/relations                scope: write
PATCH  /api/ric/v1/relations/{id}           scope: write
DELETE /api/ric/v1/relations/{id}           scope: delete
```

POST body: `{subject_id, object_id, relation_type}` plus optional `{start_date, end_date, certainty, evidence}`. `relation_type` is a code from `ric_relation_type` vocabulary.

If the underlying `ric_relation_meta` marks the relation as symmetric, the server MUST create a mirror inverse-direction relation at the same time (same `id` space, linked via `ric_relation_meta.inverse_predicate`). Both sides are visible in `/relations-for/{id}` output.

#### 4.18.3 Delete by id (type-agnostic)

```
DELETE /api/ric/v1/entities/{id}            scope: delete
```

Convenience endpoint for UIs that hold a numeric entity id but not its type. Server looks up `object.class_name` and dispatches to the appropriate delete handler. Returns 422 for entities that aren't one of the four RiC-native types.

## 5. Request and response formats

### 5.1 Content negotiation

| `Accept` header | Response |
|---|---|
| `application/ld+json` (default) | RiC-O JSON-LD |
| `application/json` | Same as above — for clients that can't set ld+json |
| `text/turtle` | RiC-O Turtle |
| `application/rdf+xml` | RDF/XML (optional) |

Servers MUST support `application/ld+json`. Other formats are OPTIONAL.

### 5.2 Language negotiation

`Accept-Language` selects the culture for `rico:title`, `rico:description`, etc. Servers SHOULD honour the header. When a requested language is unavailable, the server MUST fall back to the entity's `sourceCulture`.

### 5.3 CORS

All GET endpoints MUST send:

```
Access-Control-Allow-Origin: *
```

This enables browser-based viewers hosted on other domains.

Write endpoints (POST, PATCH, PUT, DELETE) SHOULD also return `Access-Control-Allow-Origin: *` and handle the CORS preflight (`OPTIONS`) with:

```
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, X-API-Key, X-REST-API-Key, Authorization, Accept
Access-Control-Max-Age: 86400
```

Without this, browser-based capture clients (like [capture.openric.org](https://capture.openric.org)) can't write to the server.

## 6. Authentication

**Reads** — public by default. `/health`, `/`, `/vocabulary*`, and the read-side entity + relation + graph endpoints SHOULD be reachable without credentials. An ODRL-based rights-enforcement layer (OpenRiC-Rights, forthcoming) will define how to expose per-record access controls for per-record private reads.

**Writes** — authenticated via `X-API-Key` header. Alternative header names that SHOULD be accepted: `X-REST-API-Key`, `Authorization: Bearer <key>`.

API keys carry a list of **scopes**. The required scope per operation:

| Operation | Required scope |
|---|---|
| `POST /{type}`, `POST /relations` | `write` |
| `PATCH /{type}/{id}`, `PATCH /relations/{id}` | `write` |
| `DELETE /{type}/{id}`, `DELETE /relations/{id}`, `DELETE /entities/{id}` | `delete` |

Missing key → `401 Unauthorized`. Key present but missing scope → `403 Forbidden`. Both responses MUST be JSON: `{error: "unauthorized", message: "…"}`.

Key issuance is operator-defined — the spec doesn't mandate a particular UI or workflow. The reference implementation issues SHA-256-hashed keys with per-key scope lists and optional expiry. See the reference [`ahg-api`](https://github.com/ArchiveHeritageGroup/heratio/tree/main/packages/ahg-api) package for a model.

## 7. Pagination

All list endpoints use the same pattern:

```json
{
  "openric:total": 1423,
  "openric:page": 1,
  "openric:limit": 50,
  "openric:next": ".../records?page=2&limit=50",
  "openric:prev": null,
  "openric:items": [ … ]
}
```

`next` and `prev` are absolute URLs or `null`. Clients SHOULD follow `next` rather than construct their own URLs.

## 8. Error responses

Errors MUST use HTTP status codes correctly and return a JSON error body:

```json
{
  "@type": "openric:Error",
  "openric:status": 404,
  "openric:code": "not-found",
  "openric:message": "No record with identifier 'AHG-XYZ' exists.",
  "openric:detail": ".../records/AHG-XYZ"
}
```

Codes: `not-found`, `forbidden`, `bad-request`, `rate-limited`, `unavailable`, `internal`.

## 9. Rate limiting

Servers SHOULD rate-limit. The reference implementation uses `60 requests / minute / IP`. When limiting, servers MUST return HTTP 429 with `Retry-After` header.

## 10. OpenAPI description

Every conformant server MUST expose a valid OpenAPI 3.1 description at:

```
GET /api/ric/v1/openapi.json
```

This enables auto-generated clients, Postman collections, and CI validation.

## 11. Change log

| Version | Date | Notes |
|---|---|---|
| 0.1.0-draft | 2026-04-17 | Initial draft extracted from Heratio `LinkedDataApiController`. |

---

[Back to OpenRiC](../)
