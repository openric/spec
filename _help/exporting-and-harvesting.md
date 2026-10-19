---
title: Exporting & harvesting
category: Using the API
order: 4
summary: Get data out in bulk or per-record - OAI-PMH v2.0 harvest, content-negotiated JSON-LD/Turtle/RDF-XML dumps, and what the draft Portability profile would add. With samples.
---

OpenRiC treats getting your data out as **part of the contract**, not an optional feature: the normative Export-Only profile defines it, and the probe tests it. Two surfaces.

## Per-record export

```bash
# JSON-LD (default), Turtle, or RDF-XML
curl -s "https://ric.theahg.co.za/api/ric/v1/records/<slug>/export"
curl -s "https://ric.theahg.co.za/api/ric/v1/records/<slug>/export?format=ttl"
curl -s "https://ric.theahg.co.za/api/ric/v1/records/<slug>/export?format=rdf"
```

The draft [Portability profile](/spec/profiles/portability.html) requires that a record exported to JSON-LD or Turtle **re-imports to the same graph**. The reference service does not yet declare that profile, so on this server it is a stated requirement, not a tested result.

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
