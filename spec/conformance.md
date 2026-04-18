---
layout: default
title: OpenRiC Conformance
---

# OpenRiC Conformance

**Version:** 0.1.0-draft
**Status:** Draft — open for comment
**Last updated:** 2026-04-17

---

## 1. Purpose

Defines what it means for an implementation to be "OpenRiC-conformant." Conformance is **machine-checkable**: a CLI validator runs against a live server and produces a pass/fail report.

This document specifies:
- The four conformance levels and their requirements.
- The SHACL shape files every implementation MUST validate its output against.
- The fixture pack (paired input / expected output pairs).
- The `openric-validate` CLI and its exit semantics.
- How implementations self-report conformance.

## 2. Conformance levels

| Level | Name | Requirement |
|---|---|---|
| **L1** | Mapping conformance | The implementation translates each fixture input into RiC-O output that is isomorphic (per SPARQL graph equality) to the canonical expected output. |
| **L2** | Viewing API conformance | All endpoints marked "REQUIRED" in [Viewing API](viewing-api.html) §4 are implemented, return correct content types, and pass their respective JSON Schemas. |
| **L3** | Graph primitives conformance | All subgraph responses satisfy the six invariants in [Graph Primitives](graph-primitives.html) §6. |
| **L4** | Full conformance | L1 + L2 + L3, plus round-trip (input → RiC → subgraph → viewer-ready) passes with no data loss against the round-trip fixture set. |

Implementations advertise the highest level they claim. Claims are verifiable — the validator CLI reports actual level, which MUST match the claim.

## 3. Normative validation inputs

### 3.1 SHACL shapes — `shapes/openric.shacl.ttl`

Every RiC-O entity emitted MUST validate against the corresponding SHACL node shape. The shape file is versioned with the spec. Shapes use the `sh:` namespace per W3C SHACL 1.0.

The shape file defines, at minimum:

| Node shape | Target class | Key constraints |
|---|---|---|
| `:RecordSetShape` | `rico:RecordSet` | `rico:title` required (1 string), `rico:identifier` recommended, `rico:hasDateRangeSet` recommended |
| `:RecordShape` | `rico:Record` | As RecordSet; `rico:isContainedIn` required if not a root |
| `:AgentShape` | `rico:Agent` (and subclasses) | `rico:name` required, `rico:hasDateRangeSet` with `dateType=existence` recommended |
| `:RepositoryShape` | `rico:CorporateBody` with `openric:role=repository` | `rico:name` required, `rico:hasPlace` recommended |
| `:FunctionShape` | `rico:Function` | `rico:name` required |
| `:DateRangeShape` | `rico:DateRange` | At least one of `rico:startDate` / `rico:endDate` / `rico:normalizedDate` |
| `:ExtentShape` | `rico:Extent` | `rico:extentType` required |
| `:LanguageShape` | `rico:Language` | `rico:languageCode` required, MUST be ISO 639-3 |

Severity levels: `sh:Violation` (L1 fail), `sh:Warning` (advisory), `sh:Info`.

### 3.2 JSON Schemas — `schemas/*.schema.json`

Every endpoint response MUST validate against its JSON Schema. Schemas are JSON Schema 2020-12.

| Schema | Validates |
|---|---|
| `service-description.schema.json` | `GET /` |
| `vocabulary.schema.json` | `GET /vocabulary` |
| `record-list.schema.json` | `GET /records` |
| `record.schema.json` | `GET /records/{id}` |
| `agent-list.schema.json` | `GET /agents` |
| `agent.schema.json` | `GET /agents/{id}` |
| `repository-list.schema.json` | `GET /repositories` |
| `repository.schema.json` | `GET /repositories/{id}` |
| `subgraph.schema.json` | `GET /graph` and `/records/{id}/export` |
| `error.schema.json` | Any error response |
| `validation-report.schema.json` | `POST /validate` |

**Added post-v0.1.0 (pending v0.2.0 freeze):**

| Schema | Validates |
|---|---|
| `autocomplete.schema.json` | `GET /autocomplete` |
| `relations-for.schema.json` | `GET /relations-for/{id}` |
| `relation-list.schema.json` | `GET /relations` |
| `hierarchy.schema.json` | `GET /hierarchy/{id}` |
| `entity-info.schema.json` | `GET /entities/{id}/info` |
| `entity-write.schema.json` | Request body for `POST /{type}` and `PATCH /{type}/{id}`; also `POST /relations`, `PATCH /relations/{id}` |
| `write-response.schema.json` | Any `201 Created` or `200 OK` write response (both shapes via `oneOf`) |

### 3.3 Fixture pack — `fixtures/`

The fixture pack is a directory of ~20 cases. Each case is a folder containing:

```
fixtures/fonds-with-series/
├── input.json           # AtoM-shape input description
├── expected.jsonld      # Canonical RiC-O JSON-LD output
├── expected-graph.json  # Canonical Subgraph for /graph endpoint
└── notes.md             # Explanation of what this case exercises
```

Initial fixture set covers:

1. `fonds-minimal` — fonds with title and creator only
2. `fonds-with-series` — fonds + series + item hierarchy
3. `fonds-multilingual` — fonds with en + fr + af titles
4. `agent-person-simple` — single person with dates
5. `agent-corporate-body` — corporate body with mandates and places
6. `agent-family` — family with member relationships
7. `agent-with-relations` — successor-of, predecessor-of chains
8. `repository-with-holdings` — ISDIAH repo + 3 fonds
9. `function-with-activities` — ISDF function with 2 activities
10. `event-production` — record with creation event → Production
11. `event-accumulation` — record with accumulation event
12. `record-with-digital-object` — record + instantiation + mime-type
13. `record-in-container` — record held in `rico:Thing` (box)
14. `record-security-classified` — record with classification level
15. `record-personal-data` — record flagged `containsPersonalData=true`
16. `record-with-access-restriction` — record with restriction scope
17. `subgraph-depth-1` — graph endpoint, root + direct neighbours
18. `subgraph-depth-2` — graph endpoint, two-hop BFS
19. `subgraph-filtered-by-type` — graph endpoint with `types=rico:Person`
20. `validation-failure` — deliberately broken input, expected SHACL failures

**Added post-v0.1.0 (pending v0.2.0 freeze):**

21. `autocomplete-egypt` — cross-entity search result shape
22. `relations-for-place` — outgoing + incoming split on a Place
23. `hierarchy-with-children` — parent + children + siblings on a hierarchical Place
24. `entity-info-place` — minimal info card shape
25. `relation-list` — paginated global relation browse
26. `entity-write-place` — request + response for `POST /places`
27. `write-response-create` — canonical 201-Created shape across every POST endpoint

## 4. Graph equality

Two RiC-O graphs are equal (for L1 conformance) iff they are **isomorphic under blank-node bijection**. The validator uses SPARQL's `sh:equal` semantics for concrete nodes and standard graph isomorphism for blank nodes.

JSON-LD framing order, property order within a node, and prefix choice are NOT significant. Only the resulting RDF graph matters.

## 5. The `openric-validate` CLI

A reference validator is published at `https://github.com/openric/validator` (pending).

### 5.1 Usage

```bash
openric-validate <server-base-url> [--level=L1|L2|L3|L4] [--fixtures=<dir>]
                                    [--output=<json|junit|human>]
```

Examples:

```bash
# Validate a running server at L4
openric-validate https://archives.example.org/api/ric/v1 --level=L4

# Validate a specific record by URL
openric-validate --record https://archives.example.org/api/ric/v1/records/AHG-A001

# Validate local JSON-LD file against shapes
openric-validate --file my-record.jsonld --shapes shapes/openric.shacl.ttl
```

### 5.2 Exit codes

| Code | Meaning |
|---|---|
| `0` | All checks passed at the requested level |
| `1` | One or more violations (check report) |
| `2` | Warnings only (useful in strict mode) |
| `3` | Server unreachable |
| `4` | Invalid invocation |

### 5.3 Report format

JUnit XML and JSON are supported for CI integration. Human-readable format for interactive use.

```json
{
  "openric_version": "0.1.0",
  "level_claimed": "L4",
  "level_achieved": "L3",
  "passed": 47,
  "failed": 3,
  "warnings": 12,
  "failures": [
    {
      "fixture": "agent-family",
      "endpoint": "/agents/smuts-family",
      "check": "SHACL:AgentShape",
      "severity": "Violation",
      "message": "rico:name required but missing"
    }
  ]
}
```

## 6. Self-reporting

Every conformant server SHOULD expose its achieved level in the service-description endpoint:

```
GET /api/ric/v1/
→ { "openric:conformance": ["L1", "L2", "L3"], … }
```

Additionally, a conformance badge MAY be displayed in the server's web UI or README:

```
![OpenRiC conformance L4](https://openric.org/badge/L4.svg)
```

(Badge endpoint is aspirational — not yet live.)

## 7. Certification

**There is no certification authority.** Conformance is self-asserted and independently verifiable via the CLI. This mirrors IIIF's approach and keeps the ecosystem open.

Spec editors may, at their discretion, list third-party implementations on `openric.org` alongside Heratio once they pass the CLI at the claimed level.

## 8. Testing your implementation

The minimum to claim L1 conformance:

1. Clone `https://github.com/openric/spec` (this repo).
2. For each fixture in `fixtures/`, feed `input.json` through your mapping.
3. Compare your output against `expected.jsonld` using the validator's graph-equality mode.
4. Fix discrepancies until all 20 fixtures pass.

L2 additionally requires a running HTTP endpoint. L3 additionally requires graph responses that satisfy the six invariants in [Graph Primitives](graph-primitives.html) §6. L4 additionally requires round-trip preservation.

## 9. Versioning

This conformance document and the associated shapes/schemas/fixtures are versioned together. Conformance is stated against a specific spec version:

> *Heratio 0.94.0 passes OpenRiC 0.1.0 at L3.*

Minor version bumps (0.1.x) may add fixtures or tighten shapes but never break passing implementations. Major version bumps (1.0 → 2.0) may.

## 10. Change log

| Version | Date | Notes |
|---|---|---|
| 0.1.0-draft | 2026-04-17 | Initial draft. SHACL shapes derived from Heratio's `ric_shacl_shapes.ttl`. |

---

[Back to OpenRiC](../)
