---
layout: default
title: OpenRiC - Portability Profile
description: The anti-lock-in guarantee - lossless JSON-LD/Turtle round-trip, a self-describing DCAT/VoID dataset descriptor, a versioned change feed, and an optional validate-on-export hook. Your data stays yours, in standard formats, fully described.
---

# Portability Profile

**Profile id:** `portability`
**Profile version:** 0.43.0
**Spec version:** 0.43.0
**Status:** Draft - open for comment
**Dependencies:** [Export-Only](export-only.html) (the JSON-LD / Turtle / RDF-XML export surface Portability strengthens into a *guarantee*).
**Last updated:** 2026-06-19
**Reference implementation:** Heratio ([ArchiveHeritageGroup/heratio#1321](https://github.com/ArchiveHeritageGroup/heratio)) - `RicDatasetService`, `DatasetController`, `RdfImportService`, `RicRoundTripTest`, `docs/reference/ric-linked-data-export.md`.

---

## 1. Purpose

Portability is OpenRiC's **anti-lock-in guarantee**: standard serialisations + a self-describing dataset + a full export path mean an institution's data stays portable even if its tooling changes. Where [Export-Only](export-only.html) says *you can get the data out*, Portability says *it round-trips losslessly, it describes itself, and you can prove it conforms.*

A server claiming this profile commits to four things:

1. A **round-trip guarantee** - export then re-import yields the same graph (§2).
2. A **self-describing dataset descriptor** - DCAT + VoID at `/dataset` (§3).
3. A **versioned change feed** - `/changelog` (§4).
4. An optional **validate-on-export** hook (§5).

## 2. Round-trip portability guarantee

An entity serialised to **JSON-LD** *and* to **Turtle** MUST re-import to the same graph: title, identifier, description, and core relations intact. Conformance requires an **automated round-trip test** in the implementer's test kit (reference impl: `RicRoundTripTest`).

> Why a test, not a promise: in the reference impl the round-trip test surfaced and fixed a real, silent gap - the serializer emitted `rico:title` but the importer mapped only `rico:name` / `dc:title`, so **titles were dropped on re-import**. Only an executable round-trip caught it. A Portability claim without a passing round-trip test is not conformant.

Normative round-trip assertion (per entity, per format):

```
import( export(entity, "jsonld") ) ≡ entity   (title, identifier, description, core relations)
import( export(entity, "ttl")    ) ≡ entity
```

## 3. Self-describing dataset - `GET /api/ric/v1/dataset`

A conformant server publishes a **DCAT + VoID** descriptor (JSON-LD) so a consumer can discover, harvest and trust the dataset without out-of-band knowledge:

| Field | Source vocab | Meaning |
|---|---|---|
| `dcterms:title`, `dcterms:publisher`, `dcterms:license` | DCAT/DCTERMS | Identity + licensing |
| `dcat:version` | DCAT | Dataset version |
| `dcterms:conformsTo` | DCTERMS | The **pinned standards** (see [Governance](governance.html) §2) - RiC-O version, SKOS, PROV-O, CIDOC-CRM |
| `void:sparqlEndpoint` | VoID | The queryable endpoint |
| `dcat:distribution[]` | DCAT | **Every** access path: SPARQL, JSON-LD, Turtle, RDF/XML, OAI-PMH - each with `dcat:mediaType` + `dcat:accessURL` |

The descriptor MUST advertise *every* distribution the server offers - the point is that no access path is undocumented or proprietary-only.

## 4. Versioned change feed - `GET /api/ric/v1/changelog`

A machine-readable change feed listing released changes (date, version, migration impact) plus the currently pinned standard versions and a link to the [governance pin](governance.html). Consumers diff against it to detect breaking changes before they bite. This is the consumer-facing surface of the [Governance Profile](governance.html) §6 change process.

## 5. Validate-on-export (optional)

`GET /api/ric/v1/records/{slug}/export?validate=1` MAY run the published output through the RiC-O SHACL shapes and report conformance via response headers:

| Header | Values | Meaning |
|---|---|---|
| `X-SHACL-Validated` | `true` / `false` | Whether the validator ran |
| `X-SHACL-Conformant` | `true` / `false` / `unknown` | The verdict |
| `X-SHACL-Violations` | integer | Violation count |

**Fail open:** when the validator is unavailable, `validated=false` / `conformant=unknown` and the export still returns - validation is a reported signal, never a gate on getting your data out.

## 6. SHACL

Portability adds no entity shapes; it reuses the pinned RiC-O shapes ([Governance §5](governance.html)) for the validate-on-export verdict. The dataset descriptor is shape-checked against [`schemas/dataset.schema.json`](https://github.com/openric/spec/blob/main/schemas/dataset.schema.json).

## 7. Conformance

A server claims Portability when:

- Export → re-import round-trips losslessly for JSON-LD and Turtle, proven by an automated test.
- `GET /dataset` returns a DCAT/VoID descriptor naming every distribution + `dcterms:conformsTo` the pinned standards.
- `GET /changelog` returns a versioned change feed.
- (Optional) `?validate=1` reports SHACL conformance via headers, failing open.

Declared as `{ "id": "portability", "version": "0.43.0", "conformance": "full" }`.
