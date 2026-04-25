---
layout: default
title: "Fixture: sparql-construct"
description: "JSON-LD response shape for a CONSTRUCT/DESCRIBE result from the SPARQL Access (Draft) profile."
---

# Fixture — `sparql-construct`

**Profile:** `sparql-access` (Draft v0.1.0)
**Endpoint:** `GET/POST /api/ric/v1/sparql` with `Accept: application/ld+json` and a `CONSTRUCT` or `DESCRIBE` query
**Shape:** `:SparqlConstructShape` in [shapes/profiles/sparql-access.shacl.ttl](../../shapes/profiles/sparql-access.shacl.ttl)
**Status:** done — gates promotion of `sparql-access` from Draft to Normative

Pins the canonical JSON-LD shape returned when a SPARQL CONSTRUCT or DESCRIBE query asks for `application/ld+json`.

## What this fixture pins

1. **`@context` binds the OpenRiC namespaces.** At minimum `rico` and `openricx`; the canonical recommended set is `rico`, `openricx`, `skos`, `dcterms`, `owl`, `xsd`. Without these bindings, any `rico:*` / `openricx:*` CURIE in the result body fails JSON-LD expansion in standard processors.
2. **`@graph` carries the constructed triples** as a JSON-LD-framed array of subject objects. The example shows two subjects (a Person and a RecordSet) with cross-links.
3. **Cross-entity references** use `{ "@id": "..." }` for stub references; full embedded objects (with `@type`, `rico:name`, etc.) are permitted when the source query DESCRIBES them.
4. **All emitted property names are canonical RiC-O 1.1 or openricx — no legacy terms.** Specifically: `rico:hasBeginningDate` (not `rico:startDate`), `rico:hasEndDate`, `rico:hasOrHadHolder` (not `rico:heldBy`), `rico:isOrWasHolderOf` (not `rico:hasHolding`), `openricx:description` (not `rico:description`), `openricx:hasDateRangeSet` (not `rico:hasDateRangeSet`), `openricx:DateRange` (not `rico:DateRange`).

## Example query that would produce this shape

```sparql
PREFIX rico:     <https://www.ica.org/standards/RiC/ontology#>
PREFIX openricx: <https://openric.org/ns/ext/v1#>

CONSTRUCT {
  ?person a rico:Person ;
          rico:name             ?personName ;
          rico:hasBeginningDate ?birth ;
          rico:hasEndDate       ?death ;
          rico:isOrWasHolderOf  ?fonds ;
          owl:sameAs            ?wikidata .
  ?fonds  a rico:RecordSet ;
          rico:title         ?fondsTitle ;
          rico:identifier    ?fondsId ;
          openricx:description ?desc ;
          rico:hasOrHadHolder ?holder .
  ?holder a rico:CorporateBody ;
          rico:name ?holderName .
}
WHERE {
  VALUES ?person { <https://archives.example.org/agent/smuts-jc> }
  ?person a rico:Person ;
          rico:name             ?personName ;
          rico:hasBeginningDate ?birth ;
          rico:hasEndDate       ?death ;
          rico:isOrWasHolderOf  ?fonds .
  OPTIONAL { ?person owl:sameAs ?wikidata }
  ?fonds  a rico:RecordSet ;
          rico:title         ?fondsTitle ;
          rico:identifier    ?fondsId ;
          openricx:description ?desc ;
          rico:hasOrHadHolder ?holder .
  ?holder rico:name ?holderName .
}
```

## Validation

The SHACL `:SparqlConstructShape` documents the @context-binding contract. The contract is mechanically verified by JSON Schema (`schemas/sparql-construct.schema.json`, planned v0.7+) at the JSON-LD-document layer, since SHACL targeting works on RDF (post-expansion) and the `@context` itself disappears by then.

Triple-set parity for the same `CONSTRUCT` query across `application/ld+json`, `text/turtle`, and `application/rdf+xml` MUST hold per the Export-Only profile's lossless-parity requirement.
