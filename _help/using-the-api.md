---
title: Reading data from the API
category: Using the API
order: 1
summary: How to read RiC data over HTTP - list and fetch entities, the JSON-LD shape, pagination, autocomplete, the graph and hierarchy endpoints, and RFC 7807 errors. With curl samples.
---

The OpenRiC reference API is at **`https://ric.theahg.co.za/api/ric/v1`**. Reads are public; every response is `application/ld+json`.

## List and fetch

```bash
# List records (paginated)
curl -s "https://ric.theahg.co.za/api/ric/v1/records?limit=20"

# One record by slug
curl -s "https://ric.theahg.co.za/api/ric/v1/records/kc4x-45tz-em84"

# The same shape for agents, places, activities, instantiations, rules, functions, repositories
curl -s "https://ric.theahg.co.za/api/ric/v1/agents"
```

A single entity comes back as RiC-O JSON-LD:

```json
{
  "@context": "https://openric.org/ns/ext/v1#",
  "@id": "https://ric.theahg.co.za/ric/record/kc4x-45tz-em84",
  "@type": "rico:Record",
  "rico:title": "Field recording - Reel 12",
  "rico:hasOrHadHolder": { "@id": "...", "@type": "rico:CorporateBody" }
}
```

The `@type` reflects the level - `rico:Record`, `rico:RecordSet`, or `rico:RecordPart`.

## Search & autocomplete

```bash
curl -s "https://ric.theahg.co.za/api/ric/v1/autocomplete?q=egypt&limit=5"
```

Returns a flat list of `{id, label, type}` across all entity types.

## Walk the graph

```bash
# Neighbourhood of an entity, to a depth
curl -s "https://ric.theahg.co.za/api/ric/v1/graph?uri=<entity-iri>&depth=1"
# Relations of one entity
curl -s "https://ric.theahg.co.za/api/ric/v1/relations-for/912150"
# Hierarchy (parent/children/siblings)
curl -s "https://ric.theahg.co.za/api/ric/v1/hierarchy/912150"
```

## OpenRiC or plain RiC-O

Every answer is in the OpenRiC profile unless you ask for another: RiC-O 1.1 with the [`openricx:`](/help/vocabularies-and-namespaces/) terms beside it. A client that wants RiC-O 1.1 alone asks for the `rico` profile, and the JSON-LD comes without any `openricx:` term:

```bash
# By the query parameter (a token or the profile's URI)
curl -s "https://ric.theahg.co.za/api/ric/v1/records?limit=1&_profile=rico"
# Or by the header, with q-values if you accept more than one
curl -s -H "Accept-Profile: <https://www.ica.org/standards/RiC/ontology>" "https://ric.theahg.co.za/api/ric/v1/records?limit=1"
# The profiles on offer, each with its ontology, SHACL shapes and guidance
curl -s "https://ric.theahg.co.za/api/ric/v1/records?_profile=alt"
```

The answer names the profile it gave in `Content-Profile`, and lists the other one in a `Link` header (`rel="alternate"`). Turtle and RDF/XML are given in the OpenRiC profile only, and say so.

## Pagination

List endpoints accept `?page=` and `?limit=` (max 200). The response carries `ric:total` / `ric:page` / `ric:limit`.

## Errors

Errors use **RFC 7807** problem+json:

```json
{ "type": "https://openric.org/errors/not-found", "title": "Not Found", "status": 404, "detail": "..." }
```

## The whole surface

`GET /api/ric/v1/` returns the service description (name, version, declared profiles); `GET /api/ric/v1/openapi.json` is the service's own OpenAPI 3.1 document (the specification's [contract](/contract/openapi.json) is the normative one); `GET /api/ric/v1/docs` is a live Swagger UI you can "try it out" in.

## Next

- [Creating data](/help/creating-data/) - write entities
- [SPARQL queries](/help/sparql/) · [Export & harvesting](/help/exporting-and-harvesting/)
