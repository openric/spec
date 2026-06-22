---
title: SPARQL queries
category: Using the API
order: 3
summary: Query the RiC graph with SPARQL 1.1 - the read-only endpoint, a sample query and result, and the dataset-description endpoint. With curl samples.
---

A server implementing the **SPARQL Access** profile exposes a read-only SPARQL 1.1 endpoint at `/api/ric/v1/sparql` (public, rate-limited; SPARQL Update is rejected).

## A query

```bash
curl -s "https://ric.theahg.co.za/api/ric/v1/sparql" \
  --data-urlencode 'query=SELECT * WHERE { ?s ?p ?o } LIMIT 5' \
  -H "Accept: application/sparql-results+json"
```

Both `GET` (`?query=`) and `POST` are accepted, per the SPARQL 1.1 Protocol. The response is canonical SPARQL Results JSON:

```json
{ "head": { "vars": ["s","p","o"] },
  "results": { "bindings": [ { "s": {...}, "p": {...}, "o": {...} } ] } }
```

## A more useful query

```sparql
PREFIX rico: <https://www.ica.org/standards/RiC/ontology#>
SELECT ?record ?title WHERE {
  ?record a rico:Record ; rico:title ?title .
} LIMIT 20
```

## Dataset description

```bash
curl -s "https://ric.theahg.co.za/api/ric/v1/sparql/info"
```

Returns a `void:Dataset` description - triple count, endpoint, vocabularies.

## Notes

- The endpoint is **read-only**: `INSERT`/`DELETE`/`CLEAR`/`LOAD`/`DROP` are rejected with `403 application/problem+json`.
- Rate-limited (60/min/IP on the reference server) with a backend timeout.
- For grounding LLM/RAG agents against the graph, see the draft [Graph-Grounding profile](/spec/profiles/graph-grounding.html) (`GET /ground`).

## Next

- [Export & harvesting](/help/exporting-and-harvesting/)
- [Reading data](/help/using-the-api/)
