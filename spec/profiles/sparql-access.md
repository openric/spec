---
layout: default
title: OpenRiC - SPARQL Access Profile
description: Optional 8th profile. SPARQL 1.1 query endpoint over the canonical RDF graph backing an OpenRiC server. Draft.
---

# SPARQL Access Profile

**Profile id:** `sparql-access`
**Profile version:** 0.1.0
**Spec version:** 0.37.0
**Status:** **Draft** - open for implementer review
**Dependencies:** None - orthogonal to Core Discovery
**Last updated:** 2026-04-25

---

## 1. Purpose

SPARQL Access is the OpenRiC profile for **graph-query access** to the RDF dataset backing a conformant server. Where the seven Normative profiles define HTTP/JSON-LD shapes for retrieving and editing entities, SPARQL Access exposes the same data through a SPARQL 1.1 query endpoint - for graph-walking analyses, federated queries, and downstream RDF tooling that doesn't speak the OpenRiC HTTP API.

This profile is **optional**. Many OpenRiC servers (especially API-first or RDB-backed implementations) will not expose SPARQL. Servers that do back their data with a triplestore (Fuseki/Jena, GraphDB, QLever, Blazegraph, …) MAY claim this profile to advertise the query surface to consumers.

A server implementing this profile commits to two things:

1. **Expose a SPARQL 1.1 query endpoint** over the canonical RDF graph backing the server's RiC-O / openricx output, with a documented graph scope, access policy, and rate-limit posture.
2. **Publish dataset metadata** - `void:Dataset` description, example queries, and any access-control caveats - so consumers can discover what's queryable and how.

This profile **does not** require SPARQL Update (write access). Read-only SPARQL Query (1.1) is the normative surface. Update is a separate, future profile candidate (`sparql-update`).

## 2. Scope

### 2.1 Required endpoints

| Verb | Path | Returns |
|---|---|---|
| GET / POST | `/api/ric/v1/sparql` | SPARQL 1.1 Query results - `application/sparql-results+json` (default), `application/sparql-results+xml`, `text/csv`, `text/turtle` (CONSTRUCT/DESCRIBE), `application/ld+json` (CONSTRUCT/DESCRIBE) |
| GET | `/api/ric/v1/sparql/info` | Dataset metadata: `void:Dataset` description with triple count, graph scope, example queries (HTML or JSON-LD per content negotiation) |

### 2.2 Optional endpoints

| Verb | Path | Purpose |
|---|---|---|
| GET | `/api/ric/v1/sparql/examples` | Library of example SPARQL queries with descriptions - useful for developer onboarding |
| GET | `/api/ric/v1/sparql/health` | SPARQL-specific liveness probe (separate from the global `/health`) |

### 2.3 Forbidden without additional profile claims

- **SPARQL Update** (`INSERT DATA`, `DELETE DATA`, `CLEAR`, `LOAD`) - separate (forthcoming) `sparql-update` profile.
- **SPARQL Graph Store HTTP Protocol** - separate profile candidate.

A server claiming `sparql-access` MUST reject SPARQL Update operations with `405 Method Not Allowed` or `403 Forbidden` (per the chosen access-control posture).

### 2.4 Content types

- Default response: `application/sparql-results+json` for SELECT/ASK; `text/turtle` for CONSTRUCT/DESCRIBE.
- Servers MUST honour the `Accept` header per the SPARQL 1.1 Protocol.
- All non-SPARQL errors (malformed query, rate limit, auth) MUST follow Core Discovery §4 - `application/problem+json` with `https://openric.org/errors/{type}` URIs.

## 3. Access policy

A server claims `sparql-access` with an explicit access-policy declaration in the service description:

```json
"openric_conformance": {
  "profiles": [
    { "id": "sparql-access", "version": "0.1.0",
      "access": "public-read",
      "rate_limit": "60/minute/IP",
      "max_query_time_seconds": 30,
      "endpoint": "/api/ric/v1/sparql" }
  ]
}
```

`access` MUST be one of:

| Value | Meaning |
|---|---|
| `public-read` | Anonymous SPARQL queries permitted |
| `authenticated-read` | Requires API key (per Round-Trip Editing §2.2 auth model) |
| `tenant-restricted` | Requires API key + caller-tenant filtering applied server-side |

`rate_limit` and `max_query_time_seconds` are SHOULD-document fields. Implementations MUST enforce both - SPARQL has no built-in protection against runaway queries.

## 4. Response shapes

### 4.1 SELECT result (default JSON)

Standard SPARQL 1.1 Results JSON Format:

```json
{
  "head": { "vars": ["agent", "name"] },
  "results": {
    "bindings": [
      { "agent": { "type": "uri", "value": "https://archives.example.org/agent/smuts-jc" },
        "name":  { "type": "literal", "value": "Smuts, Jan Christian" } }
    ]
  }
}
```

### 4.2 CONSTRUCT result (JSON-LD)

When `Accept: application/ld+json`, CONSTRUCT and DESCRIBE results MUST emit JSON-LD with the OpenRiC context bound (`rico`, `openricx`, `skos`, `dcterms` per [mapping.md §4](/spec/mapping.html)).

### 4.3 Dataset description (`/sparql/info`)

```turtle
@prefix void: <http://rdfs.org/ns/void#> .
@prefix dcterms: <http://purl.org/dc/terms/> .

<https://archives.example.org/api/ric/v1/sparql> a void:Dataset ;
    dcterms:title "Example Archives RiC-O dataset" ;
    void:sparqlEndpoint <https://archives.example.org/api/ric/v1/sparql> ;
    void:triples 1234567 ;
    void:vocabulary <https://www.ica.org/standards/RiC/ontology#> ,
                    <https://openric.org/ns/ext/v1#> ,
                    <http://www.w3.org/2004/02/skos/core#> ;
    dcterms:license <https://creativecommons.org/licenses/by/4.0/> .
```

## 5. SHACL shapes

Responses validate against `shapes/profiles/sparql-access.shacl.ttl` (planned, v0.7+):

| Shape | Target | Severity model |
|---|---|---|
| `:SparqlInfoShape` | `/sparql/info` response root | `sh:Violation` on missing `void:Dataset`, `void:sparqlEndpoint`, `void:triples`; `sh:Warning` on missing `dcterms:license` |
| `:SparqlConstructShape` | CONSTRUCT response when `Accept: application/ld+json` | `sh:Violation` if `@context` is absent or doesn't bind `rico` and `openricx` |

Shape file is not yet shipped - this is a Draft profile.

## 6. Conformance testing

A server claims `sparql-access` when:

1. `GET /api/ric/v1/sparql?query=ASK { ?s ?p ?o }` returns `200` with `{ "boolean": true }`.
2. `GET /api/ric/v1/sparql/info` returns a valid `void:Dataset` description.
3. The endpoint enforces the declared `rate_limit` and `max_query_time_seconds`.
4. Update operations (`INSERT DATA` etc.) are rejected per §2.3.
5. Errors (malformed query, rate limit, auth failure) follow RFC 7807 per Core Discovery §4.

The conformance probe with `--profile=sparql-access` exercises checks 1–4 against a live server.

## 7. Fixture pack

Two fixtures planned for v0.8 of this profile (currently absent):

| Fixture | Status | What it pins |
|---|---|---|
| `sparql-info` | **planned** | Minimum-viable `/sparql/info` `void:Dataset` description |
| `sparql-construct` | **planned** | CONSTRUCT result emitted as JSON-LD with full `@context` binding |

## 8. Implementation checklist

- [ ] Choose a triplestore - Fuseki/Jena, GraphDB, QLever, Blazegraph, or other SPARQL 1.1-conformant engine
- [ ] Mount the SPARQL endpoint at `/api/ric/v1/sparql` (proxy or direct)
- [ ] Document the dataset graph scope - single default graph, named graphs, tenant-isolated graphs?
- [ ] Configure server-side query timeout (default ≤ 30s for `public-read`)
- [ ] Configure rate limiting (default 60 requests / minute / IP for `public-read`)
- [ ] Reject SPARQL Update with `405` or `403`
- [ ] Publish `/sparql/info` with `void:Dataset` triple count + license
- [ ] Add `sparql-access` to `openric_conformance.profiles` with `access` / `rate_limit` / `max_query_time_seconds` declared
- [ ] Run the conformance probe with `--profile=sparql-access`

## 9. Design decisions

### Q1 - Why a separate profile, not a Core Discovery requirement?

**Resolution**: SPARQL Access is **optional** because many OpenRiC implementations are API-first - they don't store data as RDF triples internally and cannot trivially expose a SPARQL endpoint. Forcing SPARQL on every conformant server would exclude RDB-backed implementations that would otherwise meet Core Discovery / Authority & Context. SPARQL is a strong-and-distinct capability, not a baseline.

### Q2 - Why not require SPARQL Update?

**Resolution**: SPARQL Update is a **separate future profile** (`sparql-update`) because the security and concurrency model for write SPARQL is fundamentally different - it touches every triple in the store with a single statement, which makes audit-trail recording (Round-Trip Editing §3.3) hard. Implementations that want write SPARQL access can ship it as an extension; this profile is intentionally read-only.

### Q3 - Default access posture: public or authenticated?

**Resolution**: **Implementer-declared via the `access` field in the service description**, with `public-read` as the documented default for institutional reference-data publication (consistent with Garance's pattern). Implementations holding sensitive metadata (PII, restricted records) MUST declare `authenticated-read` or `tenant-restricted` and enforce it.

### Q4 - Triplestore engine recommendation?

**Resolution**: **Engine-agnostic**. The profile defines the surface, not the implementation. Reference implementations using Fuseki/Jena and QLever both exist (the AnF Garance project uses QLever; the OpenRiC reference service uses Fuseki/Jena via the Heratio `ahg-ric` package). Performance characteristics differ - see the [Garance project benchmarks](https://github.com/sparna-git/garance) for QLever-specific guidance.

### Q5 - Should this profile be Normative or Draft for v1.0?

**Resolution**: **Draft** for now. The profile becomes Normative when:

1. At least one non-reference implementation passes the conformance probe with `--profile=sparql-access`.
2. SHACL shapes (§5) are shipped.
3. Two fixtures (§7) are shipped.
4. Community feedback on the access-policy taxonomy (§3) settles.

Until then, implementations MAY claim this profile but the shape file and fixtures are not yet load-bearing.
