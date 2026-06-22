---
layout: default
title: OpenRiC - Graph-Grounding Profile
description: A read-only grounding endpoint so any agent or RAG can disambiguate against a RiC graph - vectors retrieve, the ontology graph disambiguates. GET /ground returns prompt-ready authoritative facts keyed to the canonical entity IRI.
---

# Graph-Grounding Profile

**Profile id:** `graph-grounding`
**Profile version:** 0.43.0
**Spec version:** 0.43.0
**Status:** Draft - open for comment
**Dependencies:** [Core Discovery](core-discovery.html) (the entities `/ground` resolves to) and, in practice, a SPARQL surface ([sparql-access](sparql-access.html)) to read the graph. [Inferred-Provenance](inferred-provenance.html) is recommended so grounding packs can carry the asserted-vs-inferred signal.
**Last updated:** 2026-06-19
**Reference implementation:** Heratio ([ArchiveHeritageGroup/heratio#1320](https://github.com/ArchiveHeritageGroup/heratio)) - `GraphGroundingService`, `GET /api/ric/ground`, `docs/reference/graphrag-grounding-km.md`.

---

## 1. Purpose

LLM and RAG systems hallucinate entities and conflate similar names. A RiC graph is exactly the authority that can fix this - **"vectors retrieve, the ontology graph disambiguates."** The Graph-Grounding Profile defines a read-only, server-to-server endpoint any agent can call to resolve a query to **authoritative graph facts** and get a compact, prompt-ready block to prepend to its LLM context.

## 2. The endpoint - `GET /api/ric/v1/ground`

| Param | Meaning |
|---|---|
| `q` | the free-text query / entity mention to disambiguate (required) |
| `max` | maximum entities to return (optional, default 5) |

Public, throttled, no CSRF (server-to-server). Returns:

```json
{
  "query": "Egypt",
  "entities": [
    {
      "iri": "https://host/ric/place/912150",
      "types": ["Place"],
      "label": "Egypt",
      "dates": [],
      "properties": { "...": "..." },
      "relations": ["is location of -> ..."],
      "provenance": "asserted"
    }
  ],
  "grounding_text": "Authoritative facts from the archive's knowledge graph:\n- Egypt (Place) [https://host/ric/place/912150]; ..."
}
```

- Each **entity** is a *disambiguation pack*: canonical IRI, types, label, dates, key properties, relations, and a provenance signal (`asserted` / `inferred`, per [Inferred-Provenance](inferred-provenance.html)).
- **`grounding_text`** is a compact, prompt-ready block assembled from the packs - the artifact a consumer actually injects.

## 3. The join-key rule

The **canonical join between the vector layer and the graph is the public entity IRI** (the export IRI of the [Governance](governance.html) two-layer policy, alongside the internal `object_id → urn:ahg:ric:<type>:<id>`). A retriever's vector hits MUST resolve to graph entities by that IRI, so retrieval surfaces *candidates* and the graph supplies the *authoritative facts* for the same identity. Grounding packs MAY carry the internal IRI for operators, but the IRI a consumer keys on is the public one.

## 4. Consumer integration (informative)

1. Before building the LLM prompt, `GET /api/ric/v1/ground?q=<question>` (server-to-server).
2. If `grounding_text` is non-empty, **prepend it to the context** (above the vector-retrieved chunks), unchanged.
3. Build and send the prompt as normal.

Two operational rules borne out by the reference pilot:

- **Flag-guarded** - grounding is opt-in per request (or per deployment), so it can be A/B-measured and rolled out gradually.
- **Fail-open** - any error fetching grounding yields an empty block and the answer proceeds; grounding sharpens answers, it never blocks them. (The reference pilot measured grounded answers 15–35% shorter and anchored on canonical ids, with no fabricated entities.)

## 5. SHACL

Graph-Grounding emits a response envelope, not graph triples, so it has no SHACL shape. The response is shape-checked against [`schemas/ground.schema.json`](https://github.com/openric/spec/blob/main/schemas/ground.schema.json).

## 6. Conformance

A server claims Graph-Grounding when:

- `GET /ground?q=&max=` returns `{ query, entities[], grounding_text }` with each entity a disambiguation pack keyed to the public IRI.
- Vector↔graph resolution is on the public entity IRI.
- The endpoint is read-only, throttled, and safe to call server-to-server.

Declared as `{ "id": "graph-grounding", "version": "0.43.0", "conformance": "full" }`.
