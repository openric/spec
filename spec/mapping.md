---
layout: default
title: OpenRiC Mapping Specification
---

# OpenRiC Mapping Specification

**Version:** 0.1.0-draft
**Status:** Draft — open for comment
**Last updated:** 2026-04-17

---

## 1. Purpose

This specification defines a deterministic mapping from the traditional archival-description standards — **ISAD(G)**, **ISAAR(CPF)**, **ISDIAH**, **ISDF** — to the ICA's **Records in Contexts** conceptual model ([RiC-CM v1.0](https://www.ica.org/standards/RiC/RiC-CM_1-0.pdf)) and its ontology ([RiC-O v1.0](https://www.ica.org/standards/RiC/ontology)).

Given a conforming input description, exactly one conforming RiC graph SHALL result. The mapping is total: every entity in the input has a defined target class in RiC, and every normatively-required ISAD(G)/ISAAR(CPF)/ISDIAH element has a defined target predicate.

A reference implementation exists in the [Heratio](https://github.com/ArchiveHeritageGroup/heratio) `ahg-ric` package (AGPL-3.0) and is the empirical source of this specification.

## 2. Terminology & conformance

The keywords **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, **MAY** in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).

An **implementation** is any system that accepts archival-description input in a form compatible with the [source schemas](#3-source-schemas) and emits RiC output. A **conformant implementation** passes all `L1` test fixtures in the [conformance suite](conformance.html).

## 3. Source schemas

This specification covers mapping from the following input entity types. Named after their canonical AtoM/Qubit tables; implementations MAY use different internal storage as long as the externally-visible semantics match.

| Source entity | Source standard | Example table |
|---|---|---|
| Information Object | ISAD(G) | `information_object` + `information_object_i18n` |
| Actor | ISAAR(CPF) | `actor` + `actor_i18n` |
| Repository | ISDIAH | `repository` + `repository_i18n` |
| Function | ISDF | `function` + `function_i18n` |
| Event | (AtoM extension) | `event` |
| Physical Object | (AtoM extension) | `thing` / storage / container |

## 4. Normative prefixes

Implementations MUST emit JSON-LD or Turtle with these prefixes bound as shown, unless otherwise indicated by content negotiation:

```
@prefix rico: <https://www.ica.org/standards/RiC/ontology#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
```

OpenRiC-specific viewing hints (defined in [Graph Primitives](graph-primitives.html)) use the prefix:

```
@prefix openric: <https://openric.org/ns/v1#> .
```

## 5. Identity & URI scheme

Every emitted RiC entity MUST have a stable, dereferenceable `@id`.

The canonical form is:

```
{baseUri}/{entity-path}/{slug-or-id}
```

Where:
- `{baseUri}` — the OpenRiC server's public base URL (e.g. `https://archives.example.org`).
- `{entity-path}` — one of `informationobject`, `actor`, `repository`, `function`, `event`, `thing`.
- `{slug-or-id}` — the human-readable slug if available, otherwise the numeric primary key.

Example: `https://archives.example.org/informationobject/AHG-A001-fonds-smuts`.

A server MAY additionally mint RiC-native UUIDs (e.g. `https://openric.org/id/{uuid}`) for external interchange. When present, these MUST be related to the canonical identifier via `owl:sameAs`.

---

## 6. Class mapping

### 6.1 Information Object → `rico:RecordSet` / `rico:Record` / `rico:RecordPart`

The RiC class is selected from the ISAD(G) *level of description* term:

| Source level | RiC class |
|---|---|
| `fonds` | `rico:RecordSet` |
| `subfonds` | `rico:RecordSet` |
| `collection` | `rico:RecordSet` |
| `series` | `rico:RecordSet` |
| `subseries` | `rico:RecordSet` |
| `file` | `rico:RecordSet` |
| `item` | `rico:Record` |
| `part` | `rico:RecordPart` |
| *(fallback — unknown level)* | `rico:Record` |

Implementations MAY extend this table for local levels but MUST preserve the `RecordSet` / `Record` / `RecordPart` coarse distinction.

### 6.2 Actor → `rico:Agent` hierarchy

Selected from the ISAAR(CPF) *type of entity* term:

| Source actor type | RiC class |
|---|---|
| `corporate body` | `rico:CorporateBody` |
| `person` | `rico:Person` |
| `family` | `rico:Family` |
| *(fallback — unknown type)* | `rico:Agent` |

### 6.3 Repository → `rico:CorporateBody`

Repositories (ISDIAH institutions) are always emitted as `rico:CorporateBody`. They are distinguished from other `CorporateBody` instances by:

- The `rico:hasOrHadHolder` inverse relation (records `rico:heldBy` them).
- Optional `openric:role "repository"` annotation for viewing convenience.

### 6.4 Function → `rico:Function` / `rico:Activity`

An ISDF function record with its own identifier maps to `rico:Function`. Individual occurrences of the function (instances of it being performed) map to `rico:Activity`, linked via `rico:hasActivity`.

### 6.5 Event → RiC event subclass

| Source event type | RiC class |
|---|---|
| `creation` | `rico:Production` |
| `contribution` | `rico:Production` |
| `accumulation` | `rico:Accumulation` |
| `collection` | `rico:Accumulation` |
| `custody` | `rico:Activity` |
| `publication` | `rico:Activity` |
| `reproduction` | `rico:Activity` |
| *(fallback — unknown event type)* | `rico:Activity` |

### 6.6 Physical Object → `rico:Thing`

Boxes, containers, shelves, cabinets, vaults, and equipment all map to `rico:Thing`. The local sub-type is preserved via `openric:localType`:

| Source thing type | RiC class | `openric:localType` |
|---|---|---|
| `box` | `rico:Thing` | `"box"` |
| `container` | `rico:Thing` | `"container"` |
| `shelf_unit` | `rico:Thing` | `"shelf_unit"` |
| `cabinet` | `rico:Thing` | `"cabinet"` |
| `vault` | `rico:Thing` | `"vault"` |
| `equipment` | `rico:Thing` | `"equipment"` |

---

## 7. Property mapping

### 7.1 Information Object (ISAD(G))

| ISAD(G) element | RiC predicate | Notes |
|---|---|---|
| 3.1.1 Reference code | `rico:identifier` | |
| 3.1.2 Title | `rico:title` | Language-tagged per `culture` |
| 3.1.3 Date(s) | `rico:hasDateRangeSet` → `rico:DateRange` | See §7.2 |
| 3.1.4 Level of description | *(drives class, see §6.1)* | Not emitted as a separate property |
| 3.1.5 Extent and medium | `rico:hasExtent` → `rico:Extent` with `rico:extentType` | |
| 3.2.1 Name of creator(s) | `rico:hasCreator` → `rico:Agent` | |
| 3.2.2 Administrative / biographical history | `rico:history` | On the Agent, not the Record |
| 3.2.3 Archival history | `rico:history` on the Record | Free-text |
| 3.2.4 Immediate source of acquisition | `rico:wasAcquiredFrom` → `rico:Agent` | |
| 3.3.1 Scope and content | `rico:description` | |
| 3.3.2 Appraisal, destruction, scheduling | `rico:hasAppraisalInformation` | |
| 3.3.3 Accruals | `openric:accrualsNote` | No direct RiC-O 1.0 predicate |
| 3.3.4 System of arrangement | `rico:arrangement` | |
| 3.4.1 Conditions governing access | `rico:conditionsOfAccess` | |
| 3.4.2 Conditions governing reproduction | `rico:conditionsOfUse` | |
| 3.4.3 Language/scripts of material | `rico:hasLanguage` → ISO 639-3 code | |
| 3.4.4 Physical characteristics | `rico:hasCarrier` | |
| 3.4.5 Finding aids | `rico:hasFindingAid` | |
| 3.5.1 Existence and location of originals | `rico:hasOrHadLocation` | |
| 3.5.2 Existence and location of copies | `rico:hasInstantiation` | |
| 3.5.3 Related units of description | `rico:isRelatedTo` | |
| 3.5.4 Publication note | `rico:publicationInformation` | |
| 3.6.1 Note | `rdfs:comment` | |
| 3.7.1 Archivist's note | `rico:descriptiveNote` | |
| 3.7.2 Rules or conventions | `rico:conformsTo` → `rico:Rule` | Links to ISAD/RAD/DACS record |
| 3.7.3 Dates of description | `rico:hasDateRangeSet` (descriptive) | Distinct from record dates |
| *(Subjects / access points)* | `rico:hasSubject` | |
| *(Parent)* | `rico:isContainedIn` | Inverse: `rico:hasRecordPart` |
| *(Children)* | `rico:hasRecordPart` | |
| *(Repository)* | `rico:heldBy` → `rico:CorporateBody` | |

### 7.2 Date ranges

Dates are emitted as `rico:DateRange` objects:

```json
{
  "@type": "rico:DateRange",
  "rico:startDate": { "@value": "1899-10-11", "@type": "xsd:date" },
  "rico:endDate":   { "@value": "1902-05-31", "@type": "xsd:date" },
  "rico:normalizedDate": "1899-10-11/1902-05-31",
  "rico:dateType": "existence"
}
```

`rico:dateType` values: `existence`, `creation`, `accumulation`, `descriptive`, `custody`.

### 7.3 Actor (ISAAR(CPF))

| ISAAR(CPF) element | RiC predicate |
|---|---|
| 5.1.2 Authorised form of name | `rico:name`, also `rico:normalizedForm` |
| 5.1.3 Parallel forms of name | `rico:alternativeForm` |
| 5.1.4 Standardised forms (other rules) | `rico:alternativeForm` |
| 5.1.5 Other forms of name | `rico:otherName` |
| 5.1.6 Identifiers | `rico:identifier` |
| 5.2.1 Dates of existence | `rico:hasDateRangeSet` with `dateType=existence` |
| 5.2.2 History | `rico:history` |
| 5.2.3 Places | `rico:hasPlace` → `rico:Place` |
| 5.2.4 Legal status | `rico:legalStatus` |
| 5.2.5 Functions, occupations, activities | `rico:performs` → `rico:Function`, `rico:hasOccupation` |
| 5.2.6 Mandates / sources of authority | `rico:hasMandate` → `rico:Mandate` |
| 5.2.7 Internal structures / genealogy | `rico:hasInternalStructure` |
| 5.2.8 General context | `rico:generalContext` |
| 5.3.x Relationships | `rico:isOrWasXxxOf` family — see §8 |

### 7.4 Repository (ISDIAH)

| ISDIAH element | RiC predicate |
|---|---|
| 5.1.2 Authorized form of name | `rico:name` |
| 5.1.3 Parallel / other forms | `rico:alternativeForm`, `rico:otherName` |
| 5.1.4 Institution type | `openric:institutionType` |
| 5.2.1 Location and address | `rico:hasPlace` → `rico:Place` with `rico:streetAddress` |
| 5.2.2 Telephone, fax, email | `rico:contact` → `rico:ContactPoint` |
| 5.3.1 History of the institution | `rico:history` |
| 5.3.2 Geographical and cultural context | `rico:generalContext` |
| 5.3.3 Mandates / sources of authority | `rico:hasMandate` |
| 5.3.4 Administrative structure | `rico:hasInternalStructure` |
| 5.3.5 Records management policies | `rico:hasOrHadPolicy` |
| 5.3.6 Building(s) | `rico:hasOrHadLocation` |
| 5.3.7 Archival and other holdings | `rico:hasHolding` → `rico:RecordSet` / `rico:Record` |
| 5.3.8 Finding aids | `rico:hasFindingAid` |
| 5.4.1 Opening times | `openric:openingHours` |
| 5.4.2 Conditions and requirements for access | `rico:conditionsOfAccess` |
| 5.4.3 Accessibility | `openric:accessibility` |

---

## 8. Relationships

Relationships between actors (ISAAR(CPF) 5.3) and between records (ISAD(G) 3.5.3) are emitted as properties of the source entity pointing at the target. Where RiC-O has a directed predicate, the source is the subject and the target is the object.

The commonest ISAAR relationships map to:

| ISAAR relationship | RiC predicate |
|---|---|
| Hierarchical: parent body | `rico:isOrWasSubordinateTo` |
| Hierarchical: subordinate body | `rico:hasOrHadSubordinate` |
| Family: member of family | `rico:isOrWasMemberOf` |
| Associative: successor of | `rico:succeeds` |
| Associative: predecessor of | `rico:precedes` |
| Associative: related to | `rico:isRelatedTo` |
| Temporal: controlled by (during period) | `rico:isOrWasControlledBy` |

Each relation MAY carry a `rico:Relation` reified object when date-scoping, certainty, or provenance are required:

```json
{
  "@type": "rico:FamilyRelation",
  "rico:source": "…/actor/smuts-jc",
  "rico:target": "…/actor/smuts-family",
  "rico:hasDateRangeSet": { "@type": "rico:DateRange", "rico:startDate": "1870-05-24" },
  "rico:certainty": "asserted"
}
```

---

## 9. Access, security, and privacy extensions

RiC-O v1.0 does not fully specify security classification or personal-data flags. OpenRiC defines the following extension properties:

| Property | Domain | Range | Meaning |
|---|---|---|---|
| `rico:hasSecurityClassification` | any RiC entity | `rico:SecurityClassification` | Carries a classification code (e.g. "Confidential", "Restricted") |
| `rico:hasAccessRestriction` | any RiC entity | `rico:AccessRestriction` | Scoped restriction — time, role, purpose |
| `rico:containsPersonalData` | `rico:Record` / `rico:RecordSet` | `xsd:boolean` | True if the record is known to contain personally identifiable information |

These are emitted **inside the standard RiC namespace** on the assumption that future RiC-O versions will adopt them. Implementations SHOULD treat them as authoritative and consumers SHOULD surface them in UI.

Jurisdictional compliance regimes (POPIA, GDPR, CDPA, IPSAS, GRAP 103, PAIA, NAZ, NMMZ …) are **out of scope** for OpenRiC. They are expressed by pluggable per-jurisdiction layers on top of these base properties.

---

## 10. Canonical example — fonds with subordinate series

### Input (abbreviated AtoM-shape JSON)

```json
{
  "informationObject": {
    "identifier": "AHG-A001",
    "title": "Papers of Jan Christian Smuts",
    "level_of_description": "fonds",
    "scope_and_content": "Correspondence, diaries, speeches, 1886–1950.",
    "dates": [{ "start_date": "1886-01-01", "end_date": "1950-09-11" }],
    "extent_and_medium": "3.2 linear metres, 18 boxes",
    "language": ["eng", "afr"],
    "repository_id": 14,
    "creator_id": 201,
    "children": [
      { "identifier": "AHG-A001-01", "level_of_description": "series",
        "title": "Correspondence" }
    ]
  }
}
```

### Output (RiC-O JSON-LD)

```json
{
  "@context": {
    "rico": "https://www.ica.org/standards/RiC/ontology#",
    "xsd":  "http://www.w3.org/2001/XMLSchema#"
  },
  "@id":   "https://archives.example.org/informationobject/AHG-A001",
  "@type": "rico:RecordSet",
  "rico:identifier": "AHG-A001",
  "rico:title": { "@value": "Papers of Jan Christian Smuts", "@language": "en" },
  "rico:description": "Correspondence, diaries, speeches, 1886–1950.",
  "rico:hasDateRangeSet": {
    "@type": "rico:DateRange",
    "rico:startDate": { "@value": "1886-01-01", "@type": "xsd:date" },
    "rico:endDate":   { "@value": "1950-09-11", "@type": "xsd:date" },
    "rico:dateType": "existence"
  },
  "rico:hasExtent": {
    "@type": "rico:Extent",
    "rico:extentType": "3.2 linear metres, 18 boxes"
  },
  "rico:hasLanguage": [
    { "@type": "rico:Language", "rico:languageCode": "eng" },
    { "@type": "rico:Language", "rico:languageCode": "afr" }
  ],
  "rico:heldBy": {
    "@id": "https://archives.example.org/repository/wits-historical-papers",
    "@type": "rico:CorporateBody",
    "rico:name": "Wits Historical Papers Research Archive"
  },
  "rico:hasCreator": {
    "@id": "https://archives.example.org/actor/smuts-jc",
    "@type": "rico:Person",
    "rico:name": "Smuts, Jan Christian"
  },
  "rico:hasRecordPart": [
    {
      "@id": "https://archives.example.org/informationobject/AHG-A001-01",
      "@type": "rico:RecordSet",
      "rico:identifier": "AHG-A001-01",
      "rico:title": "Correspondence"
    }
  ]
}
```

---

## 11. Open issues

- **O-1 — Level-to-class flexibility.** The `file` level maps to `rico:RecordSet`, following Heratio's implementation. Some communities prefer `file` → `rico:Record`. Under discussion.
- **O-2 — Rights statements.** RiC-O's rights vocabulary is thin. A separate OpenRiC-Rights spec is likely, building on ODRL.
- **O-3 — Preservation events.** RiC-CM covers preservation; the predicate set in RiC-O 1.0 is incomplete for fine-grained PREMIS-equivalent events. Deferred to v0.2.
- **O-4 — Multilinguality of `rico:title` and `rico:description`.** Whether to emit one triple per culture with `@language`, or a single JSON-LD object with `@value`/`@language` pairs. Current recommendation: array of language-tagged strings. Under review.
- **O-5 — Thing / container modelling.** RiC-O does not have a native `Container` or `StorageLocation` class; we map to `rico:Thing` with `openric:localType`. May warrant an OpenRiC-Storage extension.

---

## 12. Change log

| Version | Date | Notes |
|---|---|---|
| 0.1.0-draft | 2026-04-17 | Initial draft extracted from Heratio `ahg-ric` reference implementation. |

---

[Back to OpenRiC](../)
