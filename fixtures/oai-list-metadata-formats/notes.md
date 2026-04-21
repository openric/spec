# Fixture — oai-list-metadata-formats

**Profile:** `export-only`
**Endpoint:** `GET /api/ric/v1/oai?verb=ListMetadataFormats`
**Protocol:** [OAI-PMH v2.0](https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats)
**Content-Type:** `text/xml; charset=utf-8`

OpenRiC conformant servers MUST advertise **at least these two** metadata formats:

| Prefix | Shape | Status |
|---|---|---|
| `oai_dc` | Standard Dublin Core XML (OAI-PMH baseline requirement) | REQUIRED |
| `rico_ld` | RiC-O JSON-LD wrapped in CDATA inside the `<metadata>` element | REQUIRED |

The `oai_dc` prefix is mandatory per OAI-PMH §3.4 — every harvester assumes it. The `rico_ld` prefix is an OpenRiC extension that lets harvesters round-trip the full RiC-O semantics through OAI-PMH without flattening to Dublin Core; the wrapping-in-CDATA pattern mirrors IIIF Presentation API's embed-a-JSON-blob-in-XML technique.

Servers MAY advertise additional prefixes (`mods`, `marcxml`, `ead`, `rico_xml` once that's defined) but MUST keep `oai_dc` and `rico_ld` in the list.
