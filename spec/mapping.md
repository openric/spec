---
layout: default
title: OpenRiC Mapping Specification
---

# OpenRiC Mapping Specification

**Last revised in:** v0.46.0
**Status:** Active - cross-referenced with RiC-AG (Application Guidelines) v0.1
**Last updated:** 2026-10-15

---

<div class="callout" markdown="1">

### ✅ RiC-O 1.1 namespace remediation - complete (v0.37.0, 2026-04-25)

This document has been remediated against [RiC-O 1.1 (2025-05-22)](https://www.ica.org/standards/RiC/ontology/1.1). Every `rico:*` term emitted as data is canonical 1.1; every term that needed renaming, remodelling, or moving to the OpenRiC extension namespace has been processed across five phases (A → E). The full per-term disposition table and phase summaries are at [audit/ric-o-1.1-audit.html]({{ '/audit/ric-o-1.1-audit.html' | relative_url }}).

The remaining `rico:*` tokens that appear in this document are exclusively in **"MUST NOT emit X"** warnings explaining what's *not* in RiC-O 1.1 - they are documentation prose, not emissions. Implementations of any OpenRiC profile MUST NOT emit them as data.

</div>

## 1. Purpose

This specification defines a deterministic mapping from the traditional archival-description standards - **ISAD(G)**, **ISAAR(CPF)**, **ISDIAH**, **ISDF** - to the ICA's **Records in Contexts** conceptual model ([RiC-CM v1.0](https://www.ica.org/app/uploads/2023/12/RiC-CM-1.0.pdf)) and its ontology ([RiC-O v1.1, 2025-05-22](https://www.ica.org/standards/RiC/ontology/1.1)).

Given a conforming input description, exactly one conforming RiC graph SHALL result. The mapping is total: every entity in the input has a defined target class in RiC, and every normatively-required ISAD(G)/ISAAR(CPF)/ISDIAH element has a defined target predicate.

A reference implementation exists in the [Heratio](https://github.com/ArchiveHeritageGroup/heratio) `ahg-ric` package (AGPL-3.0) and is the empirical source of this specification.

### 1.1 Alignment with RiC-O Converter v3.0

This mapping is **consistent with the conventions of [RiC-O Converter v3.0](https://github.com/ArchivesNationalesFR/rico-converter)** (Sparna + AnF Lab, March 2025) - the canonical EAD 2002 / EAC-CPF → RiC-O converter. Where this spec and the Converter make different decisions, the differences are documented:

- **Source standards**: OpenRiC mapping covers ISAD(G), ISAAR(CPF), ISDIAH, ISDF (the AtoM/Heratio source set). RiC-O Converter covers EAD 2002 and EAC-CPF (the international XML formats). The two source sets overlap on ISAD(G) ↔ EAD and ISAAR(CPF) ↔ EAC-CPF; the Converter does NOT cover ISDIAH or ISDF source data, OpenRiC does.
- **Output RiC-O version**: both target RiC-O 1.1.
- **Property choices**: where both standards model the same concept, this spec emits the same `rico:*` property the Converter emits (verified for `rico:hasOrHadInstantiation`, `rico:hasOrHadHolder`, `rico:hasOrHadAgentName`, `rico:hasOrHadLanguage`, the date-property family, the inclusion-relation family, and others - see the [audit document](../audit/ric-o-1.1-audit.html) for the per-term decisions).
- **Extension namespace**: where neither the Converter nor RiC-O 1.1 covers a needed concept, OpenRiC mints terms in `openricx:` (see [`/ns/ext/v1.html`](../ns/ext/v1.html)). The Converter does not currently use an extension namespace; OpenRiC adopters that also use the Converter can ignore the openricx terms and stay strict-RiC-O.

Institutions migrating existing EAD finding aids can reasonably use the Converter to bootstrap their corpus and an OpenRiC-conformant server (any conformant implementation, not just the reference) to expose the result over HTTP.

### 1.2 Cross-reference with RiC-AG (Application Guidelines)

This mapping is **cross-referenced with [RiC-AG v0.1](https://ica-egad.github.io/RiC-AG/)** (ICA-EGAD Application Guidelines, October 2025). RiC-AG ships a [crosswalk from the four legacy ICA standards](https://ica-egad.github.io/RiC-AG/mappings.html) - ISAD(G), ISAAR(CPF), ISDF, ISDIAH - to RiC-CM, which is exactly the source-standard set this mapping spec covers.

OpenRiC treats RiC-AG as the **upstream authoritative reference** for that crosswalk. Where this spec and RiC-AG agree on a class or property mapping, RiC-AG is canonical and OpenRiC defers. Where they diverge - intentionally or as drift - the divergence is documented:

- **Intentional divergences:** OpenRiC mints `openricx:` terms where neither RiC-O 1.1 nor RiC-AG covers a needed concept (e.g. `openricx:containsPersonalData`, `openricx:hasMimeType`, the `openricx:hasDateRangeSet` wrapper for the multi-event date pattern). These are documented in [`/ns/ext/v1.html`](../ns/ext/v1.html) and tracked as [upstream-proposal candidates](https://github.com/openric/spec/tree/main/docs/upstream-proposals) for eventual contribution back to RiC-O via EGAD.
- **Source-set extension:** OpenRiC covers ISDF and ISDIAH at the same level of detail as ISAD(G) and ISAAR(CPF). RiC-AG v0.1 covers all four; OpenRiC's per-standard tables in §6 are intended to be consistent with RiC-AG's crosswalk tables, not parallel definitions.
- **Forthcoming EAC-CPF → RiC-O 1.1 mapping:** announced under RiC-AG as "planned to be released as soon as possible." When it lands, this spec will cross-reference it from §6.2 (Actor) alongside the existing [RiC-O Converter](#11-alignment-with-ric-o-converter-v30) alignment. Tracked in [drift-log](../drift-log.html).

Implementations of OpenRiC profiles SHOULD treat RiC-AG as the application-pattern reference and this spec as the deployable-API contract. The two are designed to be coherent: RiC-AG answers *what* to model; OpenRiC answers *how* to expose it over HTTP.

### 1.3 Versions cited, what this mapping claims, and what OpenRiC adds

Every mapping row in this document is made against these editions. A newer edition of any of them is not covered until this table names it.

| Text | Edition this mapping cites | Its role here |
|---|---|---|
| ISAD(G) | Second edition, ICA, 2000 (adopted Stockholm, 1999) | Source standard, §7.1 |
| ISAAR(CPF) | Second edition, ICA, 2004 | Source standard, §7.3 |
| ISDIAH | First edition, ICA, 2008 | Source standard, §7.4 |
| ISDF | First edition, ICA, 2007 | Source standard, §6.4 |
| RiC-CM | [1.0](https://www.ica.org/app/uploads/2023/12/RiC-CM-1.0.pdf), ICA EGAD, 2023 | Target conceptual model |
| RiC-O | [1.1](https://www.ica.org/standards/RiC/ontology/1.1), 2025-05-22 | Target ontology; every `rico:` term emitted as data |
| RiC-AG | [0.1](https://ica-egad.github.io/RiC-AG/), ICA EGAD, October 2025 | Upstream crosswalk, authoritative where it covers a field (§1.2) |
| RiC-O Converter | [3.0](https://github.com/ArchivesNationalesFR/rico-converter), Sparna and AnF Lab, March 2025 | Alignment reference (§1.1); not a dependency |


**What this mapping does not claim.**

- **No ICA endorsement.** OpenRiC is independent of the ICA and EGAD, which have not reviewed or endorsed this mapping ([RiC baseline](../ric-baseline.html#openric-and-the-ica)). Where it disagrees with an ICA text, the ICA text is right.
- **No lossless round trip from the legacy standards.** Some source fields have no RiC-O 1.1 property and land in `openricx:` terms or in notes; a consumer that reads only `rico:` terms will not see them. The Portability profile's round-trip guarantee is about OpenRiC exports, not about ISAD(G) or EAD input.
- **Agreement with RiC-AG and the Converter is partial and stated.** The property choices listed in §1.1 have been checked against the Converter. The tables in §7 were compared with RiC-AG's crosswalk row by row on 15 October 2026 ([comparison](../audit/ric-ag-crosswalk-comparison.html)): of 107 elements, 55 are mapped here, and the differences found are listed there and in O-8.
- **OpenRiC conformance is not RiC conformance.** Passing an OpenRiC profile shows a server exposes this contract. RiC itself defines no conformance test, and nothing here should be read as certifying RiC compliance.

**What OpenRiC adds on top of RiC.** None of the following is part of Records in Contexts.

| Layer | Where it is defined | Status |
|---|---|---|
| `openricx:` extension terms (list envelopes, the interim `openricx:Function` class, contact points, date-range sets, ISAD(G) notes with no RiC-O predicate, checksums and MIME types, personal-data and appraisal flags) | [`/ns/ext/v1`](../ns/ext/v1.html) | Published; candidates for upstream proposal, never presented as `rico:` |
| `openric:` API terms (list envelopes, service description, errors, subgraphs, nodes, edges, layout hints) and the `localType`, `jurisdiction` and `role` annotations | [`/ns/v1`](../ns/v1.html), with their use in [Graph Primitives](graph-primitives.html) and the profiles | Published 2026-10-15 (O-6) |
| HTTP API, profiles, JSON Schemas, SHACL shapes, fixtures and the [API contract](/contract/openapi.json) | This specification | Versioned with the spec ([change control](change-control.html)) |


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
@prefix rico:    <https://www.ica.org/standards/RiC/ontology#> .
@prefix openricx: <https://openric.org/ns/ext/v1#> .
@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:     <http://www.w3.org/2001/XMLSchema#> .
@prefix skos:    <http://www.w3.org/2004/02/skos/core#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix owl:     <http://www.w3.org/2002/07/owl#> .
```

API terms - list envelopes, the service description, errors, graph primitives - and three entity annotations (`localType`, `jurisdiction`, `role`) use the prefix below, defined by the [OpenRiC API vocabulary](../ns/v1.html):

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
- `{baseUri}` - the OpenRiC server's public base URL (e.g. `https://archives.example.org`).
- `{entity-path}` - one of `informationobject`, `actor`, `repository`, `function`, `event`, `thing`.
- `{slug-or-id}` - the human-readable slug if available, otherwise the numeric primary key.

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
| *(fallback - unknown level)* | `rico:Record` |

Implementations MAY extend this table for local levels but MUST preserve the `RecordSet` / `Record` / `RecordPart` coarse distinction.

### 6.2 Actor → `rico:Agent` hierarchy

Selected from the ISAAR(CPF) *type of entity* term, extended with `mechanism` for software systems that perform provenance-significant activities (see §10):

| Source actor type | RiC class |
|---|---|
| `corporate body` | `rico:CorporateBody` |
| `person` | `rico:Person` |
| `family` | `rico:Family` |
| `mechanism` | `rico:Mechanism` |
| *(fallback - unknown type)* | `rico:Agent` |

`rico:Mechanism` is a canonical RiC-O 1.1 subclass of `rico:Agent`, used for software systems, devices, importers, AI services, OCR pipelines, and other automated agents whose actions on records can be attributed in provenance. ICA-EGAD examples (Florence Clavaud, RiC user group #27) include scanners and digital cameras as Mechanisms participating in digitisation Activities.

### 6.3 Repository → `rico:CorporateBody`

Repositories (ISDIAH institutions) are always emitted as `rico:CorporateBody`. They are distinguished from other `CorporateBody` instances by:

- The `rico:hasOrHadHolder` inverse relation (records `rico:hasOrHadHolder` them).
- Optional `openric:role "repository"` annotation for viewing convenience.

### 6.4 Function → `openricx:Function` (interim) - see canonical alternatives below

RiC-O 1.1 does **not** define `rico:Function` as a class, and ICA-EGAD guidance (Florence Clavaud, RiC user group) is that an archival/business *function* is best modelled in canonical RiC-O as either:

1. **A SKOS Concept** in a function-classification ConceptScheme (when the function is a vocabulary term), with `rico:Activity` instances classified by it, OR
2. **A `rico:Activity`** with `rico:hasActivityType <…function-type IRI…>` (when the function manifests as a concrete event).

OpenRiC currently exposes ISDF function records through the `/functions` API surface and serializes them as **`openricx:Function`** as an interim canonical class, pending: (a) a SKOS function-type vocabulary publication, and (b) an upstream proposal to ICA-EGAD if the community converges on a canonical class. Implementations claiming the Authority & Context profile MUST NOT emit `rico:Function` (which is not in RiC-O 1.1).

There is no canonical "performs this function" property in RiC-O 1.1. Where the source data has an Activity that is an instance of a Function, link via the SKOS classification on the Activity's `rico:hasActivityType`, not via a `rico:hasActivity` predicate (which is not in RiC-O 1.1).

### 6.5 Event → `rico:Activity` + `rico:hasActivityType`

RiC-O 1.1 does **not** define `rico:Production`, `rico:Accumulation`, `rico:CustodyEvent`, `rico:Transfer`, or any other concrete `rico:Activity` subclass - only the parent class `rico:Activity` is canonical. Earlier OpenRiC drafts (≤ v0.36) emitted `rico:Production` / `rico:Accumulation` as concrete classes; this was a non-conformant assumption flagged by the [RiC-O 1.1 audit](../audit/ric-o-1.1-audit.html).

The current pattern is: every event MUST be typed as `rico:Activity` and MUST carry a `rico:hasActivityType` IRI from the OpenRiC activity-type vocabulary:

| Source event type | RiC class | `rico:hasActivityType` (IRI) |
|---|---|---|
| `creation` | `rico:Activity` | `<https://openric.org/vocab/activity-type/production>` |
| `contribution` | `rico:Activity` | `<https://openric.org/vocab/activity-type/production>` |
| `accumulation` | `rico:Activity` | `<https://openric.org/vocab/activity-type/accumulation>` |
| `collection` | `rico:Activity` | `<https://openric.org/vocab/activity-type/accumulation>` |
| `custody` | `rico:Activity` | `<https://openric.org/vocab/activity-type/custody>` |
| `transfer` | `rico:Activity` | `<https://openric.org/vocab/activity-type/transfer>` |
| `publication` | `rico:Activity` | `<https://openric.org/vocab/activity-type/publication>` |
| `reproduction` | `rico:Activity` | `<https://openric.org/vocab/activity-type/reproduction>` |
| *(fallback - unknown event type)* | `rico:Activity` | (none - preserve in `openric:localType`) |

The activity-type IRIs MAY be modelled as a SKOS concept scheme in a future release; today they are dereferenceable identifiers only. Implementations MAY mint local activity-type IRIs (e.g. `<https://archives.example.org/vocab/activity-type/migration>`) for site-specific event kinds, but MUST also emit `openric:localType` so consumers without the local vocabulary can still dispatch.

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
| 3.1.3 Date(s) | `openricx:hasDateRangeSet` → `openricx:DateRange` | See §7.2. The API shape; in RDF it expands to `rico:hasCreationDate`, `rico:hasBeginningDate` and `rico:hasEndDate` → `rico:Date` (RiC-AG) |
| 3.1.4 Level of description | *(drives class, see §6.1)*, and `rico:hasRecordSetType` → `rico:RecordSetType` on a RecordSet | The class alone loses the level name; RiC-AG §5.3.1 |
| 3.1.5 Extent and medium | `rico:hasExtent` → `rico:Extent` with `rico:hasExtentType` | |
| 3.2.1 Name of creator(s) | `rico:hasCreator` → `rico:Agent` | |
| 3.2.2 Administrative / biographical history | `rico:history` | On the Agent, not the Record |
| 3.2.3 Archival history | `rico:history` on the Record | Free-text |
| 3.2.4 Immediate source of acquisition | `rico:isOrWasAffectedBy` → `rico:Activity` (activity type `transfer`) with `rico:hasOrHadParticipant` → the source `rico:Agent` | Was `rico:hasOrganicProvenance`, which names the creator or accumulator, not the source (RiC-AG) |
| 3.3.1 Scope and content | `rico:scopeAndContent` | Was `openricx:description`; servers that sent it SHOULD send both until at least v0.48.0 |
| 3.3.2 Appraisal, destruction, scheduling | `openricx:hasAppraisalInformation` | |
| 3.3.3 Accruals | `rico:accruals` | RiC-O 1.1 property; `openricx:accrualsNote` (v0.44.0) is deprecated |
| 3.3.4 System of arrangement | `rico:structure` | Was `openricx:arrangement` (deprecated) |
| 3.4.1 Conditions governing access | `rico:conditionsOfAccess` | |
| 3.4.2 Conditions governing reproduction | `rico:conditionsOfUse` | |
| 3.4.3 Language/scripts of material | `rico:hasOrHadLanguage` → ISO 639-3 code | |
| 3.4.4 Physical characteristics | `rico:physicalCharacteristicsNote` on the record's `rico:Instantiation` | Was `rico:hasCarrierType`, which names the carrier, not its condition |
| 3.4.5 Finding aids | `rico:isOrWasDescribedBy` → finding-aid Record (which carries `rico:hasDocumentaryFormType <https://www.ica.org/standards/RiC/ontology#FindingAid>`) | Canonical RiC-O 1.1 pattern per Florence Clavaud (RiC user group) - `FindingAid` is a `DocumentaryFormType` individual, not a separate property |
| 3.5.1 Existence and location of originals | `rico:hasOrHadLocation` | |
| 3.5.2 Existence and location of copies | `rico:hasOrHadInstantiation` | |
| 3.5.3 Related units of description | `rico:isRelatedTo` | |
| 3.5.4 Publication note | `openricx:publicationInformation` | |
| 3.6.1 Note | `rico:generalDescription` | Was `rdfs:comment` |
| 3.7.1 Archivist's note | `openricx:descriptiveNote` | |
| 3.7.2 Rules or conventions | `rico:isOrWasRegulatedBy` → `rico:Rule` | Links to the ISAD/RAD/DACS rule; `dcterms:conformsTo` MAY also be sent |
| 3.7.3 Dates of description | `openricx:hasDateRangeSet` (descriptive) | Distinct from record dates |
| *(Subjects / access points)* | `rico:hasOrHadSubject` | |
| *(Parent)* | `rico:isOrWasIncludedIn` | Inverse: `rico:includesOrIncluded` |
| *(Children)* | `rico:includesOrIncluded` | |
| *(Repository)* | `rico:hasOrHadHolder` → `rico:CorporateBody` | |

### 7.2 Date ranges

Dates are emitted as `openricx:DateRange` objects:

```json
{
  "@type": "openricx:DateRange",
  "rico:hasBeginningDate": { "@value": "1899-10-11", "@type": "xsd:date" },
  "rico:endDate":   { "@value": "1902-05-31", "@type": "xsd:date" },
  "rico:normalizedDateValue": "1899-10-11/1902-05-31",
  "rico:hasDateType": "existence"
}
```

`rico:hasDateType` values: `existence`, `creation`, `accumulation`, `descriptive`, `custody`.

### 7.3 Actor (ISAAR(CPF))

| ISAAR(CPF) element | RiC predicate |
|---|---|
| 5.1.1 Type of entity | *(drives class: `rico:Person`, `rico:CorporateBody` or `rico:Family`, see §6.2)* |
| 5.1.2 Authorised form of name | `rico:name`, also `openricx:normalizedForm` |
| 5.1.3 Parallel forms of name | `openricx:alternativeForm` |
| 5.1.4 Standardised forms (other rules) | `openricx:alternativeForm` |
| 5.1.5 Other forms of name | `openricx:otherName` |
| 5.1.6 Identifiers | `rico:identifier` |
| 5.2.1 Dates of existence | `openricx:hasDateRangeSet` with `dateType=existence`; in RDF `rico:hasBirthDate` / `rico:hasDeathDate` (persons) or `rico:hasBeginningDate` / `rico:hasEndDate` → `rico:Date` |
| 5.2.2 History | `rico:history` |
| 5.2.3 Places | `rico:isAssociatedWithPlace` → `rico:Place` |
| 5.2.4 Legal status | `rico:hasOrHadLegalStatus` |
| 5.2.5 Functions, occupations, activities | `rico:performsOrPerformed` → `openricx:Function` (interim, see §6.4); `openricx:hasOccupation` → SKOS Concept of `rico:OccupationType` (RiC-O 1.1 has no direct `Agent → OccupationType` linking property - Aaron+Florence in RiC user group #20 endorse SKOS individuals of `OccupationType`; canonical RDF expansion: an `Activity` typed by an OccupationType IRI per §6.5) |
| 5.2.6 Mandates / sources of authority | `rico:authorizingMandate` → `rico:Mandate` |
| 5.2.7 Internal structures / genealogy | `openricx:hasInternalStructure` |
| 5.2.8 General context | `openricx:generalContext` |
| 5.3.x Relationships | `isOrWas...Of` property family (e.g. `rico:isOrWasOwnerOf`, `rico:isOrWasHolderOf`) - see §8 |
| 5.4.x Control area | See §7.5 |

### 7.4 Repository (ISDIAH)

| ISDIAH element | RiC predicate |
|---|---|
| 5.1.1 Identifier | `rico:identifier` |
| 5.1.2 Authorized form of name | `rico:name` |
| 5.1.3 Parallel / other forms | `openricx:alternativeForm`, `openricx:otherName` |
| 5.1.5 Type of institution | `openricx:institutionType` |
| 5.2.1 Location and address | `rico:hasOrHadLocation` → `rico:Place` with `openricx:streetAddress` |
| 5.2.2 Telephone, fax, email | `openricx:contact` → `openricx:ContactPoint` |
| 5.3.1 History of the institution | `rico:history` |
| 5.3.2 Geographical and cultural context | `openricx:generalContext` |
| 5.3.3 Mandates / sources of authority | `rico:authorizingMandate` |
| 5.3.4 Administrative structure | `openricx:hasInternalStructure` |
| 5.3.5 Records management policies | `openricx:hasOrHadPolicy` |
| 5.3.6 Building(s) | `rico:hasOrHadLocation` |
| 5.3.7 Archival and other holdings | `rico:isOrWasHolderOf` → `rico:RecordSet` / `rico:Record` |
| 5.3.8 Finding aids | `rico:isOrWasDescribedBy` → finding-aid Record with `rico:hasDocumentaryFormType <…#FindingAid>` |
| 5.4.1 Opening times | `openricx:openingHours` |
| 5.4.2 Conditions and requirements for access | `rico:conditionsOfAccess` |
| 5.4.3 Accessibility | `openricx:accessibility` |
| 5.2.3 Contact persons | `openricx:contact` → `openricx:ContactPoint`; a named person as `rico:Person` with `rico:hasOrHadPosition` |
| 5.5.1 Research services | `rico:performsOrPerformed` → `rico:Activity`, or text in `rico:generalDescription` |
| 5.5.2 Reproduction services | As 5.5.1 |
| 5.5.3 Public areas | `rico:hasOrHadLocation` → `rico:Place`, with `rico:generalDescription` |
| 5.6.x Control area | See §7.5 |

---

### 7.5 Control areas (ISAAR(CPF) 5.4, ISDF 5.4, ISDIAH 5.6)

Following RiC-AG §5.3.4, a description is itself a `rico:Record` that `rico:describesOrDescribed` the entity and `rico:resultsOrResultedFrom` the `rico:Activity` that produced it.

| Element | RiC-O 1.1 |
|---|---|
| Description identifier (5.4.1 / 5.6.1) | `rico:identifier` on the describing Record |
| Institution identifier (5.4.2 / 5.6.2) | The describing Record `rico:resultsOrResultedFrom` an Activity that `rico:isOrWasPerformedBy` the institution |
| Rules and/or conventions (5.4.3 / 5.6.3) | `rico:isOrWasRegulatedBy` → `rico:Rule` |
| Status (5.4.4 / 5.6.4) | No RiC-O 1.1 property; text in `rico:generalDescription` |
| Level of detail (5.4.5 / 5.6.5) | `rico:generalDescription` |
| Dates of creation, revision or deletion (5.4.6 / 5.6.6) | `rico:hasCreationDate` and `rico:hasModificationDate` → `rico:Date` |
| Language(s) and script(s) (5.4.7 / 5.6.7) | `rico:hasOrHadLanguage` → `rico:Language` |
| Sources (5.4.8 / 5.6.8) | `rico:generalDescription` |
| Maintenance notes (5.4.9 / 5.6.9) | `rico:generalDescription` |

### 7.6 Function (ISDF)

OpenRiC serves functions as `openricx:Function` (§6.4). RiC-AG maps ISDF to `rico:Activity`; the properties below apply to either.

| ISDF element | RiC predicate |
|---|---|
| 5.1.1 Type | `rico:hasActivityType` |
| 5.1.2 Authorised form(s) of name | `rico:name` |
| 5.1.3 Parallel form(s) of name | `openricx:alternativeForm` |
| 5.1.4 Other form(s) of name | `openricx:otherName` |
| 5.1.5 Classification | `rico:classification` |
| 5.2.1 Dates | `rico:hasBeginningDate` / `rico:hasEndDate` → `rico:Date`; free text in `rico:date` |
| 5.2.2 Description | `rico:generalDescription` |
| 5.2.3 History | `rico:history` |
| 5.2.4 Legislation | `rico:isOrWasRegulatedBy` → `rico:Rule` |
| 5.3.x Related functions | `rico:isRelatedTo`, or `rico:followsInTime` / `rico:isOrWasPartOf` where the relation is known |
| 5.4.x Control area | See §7.5 |

## 8. Relationships

Relationships between actors (ISAAR(CPF) 5.3) and between records (ISAD(G) 3.5.3) are emitted as properties of the source entity pointing at the target. Where RiC-O has a directed predicate, the source is the subject and the target is the object.

The commonest ISAAR relationships map to:

| ISAAR relationship | RiC predicate |
|---|---|
| Hierarchical: parent body | `rico:isOrWasSubordinateTo` |
| Hierarchical: subordinate body | `rico:hasOrHadSubordinate` |
| Family: member of family | `rico:isOrWasMemberOf` |
| Associative: successor of | `rico:followsInTime` |
| Associative: predecessor of | `rico:precedesInTime` |
| Associative: related to | `rico:isRelatedTo` |
| Temporal: controlled by (during period) | `rico:hasOrHadController` (Agent → Agent; reify as `rico:AgentControlRelation` with date-scoping when needed) |

Each relation MAY carry a `rico:Relation` reified object when date-scoping, certainty, or provenance are required:

```json
{
  "@type": "rico:FamilyRelation",
  "rico:relationHasSource": "…/actor/smuts-jc",
  "rico:relationHasTarget": "…/actor/smuts-family",
  "openricx:hasDateRangeSet": { "@type": "openricx:DateRange", "rico:hasBeginningDate": "1870-05-24" },
  "rico:relationCertainty": "asserted"
}
```

---

## 9. Access, security, and privacy extensions

RiC-O 1.1 does **not** define `AccessRestriction` or `SecurityClassification` as classes, and does not define `hasAccessRestriction` / `hasAccessRule` / `hasSecurityClassification` as properties. The canonical pattern is:

- **The link from a regulated resource to its governing rule** is `rico:isOrWasRegulatedBy` (subject = the regulated `RecordResource` / `Instantiation` / etc.; object = a `rico:Rule`).
- **The kind of rule** is carried on the `rico:Rule` instance via `rico:hasOrHadRuleType` pointing at a SKOS Concept from the OpenRiC rule-type vocabulary.

OpenRiC rule-type IRIs (subset - a SKOS `ConceptScheme` will be published at `<https://openric.org/vocab/rule-type/>`):

| IRI | Meaning |
|---|---|
| `<https://openric.org/vocab/rule-type/access-restriction>` | Scoped restriction - time, role, purpose |
| `<https://openric.org/vocab/rule-type/security-classification>` | Classification code (e.g. "Confidential", "Restricted") |
| `<https://openric.org/vocab/rule-type/access-rule>` | General access governance |

Privacy / personal-data flag remains an OpenRiC extension property because RiC-O 1.1 does not yet model it:

| Property | Domain | Range | Meaning |
|---|---|---|---|
| `openricx:containsPersonalData` | `rico:Record` / `rico:RecordSet` | `xsd:boolean` | True if the record is known to contain personally identifiable information |

Example - a record regulated by an access-restriction Rule:

```turtle
<.../record/abc> rico:isOrWasRegulatedBy <.../rule/popia-2026> .
<.../rule/popia-2026> a rico:Rule ;
    rico:title "POPIA section 14 - personal data" ;
    rico:hasOrHadRuleType <https://openric.org/vocab/rule-type/access-restriction> .
```

Jurisdictional compliance regimes (POPIA, GDPR, CDPA, IPSAS, GRAP 103, PAIA, NAZ, NMMZ …) are **out of scope** for OpenRiC. They are expressed by pluggable per-jurisdiction layers on top of these base properties.

---

## 10. Systems, APIs, and Mechanisms

OpenRiC distinguishes between three layers that are sometimes conflated:

| Layer | Examples | RiC treatment |
|---|---|---|
| **API surface** (HTTP route) | `/records`, `/agents`, `/repositories`, `/functions` | **Not** a RiC-CM entity. Developer-facing access point. |
| **OpenRiC application concept** | "Repository", "Function", "Importer" | Useful for archivists / UI labels; mapped to canonical RiC entities below. |
| **Canonical RiC-CM/RiC-O entity** | `rico:Record`, `rico:Agent`, `rico:CorporateBody`, `rico:Activity`, `rico:Mechanism` | The semantic identity in the graph. |

API routes such as `/records`, `/agents`, `/repositories`, and `/functions` are convenience surfaces. They do not, by themselves, define new RiC-CM classes. Where an API surface corresponds directly to a RiC-CM entity, OpenRiC serializes the resource using the canonical RiC-O class. Where a route exists for archival usability (e.g. `/repositories`, `/functions`), the canonical graph representation maps the object to the closest RiC-CM/RiC-O construct (CorporateBody for repositories per §6.3; `openricx:Function` interim for functions per §6.4).

### 10.1 Software systems are `rico:Mechanism`

`rico:Mechanism` is a canonical RiC-O 1.1 subclass of `rico:Agent`. It is the correct class for any software system, device, service, or automated process that performs provenance-significant activities against records. ICA-EGAD direct guidance (Florence Clavaud, RiC user group thread #27) gives scanners and digital cameras as canonical examples; the same pattern extends to:

| Thing | RiC class |
|---|---|
| Importer (e.g. EAD-to-RiC converter) | `rico:Mechanism` |
| OCR / handwriting-recognition pipeline | `rico:Mechanism` |
| AI description / NER / summarisation model | `rico:Mechanism` |
| Migration script | `rico:Mechanism` |
| Validation engine | `rico:Mechanism` |
| Crawler / harvester | `rico:Mechanism` |
| API platform / service (when itself the actor of an event) | `rico:Mechanism` |

The actions performed by these mechanisms are modelled as `rico:Activity` instances, linked back via `rico:isOrWasPerformedBy` (or its inverse `rico:performsOrPerformed` on the Mechanism), and to the affected records via `rico:resultsOrResultedIn` / `rico:affectsOrAffected`.

### 10.2 Example - OpenRiC importer converting EAD to RiC-O

```turtle
@prefix rico:     <https://www.ica.org/standards/RiC/ontology#> .
@prefix openric:  <https://openric.org/id/> .
@prefix openricx: <https://openric.org/ns/ext/v1#> .

openric:mechanism/openric-importer a rico:Mechanism ;
    rico:name "OpenRiC EAD-to-RiC importer" ;
    openricx:technicalCharacteristics
        "Python/Laravel/Fuseki conversion service" .

openric:activity/conversion-2026-04-25 a rico:Activity ;
    rico:hasActivityType <https://openric.org/vocab/activity-type/transfer> ;
    rico:name "EAD to RiC-O conversion" ;
    rico:isOrWasPerformedBy openric:mechanism/openric-importer ;
    rico:resultsOrResultedIn openric:record/imported-graph-001 ;
    rico:isAssociatedWithDate [
        a openricx:DateRange ;
        rico:beginningDate "2026-04-25T08:00:00Z"^^xsd:dateTime
    ] .
```

This pattern keeps the OpenRiC HTTP/API layer cleanly separated from the canonical archival graph: the `/import` API endpoint is not a RiC entity, but the importer that the endpoint dispatches to *is* a `rico:Mechanism` whose conversions can be attributed in provenance.

---

## 11. Canonical example - fonds with subordinate series

### Input (abbreviated AtoM-shape JSON)

```json
{
  "informationObject": {
    "identifier": "AHG-A001",
    "title": "Papers of Jan Christian Smuts",
    "level_of_description": "fonds",
    "scope_and_content": "Correspondence, diaries, speeches, 1886-1950.",
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
  "openricx:description": "Correspondence, diaries, speeches, 1886-1950.",
  "openricx:hasDateRangeSet": {
    "@type": "openricx:DateRange",
    "rico:hasBeginningDate": { "@value": "1886-01-01", "@type": "xsd:date" },
    "rico:endDate":   { "@value": "1950-09-11", "@type": "xsd:date" },
    "rico:hasDateType": "existence"
  },
  "rico:hasExtent": {
    "@type": "rico:Extent",
    "rico:hasExtentType": "3.2 linear metres, 18 boxes"
  },
  "rico:hasOrHadLanguage": [
    { "@type": "rico:Language", "openricx:languageCode": "eng" },
    { "@type": "rico:Language", "openricx:languageCode": "afr" }
  ],
  "rico:hasOrHadHolder": {
    "@id": "https://archives.example.org/repository/wits-historical-papers",
    "@type": "rico:CorporateBody",
    "rico:name": "Wits Historical Papers Research Archive"
  },
  "rico:hasCreator": {
    "@id": "https://archives.example.org/actor/smuts-jc",
    "@type": "rico:Person",
    "rico:name": "Smuts, Jan Christian"
  },
  "rico:includesOrIncluded": [
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

## 12. Open issues

- **O-1 - Level-to-class flexibility.** The `file` level maps to `rico:RecordSet`, following Heratio's implementation. Some communities prefer `file` → `rico:Record`. Under discussion.
- **O-2 - Rights statements.** RiC-O's rights vocabulary is thin. A separate OpenRiC-Rights spec is likely, building on ODRL.
- **O-3 - Preservation events.** RiC-CM covers preservation; the predicate set in RiC-O 1.1 is incomplete for fine-grained PREMIS-equivalent events. Open; no release targeted.
- **O-4 - Multilinguality of `rico:title` and `openricx:description`.** Whether to emit one triple per culture with `@language`, or a single JSON-LD object with `@value`/`@language` pairs. Current recommendation: array of language-tagged strings. Under review.
- **O-5 - Thing / container modelling.** RiC-O does not have a native `Container` or `StorageLocation` class; we map to `rico:Thing` with `openric:localType`. May warrant an OpenRiC-Storage extension.
- **O-6 - `openric:` terms with no definition (resolved 2026-10-15).** §4 bound `openric:` for viewing hints, yet the profiles, schemas, fixtures and the reference service also used it for list envelopes, errors, the service description and the `localType`, `jurisdiction` and `role` annotations, and no vocabulary at `https://openric.org/ns/v1#` defined any of them. The [OpenRiC API vocabulary](../ns/v1.html) now defines every `openric:` term in use, so no response changed. The four terms only this mapping named and nothing emitted (`accrualsNote`, `institutionType`, `openingHours`, `accessibility`) moved to `openricx:`. `openricx:jurisdiction`, defined but never emitted, is deprecated in favour of `openric:jurisdiction`. Five fixtures that used `openric:` without binding it now bind it, as the service does, and `bin/check-vocab.py` fails CI on any undefined or unbound term.
- **O-7 - Pinned RiC-O version disagreed (resolved 2026-10-15).** The draft [Governance profile](profiles/governance.html) §2 pinned RiC-O 1.0.2, carried over from the Heratio implementation; it now pins 1.1, the version this mapping and every normative profile target.
- **O-8 - Differences from RiC-AG (resolved in the mapping 2026-10-15).** The [row-by-row comparison](../audit/ric-ag-crosswalk-comparison.html) found extension terms used where RiC-O 1.1 has a property, four semantic mismatches and 52 elements with no row. §7 now uses `rico:scopeAndContent`, `rico:structure`, `rico:generalDescription`, `rico:isOrWasRegulatedBy`, `rico:physicalCharacteristicsNote` and an acquisition Activity, states the RiC-O expansion of date range sets, adds `rico:hasRecordSetType`, and covers the control areas (§7.5) and ISDF (§7.6). Only scope and content was emitted by the reference service; it sends both forms until at least v0.48.0 (change control's deprecation period).

---

## 13. Change log

| Version | Date | Notes |
|---|---|---|
| v0.46.0 | 2026-10-15 | O-8 resolved: §7 rows follow RiC-AG with RiC-O 1.1 terms (scope and content, structure, notes, rules, physical characteristics, acquisition, date expansion, record set type); new §7.5 control areas and §7.6 ISDF. |
| v0.45.0 | 2026-10-15 | Compared row by row with RiC-AG (audit page; O-8 registered); 3.3.3 maps to `rico:accruals`; ISDIAH type of institution renumbered 5.1.5. |
| v0.44.0 | 2026-10-15 | Add §1.3: the editions every row is made against, what the mapping does not claim (ICA endorsement, lossless legacy round trip, full RiC-AG agreement, RiC conformance), and what OpenRiC adds on top of RiC. Register and resolve O-6 (publish the `openric:` API vocabulary; four mapping-only terms move to `openricx:`) and O-7 (Governance profile pin brought to RiC-O 1.1). |
| 0.38.1 | 2026-05-25 | Add §1.2 cross-reference with [RiC-AG v0.1](https://ica-egad.github.io/RiC-AG/) - treat RiC-AG as upstream-authoritative for the legacy-ICA-standards-to-RiC-CM crosswalk; document intentional `openricx:` divergences as upstream-proposal candidates; flag the forthcoming EAC-CPF → RiC-O 1.1 mapping for cross-reference when it lands. |
| 0.37.0 | 2026-04-25 | RiC-O 1.1 namespace remediation complete (Phases A-E); all `rico:*` terms emitted as data are canonical 1.1; per-term audit at `/audit/ric-o-1.1-audit.html`. |
| 0.1.0-draft | 2026-04-17 | Initial draft extracted from Heratio `ahg-ric` reference implementation. |

---

[Back to OpenRiC](../)
