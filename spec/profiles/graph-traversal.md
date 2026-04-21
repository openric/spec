---
layout: default
title: OpenRiC — Graph Traversal Profile
description: The /graph endpoint and its relation + hierarchy companions. Where Core Discovery answers "what is this record", Graph Traversal answers "what is this record connected to".
---

# Graph Traversal Profile

**Profile id:** `graph-traversal`
**Profile version:** 0.4.0
**Spec version:** 0.4.0
**Status:** Normative
**Dependencies:** None at the endpoint level; SHACL shapes assume a full-graph data source. See §5.
**Last updated:** 2026-04-21

---

## 1. Purpose

Graph Traversal is the profile for **moving across the graph of RiC entities**, not just fetching individual nodes. Core Discovery lets a client dereference a single record; Authority & Context lets it dereference the record's places, rules, and creation events. Graph Traversal is what binds those islands together: a rooted subgraph walk, a typed relation list, a hierarchy block for fonds-series-file walks.

A server implementing this profile commits to three things:

1. **Expose `/graph?uri=…&depth=N`** returning an `openric:Subgraph` per [Graph Primitives](../graph-primitives.html) — a nodes + edges envelope that any conformant viewer can render.
2. **Expose `/relations`** — a paginated index of typed edges between entities, with subject/object IDs, RiC-O predicate, optional date range, certainty, and supporting evidence.
3. **Expose `/hierarchy/{id}`** — a cheap parent/children/siblings block for clients that need to walk a RecordSet tree (fonds → series → file) without issuing one request per level.

The profile also publishes a set of **full-graph SHACL shapes** (§5) that detect cross-entity invariants — orphaned records, unlinked agents, duplicate identifiers, typed-link mismatches. These are expensive and run against a full triple-store dump, not against a single API response.

Graph Traversal is **orthogonal to Core Discovery and Authority & Context**: a server MAY claim Graph Traversal without the others (a pure graph index for a warehouse), or claim all three (the common case for a working catalogue).

## 2. Scope

### 2.1 Required endpoints

A conformant server MUST expose:

| Verb | Path | Returns |
|---|---|---|
| GET | `/api/ric/v1/graph?uri=…&depth=N` | `openric:Subgraph` (nodes + edges) |
| GET | `/api/ric/v1/relations` | Relation list, paginated |
| GET | `/api/ric/v1/relations-for/{id}` | Incoming + outgoing relations for one entity |
| GET | `/api/ric/v1/hierarchy/{id}` | Parent / children / siblings for a RecordSet or Place |

### 2.2 `/graph` query parameters

| Parameter | Type | Rules |
|---|---|---|
| `uri` | string | **Required.** The @id of the root entity. Shape: `<base>/<type>/<id-or-slug>`. Known types: `informationobject`, `record`, `recordset`, `actor`, `person`, `corporatebody`, `family`, `place`, `rule`, `activity`, `instantiation`. Unknown types → HTTP 400. |
| `depth` | integer | Optional. Default `1`, maximum `3`. Depth `N` means: breadth-first walk out from root, following `rico:*` predicates up to `N` hops. |

### 2.3 Forbidden without additional profile claims

- **Write verbs** on `/relations` — relation write surface is Round-Trip Editing.
- **Arbitrary SPARQL** against the backing store — if a server exposes `/sparql`, it is governed by the (experimental) §4.8 of `spec/viewing-api.md`, not by this profile.
- **Uncapped depth** — `depth > 3` MUST be rejected with HTTP 400 to prevent runaway server load.

### 2.4 Content types

- `/graph` → `application/ld+json` (it is a JSON-LD Subgraph per Graph Primitives)
- `/relations`, `/relations-for/{id}`, `/hierarchy/{id}` → `application/json`

The hierarchy + relations endpoints are intentionally **not** JSON-LD — they are compact convenience envelopes for clients that can't efficiently parse JSON-LD trees, modelled after IIIF's split between Presentation API (LD-native) and Image API (REST-style). A server MAY additionally expose these endpoints in JSON-LD under a separate content-type-negotiated path; that is outside the normative surface.

## 3. Response shapes

### 3.1 `GET /graph?uri=…&depth=N` — Subgraph

Returns an `openric:Subgraph` per [Graph Primitives §3.1](../graph-primitives.html#31-subgraph). The five required top-level keys are `@context`, `@type`, `openric:root`, `openric:depth`, `openric:nodes`, `openric:edges`.

```json
{
  "@context": { "rico":    "https://www.ica.org/standards/RiC/ontology#",
                "openric": "https://openric.org/ns/v1#" },
  "@type":          "openric:Subgraph",
  "openric:root":   "https://example.org/recordset/905228",
  "openric:depth":  1,
  "openric:nodes": [
    { "id":    "https://example.org/recordset/905228",
      "label": "Egyptian Boat",
      "type":  "RecordSet" },
    { "id":    "https://example.org/place/912150",
      "label": "Egypt",
      "type":  "Place" }
  ],
  "openric:edges": [
    { "source":    "https://example.org/recordset/905228",
      "target":    "https://example.org/place/912150",
      "predicate": "rico:hasOrHadSubject",
      "label":     "about" }
  ]
}
```

**Node shape:** `{ id, label, type }` required. Additional fields (e.g., `atomId`, `atomUrl`, `thumbnail_url`) MAY be emitted — clients MUST tolerate unknown keys. The `type` field is the short RiC-O local name (`RecordSet`, `Record`, `Person`, `CorporateBody`, `Family`, `Place`, `Rule`, `Activity`, `Instantiation`, `Thing`); servers MAY also use `Production` and `Accumulation` for the Activity subclasses.

**Edge shape:** `{ source, target, predicate, label }` required. `predicate` is the canonical RiC-O CURIE (e.g. `rico:hasOrHadSubject`, `rico:hasCreator`, `rico:isOrWasPartOf`). `label` is a short human-readable form ("about", "created by", "part of"); clients SHOULD NOT dispatch on `label` — it is free text for viewer rendering.

### 3.2 `GET /relations` — relation list

A paginated index of every edge in the store (or a subset via future query params). Envelope:

```json
{
  "data": [
    {
      "id":                960042,
      "subject_id":        905261,
      "object_id":         912150,
      "subject_class":     "RicActivity",
      "object_class":      "RicPlace",
      "rico_predicate":    "rico:tookPlaceAt",
      "inverse_predicate": "rico:isLocationOf",
      "dropdown_code":     "took_place_at",
      "domain_class":      "Activity",
      "range_class":       "Place",
      "start_date":        "1902-11-15",
      "end_date":          "1903-06-02",
      "certainty":         "probable",
      "evidence":          "Field season report, Abu Sir 1902–1903, p.14."
    }
  ],
  "pagination": { "page": 1, "per_page": 2, "total": 681, "last_page": 341 }
}
```

**Required per row:** `id`, `subject_id`, `object_id`, `subject_class`, `object_class`, `rico_predicate`. All other fields MAY be null when the backing row doesn't carry them. Pagination envelope is mandatory.

`subject_class` / `object_class` are the backing-system names (e.g. Heratio's `RicActivity`, `QubitInformationObject`); `domain_class` / `range_class` are the RiC-O local names (`Activity`, `Place`). Both pairs SHOULD be emitted when the server knows them — `rico_predicate` is the load-bearing field.

### 3.3 `GET /relations-for/{id}` — per-entity relation view

Groups all edges touching one entity into `outgoing` + `incoming` lists:

```json
{
  "entity_id": 912150,
  "total": 3,
  "outgoing": [
    {
      "id":                960001,
      "direction":         "outgoing",
      "target_id":         912328,
      "target_name":       "Egypt (archaeological region)",
      "target_type":       "Place",
      "rico_predicate":    "rico:hasBroaderGeographicalContext",
      "inverse_predicate": "rico:hasNarrowerGeographicalContext",
      "relation_label":    "broader place",
      "certainty":         "certain"
    }
  ],
  "incoming": [ /* … */ ]
}
```

**Required per row:** `id`, `direction` (`outgoing` or `incoming`), `target_id`, `target_type`, `rico_predicate`. The `target_name` and `relation_label` are optional display-side hints — servers SHOULD emit them when they have them.

### 3.4 `GET /hierarchy/{id}` — parent / children / siblings

A cheap three-axis walk for fonds-series-file traversal (applies equally to `rico:Place` trees):

```json
{
  "entity_id": 912150,
  "class":     "RicPlace",
  "parent": {
    "id": 912148, "name": "Africa", "slug": "africa", "type_id": "continent"
  },
  "children": [
    { "id": 912210, "name": "Cairo",      "slug": "cairo",      "type_id": "city" },
    { "id": 912215, "name": "Alexandria", "slug": "alexandria", "type_id": "city" }
  ],
  "siblings": [
    { "id": 912151, "name": "Libya", "slug": "libya", "type_id": "country" }
  ]
}
```

**Required:** `entity_id`, `class`, `parent` (MAY be `null` for roots), `children` (array, MAY be empty), `siblings` (array, MAY be empty).

Each stub row requires `id` and `name`; `slug` and `type_id` are optional display-side hints.

## 4. Error handling

Error responses follow Core Discovery §4 / §4.1 verbatim — `application/problem+json` with the nine registered error-type URIs. Endpoints in this profile commonly return:

- `400 bad-request` — `uri` missing or malformed, `depth > 3`, unknown entity-type segment.
- `404 not-found` — `uri` references an entity that doesn't exist.

No Graph Traversal-specific error types are defined.

## 5. SHACL shapes

Graph Traversal ships two classes of SHACL shapes, both in `shapes/profiles/graph-traversal.shacl.ttl`. **These shapes assume the entire RiC-O graph is loaded into the data graph before validation** — they will produce false positives on single-document API responses.

**Run them against a full triple-store dump, not against `GET /records/{id}` output.**

### 5.1 Type-check shapes (property-shape style, cheap)

| Shape | Check |
|---|---|
| `:RelationConsistencyShape` | Parent of `rico:isOrWasPartOf` is a `rico:RecordSet` (`sh:Warning`) |
| `:CreatorLinkShape` | `rico:hasCreator` target is a `rico:Person`, `rico:CorporateBody`, or `rico:Family` (`sh:Violation`) |

### 5.2 Full-graph SPARQL shapes (expensive)

| Shape | Check |
|---|---|
| `:InstantiationLinkedFromRecordShape` | Every `rico:Instantiation` is referenced by at least one `rico:Record` via `rico:hasInstantiation` (`sh:Warning`) |
| `:OrphanedRecordShape` | Every `rico:Record` has a `rico:isOrWasPartOf` parent, unless it is a top-level fonds (`sh:Warning`) |
| `:UnlinkedAgentShape` | Every Person/CorporateBody/Family is linked via `hasCreator`, `hasAccumulator`, or `hasOrHadParticipant` (`sh:Info`) |
| `:DuplicateIdentifierShape` | No two records share a `rico:identifier` value (`sh:Warning`) |

Severity of each shape is calibrated for a working archive, not a polished demo: an archive with some orphan Instantiations or unlinked Agents is normal and the shapes reflect that — hence `sh:Warning` / `sh:Info` rather than `sh:Violation` for the SPARQL checks. Implementations MAY raise severity locally by re-declaring the shapes.

## 6. Conformance testing

A server claims `graph-traversal` when, against its live endpoints:

1. `GET /graph?uri={valid}&depth=1` returns a valid `openric:Subgraph` per Graph Primitives §3.1.
2. `GET /graph?uri={valid}&depth=2` and `depth=3` return progressively larger subgraphs with the same shape — no new required keys appear at higher depths.
3. `GET /graph?uri={valid}&depth=4` returns HTTP 400.
4. `GET /graph` (missing `uri`) returns HTTP 400 with `type: https://openric.org/errors/bad-request`.
5. `GET /graph?uri={nonexistent}` returns HTTP 404 with `type: https://openric.org/errors/not-found`.
6. `GET /relations` returns the paginated envelope from §3.2.
7. `GET /relations-for/{id}` returns the outgoing/incoming split from §3.3.
8. `GET /hierarchy/{id}` returns the parent/children/siblings block from §3.4.
9. When an implementation has a full triple-store dump available, the 6 SHACL shapes from §5 produce no `sh:Violation`-severity failures (Warnings and Infos are acceptable).

Run the conformance probe with `--profile=graph-traversal` to exercise only this profile's checks against a live server.

## 7. Fixture pack

The manifest declares these seven fixtures as normative for `graph-traversal`:

| Fixture | What it pins |
|---|---|
| `subgraph-depth-1` | Rooted subgraph, 12 nodes + 20 edges — exercises every node type and the six graph invariants |
| `subgraph-depth-2` | 2-hop BFS from same root — verifies depth parameter honours breadth-first order and dedupes nodes |
| `hierarchy-with-children` | 3-axis (parent + children + siblings) block for a nested Place |
| `relation-list` | Paginated list envelope with two rows (one richly-annotated, one minimal) — pins null-tolerance |
| `relations-for-place` | Per-entity outgoing/incoming split with total count |
| `agent-with-relations` | *(planned)* Successor / predecessor chains between agents (`rico:hasSuccessor`) |
| `subgraph-filtered-by-type` | *(planned)* Graph walk with a node-type filter — exercises future `?types=` query param |

Fixtures outside this list are NOT required for profile conformance.

## 8. Implementation checklist

- [ ] Implement `/graph?uri=…&depth=N` returning `openric:Subgraph` per Graph Primitives §3.1
- [ ] Emit `@context` with both `rico` and `openric` prefix bindings
- [ ] Emit `openric:root`, `openric:depth`, `openric:nodes`, `openric:edges` — all required
- [ ] Per-node: `id`, `label`, `type` (short RiC-O class name)
- [ ] Per-edge: `source`, `target`, `predicate` (canonical RiC-O CURIE), `label` (free text)
- [ ] Enforce `depth ∈ [1, 3]` with HTTP 400 outside that range
- [ ] Implement `/relations` with `data` + `pagination` envelope
- [ ] Implement `/relations-for/{id}` with `outgoing` + `incoming` split
- [ ] Implement `/hierarchy/{id}` with `parent` + `children` + `siblings`
- [ ] Add `graph-traversal` to `openric_conformance.profiles` in `GET /`
- [ ] Validate a full triple-store dump against `shapes/profiles/graph-traversal.shacl.ttl` — no Violation failures
- [ ] All 5 shipped fixtures pass the conformance probe at `--profile=graph-traversal`
- [ ] `/conformance/badge?profile=graph-traversal` returns shields.io JSON

## 9. Design decisions

Five questions were flagged during drafting; all five carry resolutions.

### Q1 — Max depth = 3 or unlimited?

**Resolution**: **3, hard cap.**

**Rationale**: Beyond depth 3, a "rooted subgraph" becomes "half the catalogue." Memory and rendering costs grow exponentially with depth on a dense graph, and viewers can't meaningfully lay out more than a few hundred nodes on screen regardless. A client that needs more should issue multiple calls and stitch, or use the (expensive) full-graph SHACL shapes against a triple-store dump. 3 is conservative enough to keep even pathological graphs under a few seconds of response time on the reference implementation.

### Q2 — Edge predicate: CURIE or full URI?

**Resolution**: **CURIE (`rico:hasCreator`).**

**Rationale**: CURIEs are readable, match the `@context` aliases every OpenRiC response already declares, and halve the wire size on relation-heavy responses. Full URIs would be pedantically correct per JSON-LD but offer no practical benefit to clients — expanding `rico:` to `https://www.ica.org/standards/RiC/ontology#` is a one-line dictionary lookup. Clients that need expanded URIs can run the response through a JSON-LD processor.

### Q3 — Hierarchy endpoint as JSON-LD or plain JSON?

**Resolution**: **Plain JSON with the §3.4 compact shape.**

**Rationale**: The hierarchy endpoint is a convenience for UI code that needs to render a fonds-series-file sidebar with one network round-trip. Wrapping it in JSON-LD adds `@context` and `@type` clutter without giving consumers anything they can't compute from the RiC-O predicate `rico:isOrWasPartOf`. IIIF made the same call for Image API: LD-native where the semantics are load-bearing (`/graph`), REST-style where the shape is fixed and the client is a dumb viewer. A server that wants LD-native hierarchy MAY expose it on a separate path.

### Q4 — Relation list: Heratio backing-class names (`RicActivity`) or pure RiC-O (`Activity`)?

**Resolution**: **Both, in separate fields.**

**Rationale**: `subject_class`/`object_class` carry the implementation's row-class (useful for implementations that need to dispatch back into their own ORM); `domain_class`/`range_class` carry the RiC-O local name (useful for clients that want to reason generically). An implementation without the distinction emits the RiC-O names in both pairs. This costs two extra string columns per row and avoids forcing a contract that doesn't match the reference implementation's data model.

### Q5 — Should the full-graph SHACL shapes be required at every profile claim?

**Resolution**: **No — endpoint conformance is required; full-graph shape conformance is a separate gate.**

**Rationale**: A server exposing the four endpoints correctly is useful even if its backing store has orphan records or unlinked agents — those are data-hygiene issues, not API-contract issues. Gating endpoint conformance on full-store validation would prevent incomplete archives from ever claiming the profile, which hurts ecosystem adoption. The SHACL shapes are published so that implementers can run them against their own dumps as a hygiene check, not as a profile-claim prerequisite. A future "graph-hygiene-certified" badge may layer on top, but is out of scope for v0.4.0.
