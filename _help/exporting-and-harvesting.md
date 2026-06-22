---
title: Exporting & harvesting
category: Using the API
order: 4
summary: Get data out in bulk or per-record - OAI-PMH v2.0 harvest, content-negotiated JSON-LD/Turtle/RDF-XML dumps, and the portability guarantees. With samples.
---

OpenRiC treats getting your data out as a **guarantee**, not a feature. Two surfaces.

## Per-record export

```bash
# JSON-LD (default), Turtle, or RDF-XML
curl -s "https://ric.theahg.co.za/api/ric/v1/records/<slug>/export"
curl -s "https://ric.theahg.co.za/api/ric/v1/records/<slug>/export?format=ttl"
curl -s "https://ric.theahg.co.za/api/ric/v1/records/<slug>/export?format=rdf"
```

A record exported to JSON-LD or Turtle **re-imports to the same graph** - the round-trip guarantee of the draft [Portability profile](/spec/profiles/portability.html).

## OAI-PMH harvest

For aggregators and discovery portals, the **Export-Only** profile exposes OAI-PMH v2.0 at `/api/ric/v1/oai` (all six verbs, both GET and POST):

```bash
curl -s "https://ric.theahg.co.za/api/ric/v1/oai?verb=Identify"
curl -s "https://ric.theahg.co.za/api/ric/v1/oai?verb=ListMetadataFormats"
curl -s "https://ric.theahg.co.za/api/ric/v1/oai?verb=ListRecords&metadataPrefix=rico_ld"
```

Two metadata prefixes: **`oai_dc`** (the OAI baseline) and **`rico_ld`** (an OpenRiC extension carrying full RiC-O JSON-LD inside a CDATA block, so the wire format stays OAI-PMH-compatible while preserving RiC semantics).

## Self-describing dataset (draft)

The draft [Portability profile](/spec/profiles/portability.html) adds a **DCAT/VoID** descriptor at `/dataset` (title, licence, version, `dcterms:conformsTo` the pinned standards, and every distribution) and a `/changelog` feed - so a consumer can discover and trust the dataset without out-of-band knowledge.

## Next

- [Conformance & profiles](/help/conformance-and-profiles/) - Export-Only + Portability
- [SPARQL queries](/help/sparql/)
