---
layout: default
title: OpenRiC mapping against RiC-AG
description: Row-by-row comparison of the OpenRiC mapping with the RiC-AG crosswalk from ISAD(G), ISAAR(CPF), ISDIAH and ISDF to RiC-CM, checked against RiC-O 1.1.
kind: record
---

# OpenRiC mapping against RiC-AG, row by row

Carried out on 15 October 2026 for plan V4, S1.4. The [mapping](../spec/mapping.html) said its tables were meant to agree with RiC-AG's crosswalk but had never been compared with it row by row; this is that comparison.

## Method

- **RiC-AG side:** the spreadsheet `crosswalk--ica_standards_to_ric-cm.xlsx` published with [RiC-AG 0.1](https://ica-egad.github.io/RiC-AG/mappings.html) (ICA EGAD, October 2025). For each element of ISAD(G), ISAAR(CPF), ISDIAH and ISDF, every RiC-CM attribute and relation it lists was taken as an acceptable target.
- **OpenRiC side:** the element tables in [mapping §7](../spec/mapping.html) at spec v0.44.1.
- **The bridge:** RiC-AG maps to the conceptual model (RiC-CM); OpenRiC maps to the ontology (RiC-O). RiC-O names most terms after RiC-CM (the attribute *Scope and Content* is `rico:scopeAndContent`), so a row agrees when OpenRiC's `rico:` term is the RiC-O form of one of RiC-AG's options. Every term named below was checked against the published [RiC-O 1.1 ontology](https://github.com/ICA-EGAD/RiC-O) (version 1.1, 2025-05-22), not from memory.
- **Review:** rows that did not match by name were read and judged one by one; the reasons are in the Note column.

| Verdict | Meaning |
|---|---|
| Agrees | OpenRiC uses the RiC-O form of an option RiC-AG gives. |
| Agrees, less specific | Same meaning, but a broader property or class than RiC-O offers. |
| Differs | OpenRiC uses a different property, or a different reading of the element. |
| Extension where RiC-O has a property | OpenRiC uses an `openricx:` term although RiC-O 1.1 defines one. This breaks OpenRiC's own rule of minting extension terms only where RiC-O has none. |
| Extension | OpenRiC uses an `openricx:` term and RiC-O 1.1 has no direct equivalent; usually a note where RiC-AG models an activity or a relation. |
| Not mapped by OpenRiC | The mapping has no row for the element. |

## Results

Of the 107 elements in RiC-AG's crosswalk, the mapping covers 55: 22 agree, 4 agree but less specifically, 9 differ, 16 use extensions where RiC-O has no equivalent, 3 use extensions where RiC-O does have one, and 1 is misnumbered. It has no row for the other 52, including all 23 ISDF elements: functions are mapped at class level only (§6.4).

## Findings

- **F-1. Extension terms where RiC-O 1.1 has a property.** `rico:scopeAndContent` (ISAD(G) 3.3.1), `rico:accruals` (3.3.3) and `rico:structure` (3.3.4) exist, and so does `rico:generalDescription` (3.6.1, mapped to `rdfs:comment`). The April 2026 RiC-O 1.1 audit renamed `rico:description` and `rico:arrangement`, which do not exist, to `openricx:` terms without noticing these. `openricx:accrualsNote`, added in v0.44.0, was never emitted and is deprecated in favour of `rico:accruals` in this release. The other three change emitted data and need a deprecation period (mapping O-8).
- **F-2. Immediate source of acquisition (ISAD(G) 3.2.4).** `rico:hasOrganicProvenance` names the creator or accumulator. RiC-AG models acquisition as an Activity with its participant. The April audit chose `hasOrganicProvenance` with medium confidence; this comparison says it should be revisited (mapping O-8).
- **F-3. Dates.** RiC-AG and RiC-O 1.1 use `hasCreationDate`, `hasBeginningDate`, `hasEndDate`, `hasBirthDate`, `hasDeathDate` to a Date. OpenRiC's `openricx:hasDateRangeSet` is a deliberate API shape (Provenance & Event Q4); it should also say how it expands to the RiC-O properties.
- **F-4. Physical characteristics (ISAD(G) 3.4.4).** RiC-AG and RiC-O 1.1 use `physicalCharacteristicsNote` on the Instantiation; OpenRiC's `rico:hasCarrierType` describes the carrier, not its condition.
- **F-5. Rules or conventions (ISAD(G) 3.7.2).** RiC-O 1.1 has `rico:isOrWasRegulatedBy`; OpenRiC uses `dcterms:conformsTo`.
- **F-6. Level of description.** RiC-AG uses Record Set Type (`rico:hasRecordSetType`) as well as the class; OpenRiC only chooses the class.
- **F-7. ISDIAH numbering.** Type of institution is ISDIAH 5.1.5, not 5.1.4. Corrected in the mapping and the extension ontology in this release.

**Follow-up, 15 October 2026:** the mapping was corrected for F-1 to F-6 and gained rows for the control areas and ISDF ([mapping](../spec/mapping.html) §7, O-8). The table below is the state before that correction, kept as the record.

The remaining extensions are mostly places where RiC-AG models something as an activity or relation and OpenRiC keeps a text note. They are recorded so a future profile can choose the richer form.

## Row by row

### ISAD(G)

| Element | RiC-AG (RiC-CM) | OpenRiC mapping (RiC-O) | Verdict | Note |
|---|---|---|---|---|
| 3.1.1 Reference code(s) | attr: Identifier | `rico:identifier` | Agrees |  |
| 3.1.2 Title | attr: Name | `rico:title` | Agrees | RiC-AG gives the RiC-CM attribute Name; RiC-O 1.1 has the more specific `rico:title` for record resources. |
| 3.1.3 Dates | rel: has beginning date; rel: has creation date; rel: has end date; rel: has modification date ... | `openricx:hasDateRangeSet` → `openricx:DateRange` | Differs | RiC-AG links to a Date entity through `has creation date`, `has beginning date` and similar. OpenRiC wraps dates in `openricx:hasDateRangeSet`; RiC-O 1.1 has `rico:hasCreationDate`, `rico:hasBeginningDate`, `rico:hasEndDate` and `rico:isAssociatedWithDate` for this. (F-3) |
| 3.1.4 Level of description | attr: Record Set Type | *(drives class, see §6.1)* | Differs | RiC-AG maps level of description to the Record Set Type attribute (`rico:hasRecordSetType`); OpenRiC only chooses the class (RecordSet, Record, RecordPart). RiC-AG §5.3.1 discusses both readings. (F-6) |
| 3.1.5 Extent and medium of the unit | attr: Carrier Extent | `rico:hasExtent` → `rico:Extent` with `rico:hasExtentType` | Agrees, less specific | RiC-AG gives the RiC-CM attribute Carrier Extent; OpenRiC uses `rico:hasExtent` to a `rico:Extent` without the subclass. RiC-O 1.1 has `rico:CarrierExtent` and `rico:RecordResourceExtent`. |
| 3.2.1 Name of creator | attr: Name; rel: has accumulator; rel: has creator; rel: has provenance | `rico:hasCreator` → `rico:Agent` | Agrees |  |
| 3.2.2 Administrative/Biographical history | attr: History; rel: has creator; rel: is or was affected by | `rico:history` | Agrees |  |
| 3.2.3 Archival history | attr: History; rel: is or was affected by | `rico:history` on the Record | Agrees |  |
| 3.2.4 Immediate source of acquisition | attr: Activity Type; attr: EventType; attr: History; rel: has or had participant ... | `rico:hasOrganicProvenance` → `rico:Agent` | Differs | RiC-AG models the immediate source of acquisition as an Activity (an acquisition, with its participant). OpenRiC uses `rico:hasOrganicProvenance`, which in RiC-O 1.1 means the creator or accumulator, not the agent the material was acquired from. (F-2) |
| 3.3.1 Scope and content | attr: Scope and Content | `openricx:description` | Extension where RiC-O has a property | RiC-O 1.1 defines `rico:scopeAndContent`, the RiC-CM attribute RiC-AG names. OpenRiC emits `openricx:description`. (F-1) |
| 3.3.2 Appraisal, destruction and scheduling | attr: Activity Type; attr: History; rel: is or was affected by; rel: is or was regulated by | `openricx:hasAppraisalInformation` | Extension | RiC-AG models appraisal as an Activity affecting the record. OpenRiC keeps a note, `openricx:hasAppraisalInformation`. |
| 3.3.3 Accruals | attr: Accruals | `openricx:accrualsNote` | Extension where RiC-O has a property | RiC-O 1.1 defines `rico:accruals`. OpenRiC v0.44.0 named `openricx:accrualsNote`, saying RiC-O had no property; that was wrong. Never emitted. (F-1) |
| 3.3.4 System of arrangement | attr: Structure | `openricx:arrangement` | Extension where RiC-O has a property | RiC-AG gives the RiC-CM attribute Structure, which RiC-O 1.1 defines as `rico:structure`. OpenRiC emits `openricx:arrangement`. (F-1) |
| 3.4.1 Conditions governing access | attr: Conditions of Access; attr: Rule Type; rel: is or was regulated by | `rico:conditionsOfAccess` | Agrees |  |
| 3.4.2 Conditions governing reproduction | attr: Conditions of Use; attr: Rule Type; rel: is or was regulated by | `rico:conditionsOfUse` | Agrees |  |
| 3.4.3 Language/scripts of material | attr: Language | `rico:hasOrHadLanguage` → ISO 639-3 code on a record; `rico:hasOrHadAllMembersWithLanguage` / `rico:hasOrHadSomeMembersWithLanguage` on a record set (from v0.50.0) | Agrees | RiC-AG gives the Language attribute; RiC-O 1.1 expresses it as `rico:hasOrHadLanguage` to a `rico:Language`, but only for Agent, Record and RecordPart. Before v0.50.0 OpenRiC also sent it on record sets, outside that domain. |
| 3.4.4 Physical characteristics and technical requirements | attr: Conditions of Access | `rico:hasCarrierType` | Differs | RiC-AG maps physical characteristics to the Instantiation attribute Physical Characteristics (`rico:physicalCharacteristicsNote` in RiC-O 1.1). OpenRiC uses `rico:hasCarrierType`, which is the carrier, not its condition. (F-4) |
| 3.4.5 Finding aids | rel: is or was described by | `rico:isOrWasDescribedBy` → finding-aid Record (which carries `rico:hasDocumentaryFormType <https://www.ica.org/standards/RiC/vocabularies/documentaryFormTypes#FindingAid>`) | Agrees | Corrected in v0.50.0: the IRI was given as `ontology#FindingAid`, which does not exist. |
| 3.5.1 Existence and location of originals | rel: has genetic link to record resource; rel: has or had holder; rel: has original | `rico:hasOrHadLocation` | Differs | RiC-AG uses `has original` and `has or had holder`. OpenRiC uses `rico:hasOrHadLocation`, a place rather than the originals themselves. |
| 3.5.2 Existence and location of copies | rel: has copy; rel: has or had derived instantiation; rel: has or had holder; rel: migrated into | `rico:hasOrHadInstantiation` | Agrees, less specific | RiC-AG uses `has copy` and `has or had derived instantiation`; OpenRiC uses `rico:hasOrHadInstantiation`, the broader property. |
| 3.5.3 Related units of description | rel: has genetic link to record resource; rel: is record resource associated with record resource; rel: is related to | `rico:isRelatedTo` | Agrees |  |
| 3.5.4 Publication note | rel: is or was described by; rel: is or was main subject of; rel: is or was subject of | `openricx:publicationInformation` | Extension | RiC-AG relates the record to the publication (`is or was described by`, `is or was subject of`). OpenRiC keeps a note, `openricx:publicationInformation`. |
| 3.6.1 Note | attr: General Description | `rdfs:comment` | Differs | RiC-AG gives General Description, which RiC-O 1.1 defines as `rico:generalDescription`. OpenRiC uses `rdfs:comment`. (F-1) |
| 3.7.1 Archivist's note | attr: General Description; rel: is or was described by; rel: results or resulted from | `openricx:descriptiveNote` | Extension | RiC-AG gives General Description or a describing record. OpenRiC keeps `openricx:descriptiveNote`. |
| 3.7.2 Rules or conventions | rel: is or was regulated by; rel: results or resulted from | `dcterms:conformsTo` → `rico:Rule` | Differs | RiC-AG uses `is or was regulated by` a Rule (`rico:isOrWasRegulatedBy`). OpenRiC uses `dcterms:conformsTo`. (F-5) |
| 3.7.3 Date(s) of descriptions | rel: has beginning date; rel: has end date; rel: results or resulted from | `openricx:hasDateRangeSet` (descriptive) | Extension | RiC-AG dates the describing activity. OpenRiC keeps a descriptive date range set. |

### ISAAR(CPF)

| Element | RiC-AG (RiC-CM) | OpenRiC mapping (RiC-O) | Verdict | Note |
|---|---|---|---|---|
| 5.1.1 Type of entity | entity: Corporate Body, Family, Person | - | Not mapped by OpenRiC |  |
| 5.1.2 Authorized form(s) of name | attr: Name | `rico:name`, also `openricx:normalizedForm` | Agrees |  |
| 5.1.3 Parallel forms of name | - | `openricx:alternativeForm` | Extension | RiC-AG gives no RiC-CM element for parallel forms; OpenRiC keeps `openricx:alternativeForm`. RiC-O 1.1 also offers `rico:hasOrHadAgentName` to an `rico:AgentName`. |
| 5.1.4 Standardized forms of name according to other rules | - | `openricx:alternativeForm` | Extension | As 5.1.3. |
| 5.1.5 Other forms of name | - | `openricx:otherName` | Extension | As 5.1.3. |
| 5.1.6 Identifiers for corporate bodies | attr: Identifier | `rico:identifier` | Agrees |  |
| 5.2.1 Dates of existence | attr: Date; rel: has birth date; rel: has death date; rel: is beginning date of ... | `openricx:hasDateRangeSet` with `dateType=existence` | Differs | RiC-AG uses `has birth date` and `has death date` (persons) and beginning and end dates; RiC-O 1.1 has `rico:hasBirthDate`, `rico:hasDeathDate`, `rico:hasBeginningDate`, `rico:hasEndDate`. OpenRiC uses `openricx:hasDateRangeSet`. (F-3) |
| 5.2.2 History | attr: Event; attr: History; rel: is or was affected by | `rico:history` | Agrees |  |
| 5.2.3 Places | attr: Place; rel: has or had jurisdiction; rel: has or had location; rel: is associated with place | `rico:isAssociatedWithPlace` → `rico:Place` | Agrees |  |
| 5.2.4 Legal Status | attr: Corporate Body Type; attr: Legal Status | `rico:hasOrHadLegalStatus` → `rico:LegalStatus` node with `rico:name` (from v0.50.0) | Agrees | RiC-AG gives the Legal Status attribute; RiC-O 1.1 expresses it as the object property `rico:hasOrHadLegalStatus`, so its value is a `rico:LegalStatus`, not a string as OpenRiC had it before v0.50.0. |
| 5.2.5 Functions, occupations and activities | attr: Activity; attr: Occupation Type; rel: performs or performed | `rico:performsOrPerformed` → `openricx:Function` (interim, see §6.4); `openricx:hasOccupation` → SKOS Concept of `rico:OccupationType` (RiC-O 1.1 has no direct `Agent → OccupationType` linking property - Aaron+Florence in RiC user group #20 endorse SKOS individuals of `OccupationType`; canonical RDF expansion: an `Activity` typed by an OccupationType IRI per §6.5) | Agrees |  |
| 5.2.6 Mandates/Sources of authority | attr: Mandate; rel: authorized by | `rico:authorizingMandate` → `rico:Mandate` | Agrees | RiC-AG uses `authorized by` a Mandate; OpenRiC uses `rico:authorizingMandate`, which RiC-O 1.1 defines for the same link. |
| 5.2.7 Internal structures/Genealogy | attr: General Description; attr: Group; rel: has or had subdivision | `openricx:hasInternalStructure` | Extension | RiC-AG gives General Description or `has or had subdivision`. OpenRiC keeps `openricx:hasInternalStructure`. |
| 5.2.8 General context | attr: Event; attr: General Description; rel: is associated with event | `openricx:generalContext` | Extension | RiC-AG gives General Description or `is associated with event`. OpenRiC keeps `openricx:generalContext`. |
| 5.3.1 Identifiers of related corporate bodies, persons or families | attr: Agent; rel: follows in time; rel: has ancestor; rel: has child ... | - | Not mapped by OpenRiC |  |
| 5.3.2 Category of relationship | attr: Agent; rel: has or had controller; rel: has or had subordinate; rel: has or had work relation with ... | - | Not mapped by OpenRiC |  |
| 5.3.3 Description of relationship | attr: Agent; rel: has or had controller; rel: has or had subordinate; rel: has or had work relation with ... | - | Not mapped by OpenRiC |  |
| 5.3.4 Dates of the relationship | attr: Agent; rel: has or had controller; rel: has or had subordinate; rel: has or had work relation with ... | - | Not mapped by OpenRiC |  |
| 5.4.1 Authority record identifier | attr: Agent; attr: Identifier; rel: describes or described | - | Not mapped by OpenRiC |  |
| 5.4.2 Institution identifiers | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.3 Rules and/or conventions | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.4 Status | attr: State | - | Not mapped by OpenRiC |  |
| 5.4.5 Level of detail | attr: General Description | - | Not mapped by OpenRiC |  |
| 5.4.6 Dates of creation, revision or deletion | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.7 Language(s) and script(s) | attr: Language | - | Not mapped by OpenRiC |  |
| 5.4.8 Sources | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.9 Maintenance notes | attr: Activity; attr: Record Resource; rel: has or had authority over; rel: is accumulator of ... | - | Not mapped by OpenRiC |  |

### ISDIAH

| Element | RiC-AG (RiC-CM) | OpenRiC mapping (RiC-O) | Verdict | Note |
|---|---|---|---|---|
| 5.1.1 Identifier | attr: Identifier | - | Not mapped by OpenRiC |  |
| 5.1.2 Authorised form(s) of name | attr: Name | `rico:name` | Agrees |  |
| 5.1.3 Parallel form(s) of name | entity: Group | `openricx:alternativeForm`, `openricx:otherName` | Extension | RiC-AG gives no RiC-CM element. OpenRiC keeps name-form extensions. |
| 5.1.4 Other form(s) of name | entity: Corporate Body, Family | `openricx:institutionType` | Numbering error | OpenRiC lists Institution type under 5.1.4; in ISDIAH that is Other form(s) of name, and Type of institution is 5.1.5. (F-7) |
| 5.1.5 Type of institution with archival holdings | attr: Demographic Group; attr: Legal Status | - | Not mapped by OpenRiC |  |
| 5.2.1 Location and address(es) | attr: Location; rel: has or had location | `rico:isAssociatedWithPlace` → `rico:Place` with `openricx:streetAddress` | Differs | RiC-AG uses the Location attribute or `has or had location`. OpenRiC uses `rico:isAssociatedWithPlace`. |
| 5.2.2 Telephone, fax, email | entity: Corporate Body, Family, Group | `openricx:contact` → `openricx:ContactPoint` | Extension | RiC-AG gives no RiC-CM element. OpenRiC keeps `openricx:contact`. |
| 5.2.3 Contact persons | attr: Name; rel: had or has position | - | Not mapped by OpenRiC |  |
| 5.3.1 History of the institution with archival holdings | attr: History | `rico:history` | Agrees |  |
| 5.3.2 Geographical and cultural context | rel: is associated with place | `openricx:generalContext` | Extension | RiC-AG uses `is associated with place`. OpenRiC keeps `openricx:generalContext`. |
| 5.3.3 Mandates/Sources of authority | rel: authorized by | `rico:authorizingMandate` | Agrees | As ISAAR(CPF) 5.2.6. |
| 5.3.4 Administrative structure | attr: General Description | `openricx:hasInternalStructure` | Extension | RiC-AG gives General Description. OpenRiC keeps `openricx:hasInternalStructure`. |
| 5.3.5 Records management and collecting policies | rel: is or was regulated by | `openricx:hasOrHadPolicy` | Extension | RiC-AG uses `is or was regulated by` a Rule. OpenRiC keeps `openricx:hasOrHadPolicy`. |
| 5.3.6 Building(s) | attr: General Description; rel: has or had location | `rico:hasOrHadLocation` | Agrees |  |
| 5.3.7 Archival and other holdings | attr: General Description | `rico:isOrWasHolderOf` → `rico:RecordSet` / `rico:Record` | Agrees, less specific | RiC-AG gives General Description; OpenRiC links the holdings themselves with `rico:isOrWasHolderOf`, which RiC-O 1.1 defines. |
| 5.3.8 Finding aids, guides and publications | rel: is or was described by | `rico:isOrWasDescribedBy` → finding-aid Record with `rico:hasDocumentaryFormType <…#FindingAid>` | Agrees |  |
| 5.4.1 Opening times | attr: General Description; rel: Rule; rel: performs or performed | `openricx:openingHours` | Extension | RiC-AG gives General Description or a Rule. OpenRiC keeps `openricx:openingHours`. |
| 5.4.2 Conditions and requirements for access and use | attr: Rule Type; rel: is or was regulated by | `rico:conditionsOfAccess` | Agrees, less specific | RiC-AG uses a Rule (`is or was regulated by`); OpenRiC uses `rico:conditionsOfAccess`, the RiC-O 1.1 text property. |
| 5.4.3 Accessibility | attr: Rule Type; rel: is or was regulated by | `openricx:accessibility` | Extension | RiC-AG uses a Rule. OpenRiC keeps `openricx:accessibility`. |
| 5.5.1 Research services | rel: performs or performed | - | Not mapped by OpenRiC |  |
| 5.5.2 Reproduction service | entity: Corporate Body, Family, Group | - | Not mapped by OpenRiC |  |
| 5.5.3 Public areas | attr: General Description; rel: has or had location | - | Not mapped by OpenRiC |  |
| 5.6.1 Description identifier | attr: Agent; attr: Identifier; rel: describes or described | - | Not mapped by OpenRiC |  |
| 5.6.2 Institution identifier | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.6.3 Rules and/or conventions used | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.6.4 Status | attr: State | - | Not mapped by OpenRiC |  |
| 5.6.5 Level of detail | attr: General Description | - | Not mapped by OpenRiC |  |
| 5.6.6 Dates of creation, revision or deletion | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.6.7 Language(s) and script(s) | attr: Language | - | Not mapped by OpenRiC |  |
| 5.6.8 Sources | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.6.9 Maintenance notes | attr: Activity; attr: Date; attr: Description; attr: Identifier ... | - | Not mapped by OpenRiC |  |

### ISDF

| Element | RiC-AG (RiC-CM) | OpenRiC mapping (RiC-O) | Verdict | Note |
|---|---|---|---|---|
| 5.1.1 Type | attr: Activity Type | - | Not mapped by OpenRiC |  |
| 5.1.2 Authorised form(s) of name | attr: Name | - | Not mapped by OpenRiC |  |
| 5.1.3 Parallel form(s) of name | entity: Activity | - | Not mapped by OpenRiC |  |
| 5.1.4 Other form(s) of name | entity: Activity | - | Not mapped by OpenRiC |  |
| 5.1.5 Classification | attr: Activity Type | - | Not mapped by OpenRiC |  |
| 5.2.1 Dates | attr: Date; rel: has beginning date; rel: has end date; rel: has modification date ... | - | Not mapped by OpenRiC |  |
| 5.2.2 Description | attr: General Description | - | Not mapped by OpenRiC |  |
| 5.2.3 History | attr: Event; attr: History; rel: is or was affected by | - | Not mapped by OpenRiC |  |
| 5.2.4 Legislation | attr: Rule; rel: is or was regulated by | - | Not mapped by OpenRiC |  |
| 5.3.1 Authorised form(s) of name/ | attr: Activity | - | Not mapped by OpenRiC |  |
| 5.3.2 Type | attr: Activity | - | Not mapped by OpenRiC |  |
| 5.3.3 Category of relationship | attr: Activity; rel: is related to | - | Not mapped by OpenRiC |  |
| 5.3.4 Description of relationship | rel: affects or affected; rel: follows in time; rel: follows or followed; rel: has or had part ... | - | Not mapped by OpenRiC |  |
| 5.3.5 Dates of relationship | attr: Activity; rel: affects or affected; rel: follows in time; rel: follows or followed ... | - | Not mapped by OpenRiC |  |
| 5.4.1 Function description identifier | attr: Activity; attr: Identifier; rel: describes or described | - | Not mapped by OpenRiC |  |
| 5.4.2 Institution identifiers | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.3 Rules and/or conventions used | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.4 Status | attr: State | - | Not mapped by OpenRiC |  |
| 5.4.5 Level of detail | attr: General Description | - | Not mapped by OpenRiC |  |
| 5.4.6 Dates of creation, revision or deletion | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.7 Language(s) and script(s) | attr: Language | - | Not mapped by OpenRiC |  |
| 5.4.8 Sources | attr: Activity; rel: results or resulted from | - | Not mapped by OpenRiC |  |
| 5.4.9 Maintenance notes | attr: Activity; attr: Agent; attr: Record Resource; rel: documented by ... | - | Not mapped by OpenRiC |  |
