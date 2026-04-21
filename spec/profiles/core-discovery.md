---
layout: default
title: OpenRiC — Core Discovery Profile
description: The minimum-viable OpenRiC conformance target. Read-only Records, Agents, Repositories, vocabulary, autocomplete. Ten endpoints, three entity types.
---

# Core Discovery Profile

**Profile id:** `core-discovery`
**Profile version:** 0.3.0
**Spec version:** 0.3.0
**Status:** Normative
**Dependencies:** None
**Last updated:** 2026-04-21

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

<!-- Q3: Resolved — /autocomplete stays in Core Discovery. See §10 Q3. -->
<!-- Q4: Resolved — repositories first-class in Core Discovery. See §10 Q4. -->

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

<!-- Q5: Resolved — pagination mandatory; default page 50, max 200. See §10 Q5. -->

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
| `rico:contact` | 0..1 | Single `rico:ContactPoint` object; shape in §3.4.1 |

#### 3.4.1 `rico:ContactPoint` shape

The contact point is a single embedded object under `rico:contact`, typed `rico:ContactPoint`. Consistent with `spec/mapping.md` §5.2.2 (ISDIAH 5.2.2 → `rico:contact → rico:ContactPoint`). All subfields are OPTIONAL — emit only what you have; omit nulls. Implementations MUST NOT invent alternative property names.

```json
{
  "rico:contact": {
    "@type": "rico:ContactPoint",
    "rico:streetAddress": "Private Bag X236",
    "rico:postalCode": "0001",
    "rico:city": "Pretoria",
    "rico:country": "ZA",
    "rico:telephone": "+27 12 323 5300",
    "rico:email": "info@example.org"
  }
}
```

| Field | Cardinality | Notes |
|---|---|---|
| `@type` | 1 | MUST be `rico:ContactPoint` |
| `rico:streetAddress` | 0..1 | Free-form single-line address |
| `rico:postalCode` | 0..1 | |
| `rico:city` | 0..1 | |
| `rico:country` | 0..1 | ISO 3166-1 alpha-2 RECOMMENDED |
| `rico:telephone` | 0..1 | E.164 RECOMMENDED |
| `rico:email` | 0..1 | |

**Rationale for `rico:ContactPoint` over `schema:ContactPoint`.** The Core Discovery profile is RiC-native and avoids cross-vocabulary dependencies in its normative surface. `schema.org/ContactPoint` is a valid alternative shape in a non-normative `@context` alias; implementations that want schema.org interop MAY emit the same object under `schema:contactPoint` in addition, but a Core-Discovery-conformant response MUST emit the `rico:contact → rico:ContactPoint` form.

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

Errors MUST use the RFC 7807 Problem Details shape with `Content-Type: application/problem+json`:

```json
{
  "type": "https://openric.org/errors/not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "Record with key 'abc123' does not exist",
  "instance": "/api/ric/v1/records/abc123"
}
```

The five base fields (`type`, `title`, `status`, `detail`, `instance`) are REQUIRED. Implementations MAY emit additional fields alongside them — for example, an `id` of the missing entity, a `code` shorthand, a `max_bytes` upload ceiling, a validation `example`. Clients MUST tolerate unknown fields.

### 4.1 Error-type URIs

The `type` field is the stable identifier clients SHOULD dispatch on. Titles and details are human-readable and MAY be reworded or localised without breaking clients. The registered types, with their HTTP status codes, are:

| Type URI | HTTP status | Used for |
|---|---|---|
| `https://openric.org/errors/not-found` | 404 | Entity does not exist |
| `https://openric.org/errors/bad-request` | 400 | Malformed request — missing or nonsense parameters |
| `https://openric.org/errors/validation-failed` | 422 | Request shape was fine; content did not pass validation |
| `https://openric.org/errors/authentication-required` | 401 | Protected route hit without credentials |
| `https://openric.org/errors/forbidden` | 403 | Credentials valid but insufficient scope |
| `https://openric.org/errors/conflict` | 409 | State conflict — e.g. delete blocked by descendants |
| `https://openric.org/errors/payload-too-large` | 413 | Upload exceeded the size ceiling |
| `https://openric.org/errors/unsupported-media-type` | 415 | Content-Type not accepted for this endpoint |
| `https://openric.org/errors/internal-error` | 500 | Unexpected server-side failure |

Implementations MAY mint additional types for implementation-specific errors; such types MUST live under a URI prefix the implementer controls (NOT under `https://openric.org/errors/`), and the HTTP status MUST match the meaning in RFC 9110.

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

<!-- Q7: Resolved — open shapes (tolerant of unknown predicates). See §10 Q7. -->

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

## 10. Design decisions

Seven questions were flagged during drafting. All seven are resolved in the normative v0.3.0 profile. Rationale is retained below for the record; any resolution can be re-opened via a GitHub discussion citing the question ID.

**A note on numbering**: Q2 was retired during early drafting; the remaining questions keep their original IDs (Q1, Q3–Q8) so cross-document references stay stable. Any resolution below can be re-opened via a GitHub discussion citing the question ID.

### Q1 — "Core Discovery" name vs IIIF Level 0/1/2 numbering

**Question**: Should profiles follow IIIF's numeric Level 0/1/2 convention, or keep named profiles?

**Resolution**: **Keep named profiles.** "Core Discovery", "Authority & Context", etc.

**Rationale**: IIIF's numeric levels assume nested supersets — Level 1 contains Level 0. OpenRiC profiles are *bounded capability axes* that are largely orthogonal, not layered. A server might claim Core Discovery + Digital Object Linkage without ever implementing Round-Trip Editing, and numeric levels would falsely imply a ladder. Names preserve semantic flavour and avoid misrepresenting the design.

*External review welcome on*: whether one profile should nonetheless be declared the "floor" in governance.

### Q3 — `/autocomplete` in Core Discovery or a separate Search profile?

**Question**: Is `/autocomplete` discovery, or is it search?

**Resolution**: **Stays in Core Discovery.**

**Rationale**: A discovery profile without type-ahead reads as navigation-only, which is a weaker position than IIIF Image API Level 0 (which at least delivers full images). Users evaluating whether to adopt OpenRiC will expect `/autocomplete` at the first step; carving it into a separate profile would make the default conformance target look incomplete. A richer Search profile can still add faceting, filters, and relevance tuning on top.

### Q4 — Repositories as first-class in Core Discovery, or behind Authority & Context?

**Question**: Should `GET /repositories/{key}` and repository inclusion in lists require an A&C profile claim?

**Resolution**: **First-class in Core.**

**Rationale**: `rico:heldBy` is emitted inline on every record in the list and detail shapes already. If repositories were A&C-only, every Core-only implementation would have to either strip the `heldBy` triple (losing material context) or leak a class the profile doesn't cover (breaking conformance). First-classing repositories matches what real archival discovery always needs — "who holds this?" is a first-order discovery question, not an authority-control detail.

### Q5 — Pagination mandatory on list endpoints?

**Question**: Must `GET /records`, `/agents`, `/repositories` paginate, or is unbounded allowed?

**Resolution**: **Mandatory pagination.** Default page size 50, max 200.

**Rationale**: Unbounded list responses are a client footgun: a `/records` endpoint with 100,000 rows tanks page loads, wastes bandwidth, and exposes every client to a memory-pressure bug nobody signed up for. Every known conformant implementation paginates anyway; codifying it avoids a failure mode where one impl ships unbounded and clients hand-written against it break against everyone else.

*External review welcome on*: the specific default (50) and max (200) page sizes.

### Q6 — Error envelope shift to RFC 7807 in v0.3?

**Question**: Mandate `application/problem+json` in v0.3 and deprecate the existing `{success: false, error: …}` envelope, or accept both?

**Resolution**: **Mandate RFC 7807 in v0.3. No migration window.**

**Rationale**: There are no external v0.2 clients to accommodate — only the reference server itself was emitting the old envelope, and the migration landed in the reference implementation at the same time as this resolution (OpenRiC service v0.8.11, `packages/ahg-ric/src/Support/ProblemDetails.php`). Accepting both shapes indefinitely would lock every future implementer into emitting two error formats on every 4xx/5xx, which is strictly worse than a single IETF-standard shape. A migration window buys nothing when the only affected client is the one doing the migration. The nine registered error-type URIs are in §4.1; they cover the full surface the reference implementation currently returns. Implementations MAY mint additional types under a prefix they control, as §4.1 states.

### Q7 — SHACL shapes open or closed?

**Question**: Should Core Discovery SHACL shapes use `sh:closed true` (reject unknown predicates) or leave shapes open?

**Resolution**: **Open shapes.**

**Rationale**: Closed shapes punish harmless additions — a reference server adding `rico:someInternalMarker` for operational reasons while still satisfying every Core Discovery requirement would fail validation under closed shapes. That turns every future spec extension into a coordinated flag day for every implementation. Open shapes let the ecosystem extend forward-compatibly: new predicates don't break old validators, and closed-shape validation can still be offered as a stricter optional profile for implementers who want it.

### Q8 — Profile lifecycle: tracks spec versions, or independent?

**Question**: Does Core Discovery v0.3 have to move to v0.4 when the spec does?

**Resolution**: **Independent lifecycle.**

**Rationale**: Spec version describes the HTTP contract (paths, response shapes, auth). Profile version describes a conformance-claim scope. An implementation might sit at Core Discovery v0.3 while the spec as a whole is at v0.4; the reverse is unlikely but permitted. Independent lifecycles mean we can revise Core Discovery without forcing a spec-wide freeze, and freezing the spec doesn't rush unpolished profiles out. Matches IIIF's multi-API approach — Image API and Presentation API ship on separate cadences.

*External review welcome on*: whether profile versions should declare a *minimum* spec version they require (likely yes) and a *maximum* (likely no — forward-compatible).

---

Comments on any of these — including arguments to reverse a draft resolution — are welcome at <https://github.com/ArchiveHeritageGroup/openric-spec/discussions>.

---

*Copyright © 2026 The Archive and Heritage Group (Pty) Ltd and the OpenRiC contributors. Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Editor: Johan Pieterse ([johan@plainsailingisystems.co.za](mailto:johan@plainsailingisystems.co.za)).*
