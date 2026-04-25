---
layout: default
title: "Fixture: sparql-info"
description: "Minimum-viable /sparql/info void:Dataset description for the SPARQL Access (Draft) profile."
---

# Fixture — `sparql-info`

**Profile:** `sparql-access` (Draft v0.1.0)
**Endpoint:** `GET /api/ric/v1/sparql/info`
**Shape:** `:SparqlInfoShape` in [shapes/profiles/sparql-access.shacl.ttl](../../shapes/profiles/sparql-access.shacl.ttl)
**Status:** done — gates promotion of `sparql-access` from Draft to Normative

Pins the canonical `/sparql/info` response: a `void:Dataset` describing the SPARQL endpoint, with required `void:sparqlEndpoint`, `void:triples`, `void:vocabulary` (at minimum binding `rico:`), and recommended `dcterms:license`.

Implementation hints carried as `openricx:*` on the same `void:Dataset` node:

- `openricx:accessPolicy` — one of `public-read` / `authenticated-read` / `tenant-restricted` per `sparql-access.md` §3.
- `openricx:rateLimit` — free-text rate limit declaration (e.g. `60/minute/IP`).
- `openricx:maxQueryTimeSeconds` — server-side query timeout cap.
- `openricx:exampleQueriesUrl` — optional pointer at `/sparql/examples` per §2.2.

## What this fixture pins

1. The response is a single `void:Dataset` JSON-LD root node.
2. `@context` binds `void`, `dcterms`, `rico`, `openricx`, `skos`, `owl`, `xsd`.
3. `void:sparqlEndpoint` is an IRI pointing back at the live SPARQL URL (typically the same as `@id`).
4. `void:triples` is `xsd:integer` ≥ 0 (use `0` for an empty store; do not omit).
5. `void:vocabulary` is an array of IRIs and includes at least `<https://www.ica.org/standards/RiC/ontology#>`.
6. `dcterms:license` is an IRI when present (Warning if missing).

## Validation

`expected.jsonld` MUST validate against `:SparqlInfoShape`:

```bash
pyshacl -s shapes/profiles/sparql-access.shacl.ttl \
        -d fixtures/sparql-info/expected.jsonld -f human
```

Expected result: 0 Violations, 0 Warnings.
