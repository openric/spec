---
layout: default
title: OpenRiC — Core Discovery Profile
description: The minimum-viable OpenRiC conformance target. Read-only Records, Agents, Repositories, vocabulary, autocomplete. Ten endpoints, three entity types.
---

# Core Discovery Profile

**Profile id:** `core-discovery`
**Profile version:** 0.3.0-draft
**Spec version:** 0.3.0
**Status:** Draft — open for comment
**Dependencies:** None
**Last updated:** 2026-04-19

---

## 1. Purpose

Core Discovery is the **minimum-viable OpenRiC conformance target**. A server that implements this profile can be listed, browsed, searched, and dereferenced for records, agents, and repositories — but is not required to expose graph traversal, relations, authority entities, activities, digital objects, write verbs, or OAI-PMH harvesting.

This profile answers the question: *"what is the smallest thing my system can expose and still call itself OpenRiC-compliant?"*

Typical use cases:

- **Legacy catalogues** publishing a read-only window over existing records.
- **Aggregator back-ends** that only need to ingest descriptions, not the full graph.
- **First-stage implementations** on their way to wider profile coverage.

## 2. Scope

### 2.1 Required endpoints

A server claiming Core Discovery conformance MUST implement all ten endpoints below under a single base URL:

| # | Method + path | Purpose |
|---|---|---|
| 1 | `GET /` | Service description with `openric_conformance` declaration |
| 2 | `GET /health` | Liveness probe — `{"status":"ok"}` |
| 3 | `GET /vocabulary` | rico:* term catalogue used by clients to render type labels |
| 4 | `GET /records` | List and search records; pagination required |
| 5 | `GET /records/{key}` | Single record by slug or numeric id |
| 6 | `GET /agents` | List and search agents; pagination required |
| 7 | `GET /agents/{key}` | Single agent |
| 8 | `GET /repositories` | List repositories |
| 9 | `GET /repositories/{key}` | Single repository |
| 10 | `GET /autocomplete?q=&types=` | Cross-entity prefix search; `types` filter supports `record,agent,repository` |

All endpoints are unauthenticated reads. Rate limiting is allowed but MUST return RFC 6585 `429 Too Many Requests` with a `Retry-After` header when applied.

<!-- TK Q3: confirm /autocomplete stays in Core Discovery. Discovery without search is navigation-only, which is a weaker position than IIIF Level 0. Lean: yes. -->
<!-- TK Q4: repositories in Core Discovery vs Authority & Context. Lean: keep in Core because `rico:heldBy` is emitted inline on records. -->

### 2.2 Forbidden endpoints (without additional profile claims)

A server that claims **only** Core Discovery MUST NOT implement or reference:

- `/graph`, `/hierarchy/{id}`, `/relations`, `/relations-for/{id}` — belong to the forthcoming Graph Traversal profile
- `/activities`, `/places`, `/rules`, `/functions`, `/instantiations` — Authority & Context, Provenance, Digital Object profiles
- `/oai` — Export-Only profile
- `POST`, `PATCH`, `PUT`, `DELETE` on any resource — Round-Trip Editing profile

A server MAY implement these if it also declares the relevant profile. Silently implementing them without declaration is a conformance failure because it misleads consumers about the capability surface.

### 2.3 Content types

All responses MUST support:

- `application/ld+json` — JSON-LD with the OpenRiC context
- `application/json` — same content; `@context` MAY be trimmed to a URL reference

Servers MUST set `Vary: Accept` on every response that content-negotiates.

## 3. Response shapes

### 3.1 Service description — `GET /`

```json
{
  "name": "string, human-readable service name",
  "version": "string, implementation version",
  "openric_conformance": {
    "spec_version": "0.3.0",
    "profiles": [
      {
        "id": "core-discovery",
        "version": "0.3.0",
        "level": "L2",
        "conformance": "full"
      }
    ]
  }
}
```

The `openric_conformance` object is REQUIRED. At least one profile MUST be declared; `core-discovery` MUST appear if this profile is claimed.

### 3.2 Vocabulary — `GET /vocabulary`

Returns an ordered array of rico:* types with labels. Minimum shape:

```json
{
  "@context": "https://openric.org/ns/v1/context.jsonld",
  "classes": [
    { "@id": "rico:Record", "rdfs:label": "Record" },
    { "@id": "rico:Agent", "rdfs:label": "Agent" }
  ],
  "properties": [
    { "@id": "rico:title", "rdfs:label": "Title" }
  ]
}
```

Only classes and properties actually exposed by the server's declared profiles need be listed. A Core-Discovery-only server lists Record, Agent, CorporateBody (for repositories), and the property set it emits.

### 3.3 List responses — `GET /records`, `/agents`, `/repositories`

Pagination envelope:

```json
{
  "@context": "https://openric.org/ns/v1/context.jsonld",
  "total": 713,
  "limit": 20,
  "offset": 0,
  "items": [
    { "@id": "...", "@type": "rico:Record", "rico:title": "..." }
  ]
}
```

- `total` MUST reflect the unfiltered set size when no query is supplied, or the filtered size when `?q=` or equivalent is present.
- `limit` and `offset` MUST be integers.
- Each item MUST include at minimum `@id`, `@type`, and a name-like field (`rico:title` for records, `rico:name` or `rico:hasAgentName` for agents and repositories).
- Servers MUST emit RFC 5988 `Link` headers with `rel="next"` and `rel="prev"` when applicable.

<!-- TK Q5: confirm mandatory pagination. Lean: yes, unbounded responses are a client footgun. -->

### 3.4 Single-entity responses

#### 3.4.1 `GET /records/{key}`

**Required fields:**

| Field | Cardinality | Notes |
|---|---|---|
| `@id` | 1 | Stable IRI, dereferenceable (SHOULD 303-redirect to content-negotiated representation) |
| `@type` | 1 | `rico:Record` (other subclasses allowed but MUST extend this) |
| `rico:title` OR `rico:hasName` | 1 | Multilingual via `@language` tags permitted |
| `rico:identifier` | 1 | String |

**Optional fields (permitted in this profile):**

| Field | Cardinality | Notes |
|---|---|---|
| `rico:description` | 0..1 | Long-form prose |
| `rico:hasBeginningDate` | 0..1 | xsd:gYear / xsd:date / xsd:dateTime |
| `rico:hasEndDate` | 0..1 | Same types as above |
| `rico:heldBy` | 0..1 | Embedded partial repository object — `@id`, `@type`, `rico:name` only |
| `rico:hasCreator` | 0..n | Embedded partial agent objects — `@id`, `@type`, `rico:name` only |

**Forbidden without other profile claims:**

- `rico:isOrWasSubjectOf`, `rico:hasOrHadSubject` — require Graph Traversal profile
- `rico:hasInstantiation` — requires Digital Object Linkage profile
- `rico:hasAcquisitionProvenance` — requires Provenance & Event profile

#### 3.4.2 `GET /agents/{key}`

**Required fields:**

| Field | Cardinality | Notes |
|---|---|---|
| `@id` | 1 | |
| `@type` | 1 | One of `rico:Agent`, `rico:Person`, `rico:CorporateBody`, `rico:Family` |
| `rico:name` OR `rico:hasAgentName` | 1 | Either shorthand or canonical AgentName object permitted (v0.2+) |

**Optional fields:**

| Field | Cardinality | Notes |
|---|---|---|
| `rico:history` | 0..1 | Biographical / administrative prose |
| `rico:hasBeginningDate` | 0..1 | |
| `rico:hasEndDate` | 0..1 | |

#### 3.4.3 `GET /repositories/{key}`

**Required fields:**

| Field | Cardinality | Notes |
|---|---|---|
| `@id` | 1 | |
| `@type` | 1 | `rico:CorporateBody` |
| `rico:name` | 1 | |

**Optional fields:**

| Field | Cardinality | Notes |
|---|---|---|
| `rico:history` | 0..1 | |
| Contact point (single object) | 0..1 | Shape TBD; see TK below |

<!-- TK: contact-point shape pending SHACL alignment. Likely schema:ContactPoint or rico:ContactName. -->

### 3.5 Autocomplete — `GET /autocomplete?q=&types=&limit=`

```json
{
  "query": "pieters",
  "items": [
    { "@id": "...", "@type": "rico:Person", "label": "Pieterse, Johan", "score": 0.95 }
  ]
}
```

- `q` parameter REQUIRED; 2-character minimum enforced server-side.
- `types` parameter OPTIONAL; accepts comma-separated `record`, `agent`, `repository`. Defaults to all.
- `limit` parameter OPTIONAL; defaults to 10, maximum 50.

## 4. Error handling

Errors MUST use the RFC 7807 Problem Details shape:

```json
{
  "type": "https://openric.org/errors/not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "Record with key 'abc123' does not exist",
  "instance": "/api/ric/v1/records/abc123"
}
```

Implementations MAY emit additional fields alongside the RFC 7807 base fields. Content type MUST be `application/problem+json` for error responses.

<!-- TK Q6: RFC 7807 shift from Heratio's current {success:false} envelope. Breaks v0.2 clients. Decide before freeze. -->

## 5. SHACL shapes

Core Discovery responses MUST validate against the profile-scoped shape file:

```
shapes/profiles/core-discovery.shacl.ttl
```

This file is a strict subset of the main `shapes/openric.shacl.ttl` containing only:

- `:RecordShape` — with forbidden-predicate rules for Graph/Authority/Provenance fields
- `:AgentShape` — with minimum-name constraint
- `:CorporateBodyShape` — for repositories
- `:AgentNameShape` — for canonical name resolution
- `:DateRangeShape` — for date fields

Shapes are **open** — unknown predicates do not cause failure. Implementations MAY emit private metadata.

<!-- TK Q7: confirm open shapes (implementer-friendly) vs closed shapes (strict). Lean: open; closed shapes punish implementations for harmless additions. -->

## 6. Conformance testing

The conformance probe runs profile-scoped:

```bash
./probe.sh --profile core-discovery {base-url}
```

The probe MUST:

1. Fetch `GET /` and verify `openric_conformance.profiles` contains `core-discovery`
2. Hit each of the ten required endpoints
3. Validate responses against their JSON Schemas
4. Validate against `shapes/profiles/core-discovery.shacl.ttl`
5. Verify no forbidden predicates appear in responses
6. Verify pagination links on list endpoints
7. Verify RFC 7807 error shape on a deliberate 404
8. Emit a JSON report — `{"profile":"core-discovery", "level":"L2", "pass":true, "tests":[...]}`

A server passes Core Discovery conformance when all tests pass. A server may pass at `level: L1` (mapping only) or `L2` (full API); higher levels require graph-primitives support, which is out of scope for this profile.

## 7. Fixture pack

The following existing fixtures exercise Core Discovery and ship in the profile manifest at `fixtures/profiles/core-discovery/manifest.json`:

1. `service-description` — `GET /`
2. `vocabulary` — `GET /vocabulary`
3. `record-list` — `GET /records` list envelope
4. `fonds-minimal` — `GET /records/{key}` minimal valid record
5. `fonds-with-children` — `GET /records/{key}` with nested structure (fields trimmed to profile)
6. `record-multilingual` — `GET /records/{key}` with `@language` tagged titles
7. `agent-person-simple` — `GET /agents/{key}` minimal Person
8. `agent-corporate-body` — `GET /agents/{key}` CorporateBody
9. `agent-family` — `GET /agents/{key}` Family
10. `autocomplete-egypt` — `GET /autocomplete` cross-entity hit
11. `error-not-found` — RFC 7807 error envelope

The manifest declares these eleven fixtures as normative for `core-discovery`. Fixtures outside this list are NOT required for profile conformance.

## 8. Implementation checklist

A server implementer works through:

- [ ] Implement or expose the ten required endpoints under a single base URL
- [ ] Emit `openric_conformance` in the service description with `profiles: [{id: "core-discovery", ...}]`
- [ ] Ensure responses satisfy the minimum-field requirements in §3
- [ ] Remove or gate forbidden predicates (see §2.2 and §3.4)
- [ ] Return RFC 7807 errors with `application/problem+json` content type
- [ ] Support content negotiation; set `Vary: Accept`
- [ ] Enable CORS for reads: `Access-Control-Allow-Origin: *`
- [ ] Paginate list responses with RFC 5988 Link headers
- [ ] Run `./probe.sh --profile core-discovery {base-url}` — all tests pass
- [ ] Validate responses against `shapes/profiles/core-discovery.shacl.ttl`

## 9. Migration from v0.2.0

Servers currently claiming `L2-core` conformance per the pre-v0.3 [Viewing API §2](../viewing-api.html#2-conformance-levels) should transition as follows:

| v0.2 claim | v0.3 equivalent |
|---|---|
| `L2-core` | `{"id":"core-discovery", "version":"0.3.0", "level":"L2"}` |
| `L2-graph` | `[{"id":"core-discovery"}, {"id":"graph-traversal"}]` (Graph Traversal not yet defined; claim becomes pending until v0.4) |
| `L2-full` | All six profiles once defined |

Servers using the Heratio-style `{"success":false, "error":"..."}` error envelope will need to switch to RFC 7807 to claim Core Discovery. This is the one breaking change in the v0.2 → v0.3 transition.

## 10. Open design questions

These questions are open for reviewer comment before the v0.3.0 freeze. Marked inline with `<!-- TK QN: -->` comments throughout this document:

- **Q1** — Is "Core Discovery" the right name, or should we follow IIIF's Level 0/1/2 numbering?
- **Q3** — Should `/autocomplete` stay in Core Discovery or move to its own Search profile?
- **Q4** — Repositories as first-class in Core Discovery, or behind an Authority & Context claim?
- **Q5** — Pagination mandatory on list endpoints?
- **Q6** — Mandate RFC 7807 error envelope in v0.3, or keep both shapes as accepted?
- **Q7** — SHACL shapes open (tolerant of unknown predicates) or closed (strict)?
- **Q8** — Profile versions track spec versions, or have their own lifecycle?

Comments welcome at <https://github.com/ArchiveHeritageGroup/openric-spec/discussions>.

---

*Copyright © 2026 The Archive and Heritage Group (Pty) Ltd and the OpenRiC contributors. Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Editor: Johan Pieterse ([johan@plainsailingisystems.co.za](mailto:johan@plainsailingisystems.co.za)).*
