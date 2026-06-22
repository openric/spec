---
layout: default
title: OpenRiC Graph Primitives
---

# OpenRiC Graph Primitives

**Version:** 0.37.0
**Status:** Active - RiC-O 1.1 namespace remediation complete
**Last updated:** 2026-04-25

---

## 1. Purpose

Defines the **abstract viewing model** - the minimum vocabulary a server emits and a viewer consumes so that visualisations of RiC data can be built interoperably.

A server-produced subgraph described in these primitives can be rendered as a 2D force-directed graph, a 3D WebGL graph, a timeline, a matrix, a Sankey, or a form of visualisation not yet invented. The spec is deliberately minimal: **it describes what data travels, not what the screen looks like.**

The reference implementation lives in Heratio's `buildGraphFromDatabase` and the 2D/3D viewer JavaScript that consumes it. The `@openric/viewer` package (pending extraction) will be the canonical viewer-side reference.

## 2. Namespace

Primitives are defined in the OpenRiC namespace:

```
@prefix openric: <https://openric.org/ns/v1#> .
```

## 3. The core five

Every conformant subgraph uses these five primitives. Nothing else is required; nothing else is forbidden.

### 3.1 `Subgraph`

The container returned by any endpoint that yields a graph-shaped response (typically `/api/ric/v1/graph`, `/records/{id}/export`).

```json
{
  "@type": "openric:Subgraph",
  "openric:root":   "<entity-uri-the-subgraph-was-built-around>",
  "openric:depth":  2,
  "openric:nodes":  [ /* Node objects */ ],
  "openric:edges":  [ /* Edge objects */ ],
  "openric:clusters": [ /* optional */ ],
  "openric:hints":    { /* optional layout hints */ }
}
```

Fields:

| Field | Required | Meaning |
|---|---|---|
| `root` | yes | The URI of the entity the subgraph was built around |
| `depth` | yes | BFS depth the server walked from root |
| `nodes` | yes | Array of `Node` objects (§3.2). Always includes the root. |
| `edges` | yes | Array of `Edge` objects (§3.3) |
| `clusters` | no | Optional `Cluster` groupings (§3.4) |
| `hints` | no | Optional `LayoutHint` map (§3.5) |

### 3.2 `Node`

A RiC entity projected for display.

```json
{
  "id":    "https://archives.example.org/actor/smuts-jc",
  "type":  "rico:Person",
  "label": "Smuts, Jan Christian",
  "attributes": {
    "dates":    "1870–1950",
    "occupation": "Statesman, philosopher"
  },
  "openric:localType": null,
  "openric:layoutHint": null
}
```

Fields:

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | The entity's canonical URI (matches `@id` in its RiC-O emission) |
| `type` | yes | RiC-O class name with `rico:` prefix (e.g. `rico:Person`, `rico:RecordSet`, `rico:CorporateBody`) |
| `label` | yes | Human-readable display string, language-negotiated to `Accept-Language` |
| `attributes` | no | Flat string→string/number map for tooltips / side panels. No structured objects. |
| `openric:localType` | no | Implementation-specific subtype (e.g. `"box"` for `rico:Thing`) |
| `openric:layoutHint` | no | See §3.5 |

Node objects are **self-describing**. A viewer that only understands the five required fields can render any subgraph correctly. Unknown fields MUST be ignored, not rejected.

### 3.3 `Edge`

A typed RiC relation between two nodes.

```json
{
  "source": "https://archives.example.org/informationobject/AHG-A001",
  "target": "https://archives.example.org/actor/smuts-jc",
  "predicate": "rico:hasCreator",
  "label": "created by",
  "directed": true
}
```

Fields:

| Field | Required | Meaning |
|---|---|---|
| `source` | yes | Node id (tail of the arrow) |
| `target` | yes | Node id (head of the arrow) |
| `predicate` | yes | Full RiC-O (or OpenRiC) predicate with prefix |
| `label` | yes | Human-readable, language-negotiated |
| `directed` | no, default `true` | Most RiC relations are directed; set `false` only for symmetric predicates |
| `attributes` | no | Optional flat map (e.g. date scoping, certainty) |

Edges MUST reference node ids that exist in the `nodes` array of the same `Subgraph`. Dangling edges are invalid.

### 3.4 `Cluster` *(optional)*

A grouping proposal the server attaches. Viewers MAY honour clusters (e.g. to render each as a visually-distinct region) or ignore them entirely.

```json
{
  "id": "by-type-Person",
  "label": "People",
  "strategy": "by-type",
  "members": [ "<node-id-1>", "<node-id-2>", … ]
}
```

Supported strategies:

| Strategy | Semantics |
|---|---|
| `by-type` | One cluster per distinct `Node.type` |
| `by-fonds` | One cluster per ancestral RecordSet |
| `by-date-range` | Buckets by date (server-defined bucket edges) |
| `by-repository` | One cluster per holding institution |
| `custom` | Server-defined; viewer can display but not interpret |

### 3.5 `LayoutHint` *(optional)*

Non-binding advice from the server about node placement. Viewers may consume or discard at will.

```json
{
  "openric:layoutHint": {
    "preferred_position": { "x": 0.3, "y": 0.7, "z": null },
    "weight": 5,
    "group": "creators"
  }
}
```

| Field | Meaning |
|---|---|
| `preferred_position` | Suggested coordinates in normalised [0,1] space. `z` may be null for 2D-intended viewers. |
| `weight` | Force-directed layout weight (higher → more central pull) |
| `group` | Free-form group identifier - viewers may use for colouring or clustering |

## 4. Operations

Operations are client → server requests that modify what the server returns. They are issued against existing endpoints - the operations themselves are not endpoints.

### 4.1 `Drill`

Expand (or contract) a subgraph at a given node.

Client sends:

```
GET /api/ric/v1/graph?uri={node-id}&depth={N}&direction=out
```

Server returns a fresh `Subgraph` rooted at that node. The viewer is responsible for merging into its current view if desired.

| Parameter | Meaning |
|---|---|
| `uri` | Node to drill from |
| `depth` | How many hops to expand |
| `direction` | `in` (predecessors), `out` (successors), `both` |

### 4.2 `Filter`

Restrict the returned subgraph by node type:

```
GET /api/ric/v1/graph?uri={root}&types=rico:Person,rico:CorporateBody
```

Edges whose endpoints fall outside the type filter are also omitted.

## 5. Canonical `Node.type` values

Servers SHOULD use the RiC-O class that most precisely describes the entity. The following are the values emitted by the reference implementation:

| Entity family | `Node.type` |
|---|---|
| Records | `rico:Record`, `rico:RecordSet`, `rico:RecordPart` |
| Agents | `rico:Person`, `rico:CorporateBody`, `rico:Family`, `rico:Agent` |
| Repositories | `rico:CorporateBody` (with `openric:role = "repository"`) |
| Activities | `rico:Activity` (kind via `rico:hasActivityType` IRI from `<https://openric.org/vocab/activity-type/>`) |
| Functions | `openricx:Function` |
| Places | `rico:Place` |
| Dates | `openricx:DateRange` (rarely as a node; usually as an edge attribute) |
| Instantiations (digital objects) | `rico:Instantiation` |
| Things (boxes, containers) | `rico:Thing` + `openric:localType` |

Viewers SHOULD style by `type`; a sensible default palette groups Records (blues), Agents (oranges/reds), Activities (greens), Places (purples), Things (greys).

## 6. Invariants

A conformant `Subgraph` MUST satisfy:

1. **Root presence.** The `root` URI appears as a node in `nodes`.
2. **No dangling edges.** Every `edge.source` and `edge.target` refers to a node `id` present in `nodes`.
3. **Unique node ids.** Each `Node.id` appears exactly once in `nodes`.
4. **Stable identifiers.** Re-requesting the same subgraph on a quiescent server yields the same node ids (labels and attributes may vary with `Accept-Language`).
5. **Type vocabulary.** Every `Node.type` is either a RiC-O class or an OpenRiC extension class.
6. **Edge predicates.** Every `Edge.predicate` resolves to a predicate defined in RiC-O, OpenRiC, or a namespace the server advertises via `/vocabulary`.

Conformance test fixtures (see [Conformance](conformance.html)) assert all six invariants.

## 7. Non-goals

- **Layout algorithms.** Not specified. Viewers choose.
- **Styling.** Not specified. Viewers choose.
- **Interactivity.** Hover, click, keyboard navigation - entirely viewer concerns.
- **Mutation.** This spec is read-only. Editing RiC data belongs to a separate (future) Editing API, not here.

## 8. Rationale

Why so minimal? Because IIIF's biggest win was deciding what *not* to specify. Anything baked into the primitives becomes a constraint on future viewers. By keeping the core to five primitives and six invariants, OpenRiC leaves room for future viewers that don't exist yet - timeline-only viewers, matrix-only viewers, VR viewers - to consume the same server output.

## 9. Change log

| Version | Date | Notes |
|---|---|---|
| 0.1.0-draft | 2026-04-17 | Initial draft extracted from Heratio `buildGraphFromDatabase` and the 2D/3D viewer. |

---

[Back to OpenRiC](../)
