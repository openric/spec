---
layout: default
title: OpenRiC — Export-Only Profile
description: OAI-PMH v2.0 harvest and one-shot JSON-LD dumps. The profile for aggregators, migration tools, and anyone who needs the data out rather than the data queried.
---

# Export-Only Profile

**Profile id:** `export-only`
**Profile version:** 0.9.0
**Spec version:** 0.36.0
**Status:** Normative
**Dependencies:** None. Export-Only is orthogonal to every other profile — a server may expose a pure harvest surface without any of the per-entity read endpoints required by Core Discovery.
**Last updated:** 2026-04-21

---

## 1. Purpose

Export-Only is the profile for **getting the data out in bulk** — without the expectation that a client will query, walk, or edit the catalogue. Two very different audiences depend on this:

1. **Aggregators and discovery portals** (Europeana, DPLA, WorldCat, national-level RiC hubs) that harvest the whole store over time and keep their own derived index. OAI-PMH v2.0 is the protocol they already speak.
2. **Migration tools, auditors, researchers** who need a single-file snapshot of one record (with its transitively-reachable authority context) in a format they can load into a triplestore or an offline RDF tool. JSON-LD / Turtle / RDF-XML are the formats they already consume.

A server implementing this profile commits to three things:

1. **Expose `/api/ric/v1/oai`** implementing all six OAI-PMH v2.0 verbs (Identify, ListMetadataFormats, ListSets, ListIdentifiers, ListRecords, GetRecord) over the archive's records.
2. **Advertise at least the `oai_dc` and `rico_ld` metadata prefixes.** `oai_dc` is OAI-PMH's baseline requirement; `rico_ld` is an OpenRiC extension that carries full RiC-O JSON-LD inside a CDATA block so the wire format stays OAI-PMH-compatible while preserving RiC semantics.
3. **Expose `/api/ric/v1/records/{slug}/export`** for per-record dumps, content-negotiated between JSON-LD (default), Turtle, and RDF-XML.

Export-Only is **orthogonal to every other profile**. A server may claim Export-Only without Core Discovery (a pure harvest-out gateway in front of an offline archive); conversely a Core-Discovery-only server MAY exist without any bulk surface at all, and neither posture breaks either profile.

## 2. Scope

### 2.1 Required endpoints

| Verb | Path | Returns |
|---|---|---|
| GET or POST | `/api/ric/v1/oai` | OAI-PMH v2.0 XML per the requested `verb` query parameter |
| GET | `/api/ric/v1/records/{slug}/export` | Single-record JSON-LD dump (default) with `@graph` envelope |

Both GET and POST MUST be accepted on `/oai` (OAI-PMH §3.1.1 mandates this — some harvesters prefer POST for long query strings).

### 2.2 OAI-PMH verbs

A conformant server MUST implement all six OAI-PMH v2.0 verbs:

| Verb | Purpose |
|---|---|
| `Identify` | Repository metadata — name, baseURL, protocolVersion, earliestDatestamp, granularity, deletedRecord policy |
| `ListMetadataFormats` | Advertises supported metadata prefixes — MUST include at least `oai_dc` and `rico_ld` |
| `ListSets` | Record-set / collection / fonds hierarchy as harvestable sets. MAY return `noSetHierarchy` if the server chooses not to expose sets |
| `ListIdentifiers` | Batch of record headers (no metadata bodies) |
| `ListRecords` | Batch of full records with headers + metadata |
| `GetRecord` | Single record by OAI identifier |

Behavioural requirements match OAI-PMH v2.0 §4 directly — this profile does not re-specify OAI-PMH semantics.

### 2.3 Required metadata prefixes

| Prefix | Shape | Why mandatory |
|---|---|---|
| `oai_dc` | Standard Dublin Core XML (`oai_dc.xsd`) | OAI-PMH baseline — every harvester assumes it |
| `rico_ld` | RiC-O JSON-LD wrapped in `<![CDATA[...]]>` inside `<metadata>` | Carries full RiC semantics through the XML wire — the whole point of Export-Only for a RiC-native aggregator |

Servers MAY advertise additional prefixes (`mods`, `marcxml`, `ead`) but MUST NOT drop the two above.

### 2.4 Content negotiation on `/export`

| `?format=` | `Accept:` | Response `Content-Type` | Encoding |
|---|---|---|---|
| `jsonld` or omitted | `application/ld+json` | `application/ld+json` | JSON-LD with `@graph` envelope |
| `ttl` or `turtle` | `text/turtle` | `text/turtle; charset=utf-8` | Turtle — lossless round-trip of the JSON-LD graph |
| `rdf` / `rdfxml` / `rdf+xml` | `application/rdf+xml` | `application/rdf+xml; charset=utf-8` | RDF/XML — same triples, different serialisation |

`?format=` query-string takes precedence over `Accept:` when both are present. The `Content-Disposition: attachment; filename="{slug}-ric.{ext}"` header MUST be emitted — the endpoint is a download, not a render target.

### 2.5 Forbidden without additional profile claims

- **SPARQL endpoint** — if exposed, that is governed by Graph Traversal / a future SPARQL profile, not by Export-Only.
- **Reverse-direction bulk import** — bulk write is out of scope here and partially covered by Round-Trip Editing's per-entity write surface.
- **Store-wide dump without a slug** — `/records/export` (no slug) is not in this profile. A full-store dump is a legitimate future extension but would need its own pagination / resumption-token protocol because RiC catalogues routinely exceed sensible JSON-LD-file sizes.

### 2.6 Content types

- OAI-PMH responses: `text/xml; charset=utf-8`
- JSON-LD dump: `application/ld+json`
- Turtle dump: `text/turtle; charset=utf-8`
- RDF-XML dump: `application/rdf+xml; charset=utf-8`
- Error responses: `application/problem+json` per Core Discovery §4 — **but only for the `/export` endpoint**. OAI-PMH errors MUST use the OAI-PMH `<error code="...">` envelope per §3.6 of the protocol (harvesters expect it).

## 3. Response shapes

### 3.1 OAI-PMH verbs — pointer to the OAI-PMH spec

Response shapes for the six verbs are normatively defined by [OAI-PMH v2.0 §4](https://www.openarchives.org/OAI/openarchivesprotocol.html#ProtocolMessages) and its XML Schema at `http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd`. This profile does NOT re-specify those shapes — any deviation would be a compliance break against the 24-year-old protocol, which is not what Export-Only is for.

OpenRiC-specific pins that apply on top:

1. **Identify** MUST declare `protocolVersion = 2.0`, `deletedRecord = no` unless the implementation tracks deletes (then `persistent` or `transient`), and `granularity = YYYY-MM-DDThh:mm:ssZ` (the finer-grain option — not the coarser `YYYY-MM-DD`).
2. **ListMetadataFormats** MUST include both `oai_dc` and `rico_ld` per §2.3 above.
3. **`rico_ld`-prefixed records** MUST carry a well-formed RiC-O JSON-LD document as the `<metadata>` contents, wrapped in CDATA. The document's shape matches §3.2 below — i.e. the `/export` endpoint's JSON-LD dump is conceptually a single-record `rico_ld` payload unwrapped.

Canonical `Identify` and `ListMetadataFormats` examples are shipped as the [`oai-identify`](../../fixtures/oai-identify/) and [`oai-list-metadata-formats`](../../fixtures/oai-list-metadata-formats/) fixtures.

### 3.2 JSON-LD dump envelope — `GET /records/{slug}/export`

```json
{
  "@context": {
    "rico":    "https://www.ica.org/standards/RiC/ontology#",
    "openric": "https://openric.org/ns/v1#",
    "xsd":     "http://www.w3.org/2001/XMLSchema#"
  },
  "@graph": [
    {
      "@id":   "https://example.org/informationobject/mobrey-family-archive",
      "@type": "rico:RecordSet",
      "rico:title": "Mobrey Family Archive",
      "rico:hasCreator": { "@id": "https://example.org/actor/715", "@type": "rico:Family", "rico:name": "Mobrey family" }
    },
    {
      "@id":   "https://example.org/actor/715",
      "@type": "rico:Family",
      "rico:name": "Mobrey family",
      "rico:history": "Farming family active in the Eastern Cape, 1870s–1960s."
    }
  ]
}
```

**Required envelope fields:**

| Field | Cardinality | Notes |
|---|---|---|
| `@context` | 1 | MUST bind `rico` to the ontology IRI; SHOULD include `xsd` for typed literals. Additional prefixes (`openric`, `rdf`, `rdfs`, `owl`) are RECOMMENDED. |
| `@graph` | 1 | Array, non-empty. First element SHOULD be the requested root Record; subsequent elements are transitively-reachable authorities (creators, places, rules, activities, instantiations). |

**On empty dumps**: a dump for an entity with no transitively-reachable authorities still has at least the root in `@graph`. A request for a non-existent slug MUST return `404 not-found` as `application/problem+json` per Core Discovery §4 — NOT an empty envelope.

**Dump completeness**: the reachability walk SHOULD follow every `rico:*` predicate outward from the root, stop at entity boundaries (each reachable authority becomes its own `@graph` element; do not recursively walk the authority's *own* authorities unless they are also in the root Record's one-hop closure — otherwise the dump size becomes unbounded). Implementations MAY offer a `?depth=N` query parameter to widen the walk; that extension is outside the normative surface.

### 3.3 Turtle / RDF-XML dumps

The Turtle and RDF-XML representations MUST be **lossless round-trips of the same triple set** as the JSON-LD envelope. Clients that consume one format MUST be able to reconstruct the same graph from any other. Implementations SHOULD generate the alternative formats from the JSON-LD via an RDF library (e.g. `JsonLdConverter::toTurtle` / `::toRdfXml` in the reference implementation) rather than hand-serialising — this guarantees triple-set parity.

## 4. Error handling

### 4.1 OAI-PMH errors — native envelope

The OAI-PMH protocol defines its own error envelope inside the `OAI-PMH` XML root:

```xml
<OAI-PMH ...>
  <responseDate>2026-04-21T09:56:22Z</responseDate>
  <request>https://example.org/api/ric/v1/oai</request>
  <error code="badVerb">Unknown verb: Frobnicate</error>
</OAI-PMH>
```

Servers MUST use the OAI-PMH error envelope, not `application/problem+json`, on the `/oai` endpoint. Harvesters check for `<error code="...">` and will not parse problem+json. The OAI-PMH v2.0 error codes (`badVerb`, `badArgument`, `badResumptionToken`, `cannotDisseminateFormat`, `idDoesNotExist`, `noRecordsMatch`, `noMetadataFormats`, `noSetHierarchy`) are the complete allowed vocabulary per §3.6 of the protocol.

### 4.2 `/export` errors — RFC 7807

The `/records/{slug}/export` endpoint follows Core Discovery §4 / §4.1 — `application/problem+json`. Relevant type URIs:

- `404 not-found` — slug doesn't resolve to a record
- `400 bad-request` — unknown `?format=` value
- `406 not-acceptable` — `Accept:` header specifies a type the server can't produce (rare; the three types are universally supported)

## 5. SHACL shapes

This profile ships a minimal `shapes/profiles/export-only.shacl.ttl`:

| Shape | Target | Severity model |
|---|---|---|
| `:DumpEnvelopeShape` | Outer JSON-LD object of a `/export` response | `sh:Violation` on empty `@graph` (dumps with no content return `HTTP 204`, not `@graph: []`) |

**Why shapes coverage is narrow**: OAI-PMH responses are XML, not JSON-LD — SHACL cannot validate them. OAI-PMH conformance checking uses the OAI-PMH XML Schema (`OAI-PMH.xsd`) and the conformance probe's behavioural verb-by-verb tests, not SHACL. The JSON-LD envelope is the one piece of the profile SHACL can reach; it is covered.

## 6. Conformance testing

A server claims `export-only` when:

1. `GET /api/ric/v1/oai?verb=Identify` returns a `2.0`-protocol response matching the `oai-identify` fixture shape.
2. `GET /api/ric/v1/oai?verb=ListMetadataFormats` lists at least `oai_dc` and `rico_ld` per the `oai-list-metadata-formats` fixture.
3. `GET /api/ric/v1/oai?verb=ListRecords&metadataPrefix=oai_dc` returns valid OAI-PMH XML; the first record's `<metadata>` contains valid Dublin Core.
4. `GET /api/ric/v1/oai?verb=ListRecords&metadataPrefix=rico_ld` returns valid OAI-PMH XML; the first record's `<metadata>` contains a CDATA-wrapped JSON-LD document that validates against the `core-discovery` SHACL shapes (because the embedded document has the same shape as a Core Discovery single-entity response).
5. `GET /api/ric/v1/oai?verb=GetRecord&identifier=<valid>&metadataPrefix=oai_dc` and same with `rico_ld` both return the matching record.
6. `GET /api/ric/v1/oai?verb=Frobnicate` returns an OAI-PMH `<error code="badVerb">` envelope — NOT `application/problem+json`.
7. `GET /api/ric/v1/records/{known-slug}/export` returns `application/ld+json` with a `@graph`-wrapped envelope matching the `record-export-jsonld` fixture shape and validating against `:DumpEnvelopeShape`.
8. Same endpoint with `?format=ttl` returns `text/turtle` with the same triple set; `?format=rdf` returns `application/rdf+xml` with the same triple set (verify triple-count parity).
9. `GET /api/ric/v1/records/no-such-slug/export` returns `404 not-found` as `application/problem+json` — NOT an empty JSON-LD envelope.

Run the conformance probe with `--profile=export-only` to exercise all nine checks against a live server.

## 7. Fixture pack

The manifest declares these three fixtures as normative for `export-only`:

| Fixture | Status | What it pins |
|---|---|---|
| `oai-identify` | done | OAI-PMH Identify verb response — six required children + optional `<oai-identifier>` description |
| `oai-list-metadata-formats` | done | ListMetadataFormats advertising both mandatory prefixes (`oai_dc`, `rico_ld`) |
| `record-export-jsonld` | done | Per-record JSON-LD dump envelope with `@graph` array carrying root Record + reachable authorities |

Fixtures outside this list are NOT required for profile conformance.

## 8. Implementation checklist

- [ ] Implement `/api/ric/v1/oai` accepting both GET and POST
- [ ] Handle all six OAI-PMH verbs per §4 of the OAI-PMH v2.0 spec
- [ ] Advertise at least `oai_dc` and `rico_ld` in ListMetadataFormats
- [ ] Wrap `rico_ld` metadata in CDATA inside `<metadata>`
- [ ] Set `granularity: YYYY-MM-DDThh:mm:ssZ` in Identify (fine grain)
- [ ] Set `protocolVersion: 2.0` in Identify
- [ ] Return `<error code="...">` (not problem+json) on OAI-PMH errors
- [ ] Implement `/api/ric/v1/records/{slug}/export`
- [ ] Default to JSON-LD; honour `?format=ttl` and `?format=rdf`
- [ ] Emit `Content-Disposition: attachment` on exports
- [ ] Emit lossless round-trips across JSON-LD / Turtle / RDF-XML (triple-set parity)
- [ ] 404 (not empty envelope) for non-existent slug on `/export`
- [ ] Add `export-only` to `openric_conformance.profiles` in `GET /`
- [ ] Run the conformance probe with `--profile=export-only` — all 3 shipped fixtures pass
- [ ] `/conformance/badge?profile=export-only` returns shields.io JSON

## 9. Design decisions

Five questions were flagged during drafting; all five carry resolutions.

### Q1 — Should OAI-PMH be mandatory, or should a plain JSON-LD bulk endpoint replace it?

**Resolution**: **Mandatory.**

**Rationale**: OAI-PMH is 24 years old, widely hated for its XML verbosity, and universally implemented by every aggregator that matters (Europeana, DPLA, OpenAIRE, WorldCat, national-level portals). A RiC catalogue that exposes a novel JSON-LD-only bulk endpoint gets zero harvester pickup. OAI-PMH with `rico_ld` as a CDATA-wrapped prefix gives OpenRiC servers harvester compatibility *for free* — the wrapper is legacy; the contents are RiC-O. Replacing OAI-PMH with something JSON-native would be a decade-long adoption campaign; embedding RiC-O inside OAI-PMH is a weekend of code.

### Q2 — `rico_ld` inside CDATA, or a proper RiC-in-XML namespace?

**Resolution**: **CDATA-wrapped JSON-LD.**

**Rationale**: A proper XML namespace for RiC (`rico_xml`) would require defining an XSD for every RiC-O class, tracking ontology updates, and building converters in both directions. The RiC-O ontology itself ships as Turtle/RDF-XML, not as a pragmatic XML Schema. Wrapping JSON-LD in CDATA side-steps all of that: harvesters that can't parse RiC ignore the block and still get `oai_dc`; harvesters that can parse RiC unwrap the CDATA and get full semantics. This mirrors IIIF Presentation API's decision to embed JSON blobs inside whatever wire format the older protocol demanded.

### Q3 — `deletedRecord: transient` or `deletedRecord: no` as the baseline expectation?

**Resolution**: **`no` as baseline; implementations tracking deletes MAY declare `transient` or `persistent`.**

**Rationale**: Most archival catalogues do not track deletion provenance at the OAI level — records are purged or hidden, not tombstoned. Mandating `transient`/`persistent` would force every implementation to build a tombstone table before it could claim the profile, which is a barrier disproportionate to the benefit. Implementations that DO track deletes (via audit-log deletes from Round-Trip Editing, or via a dedicated tombstone table) MAY declare `transient`. Harvesters that depend on delete-aware sync SHOULD check the Identify response before running incremental harvests.

### Q4 — Store-wide dump endpoint?

**Resolution**: **Out of scope for Export-Only v0.9.**

**Rationale**: A naive `GET /records/export` (no slug) returns every record's transitively-reachable graph as one JSON-LD blob — fine for small catalogues, catastrophic at 10k+ records. Doing it right requires a pagination / resumption-token protocol distinct from OAI-PMH's token scheme. The combination (a) already-covered-by-OAI-PMH for harvesters, (b) already-covered-by-per-slug-dump for targeted exports, leaves the store-wide case in an awkward middle — big enough to need real engineering, niche enough that no concrete user need exists today. Revisit in v1.0+ if an implementer asks.

### Q5 — Lossless triple-set parity across JSON-LD / Turtle / RDF-XML — MUST or SHOULD?

**Resolution**: **MUST.**

**Rationale**: A consumer that re-runs `/export?format=ttl` and `/export?format=jsonld` MUST be able to produce the same triple set. Any silent asymmetry (e.g. Turtle drops an `@language` tag, RDF-XML over-quotes a date) breaks the "any format returns the same data" contract that makes content negotiation useful. The simplest way to guarantee parity is to generate alternative formats via an RDF library from the JSON-LD source — `JsonLdConverter::toTurtle` / `::toRdfXml` in the reference implementation. Hand-rolled serialisers almost always drift; don't write them.
