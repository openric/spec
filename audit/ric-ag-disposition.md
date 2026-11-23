---
layout: default
title: RiC-AG disposition table
description: Each of the 107 ICA-standard elements in the RiC-AG 0.1 crosswalk, with OpenRiC's current mapping, how it is classified and why. A first pass, with what is unresolved left open.
kind: record
---

# RiC-AG disposition table

**Status: first pass, 23 November 2026.** Not yet reviewed by anyone outside the project. It compares the [OpenRiC mapping](../spec/mapping.html) at spec v0.60.2 with the crosswalk published with [RiC-AG 0.1](https://ica-egad.github.io/RiC-AG/mappings.html) (ICA-EGAD, October 2025). RiC-AG is draft guidance and not a test, so this table is not a claim of conformance. Download it as [CSV](ric-ag-disposition.csv).

It replaces the figure of "55 of 107 mapped" from the [comparison of 15 October 2026](ric-ag-crosswalk-comparison.html), which records the mapping as it stood before that day's corrections.

## The result

| Classification | Elements | Meaning |
|---|---|---|
| Mapped | 62 | OpenRiC uses the RiC-O form of an option RiC-AG gives, or of the same reading. |
| Mapped, broader | 4 | Same meaning, through a broader property than RiC-AG offers. |
| Extension | 13 | An `openricx:` term or API shape, with a stated reason. |
| Unresolved | 28 | A defect, a choice that departs from RiC-AG without a written reason, or an element the mapping does not place. |
| Deliberately outside scope | 0 | None is declared yet. That is a decision for the project, row by row. |

"Mapped" means the terms exist in RiC-O 1.1 and each was tested against the property's domain in the ontology file. It describes the specification's mapping. Whether a given implementation emits each element is a separate question, answered only where a defect below says so.

The ISDF rows carry one caveat throughout: OpenRiC serves a function as the interim class `openricx:Function`, where RiC-AG maps ISDF to `rico:Activity` ([mapping 6.4](../spec/mapping.html)).

## Defects found

- **D-1. Conditions of access on a repository (ISDIAH 5.4.2).** `rico:conditionsOfAccess` applies to a Record Resource or Instantiation. The mapping puts it on a repository, and both the OpenRiC Workspace and the reference service emit it there.
- **D-2. Classification of a function (ISDF 5.1.5).** `rico:classification` applies to a Record Resource. The mapping puts it on a function, and the Workspace emits it on an activity.
- **D-3. Mandates (ISAAR(CPF) 5.2.6, ISDIAH 5.3.3).** The mapping points `rico:authorizingMandate` at a `rico:Mandate`, but it is a text property. The link to a Mandate is `rico:authorizedBy`.
- **D-4. Status (ISAAR(CPF) 5.4.4, ISDIAH 5.6.4, ISDF 5.4.4).** The mapping says RiC-O 1.1 has no property for it. It has `rico:hasRecordState`.
- **D-5. Contact persons (ISDIAH 5.2.3).** The mapping reads as `rico:hasOrHadPosition` on a Person. That property runs from a Group to a Position.

## Where RiC-AG bears on our own wording

RiC-AG's [digitisation example](https://ica-egad.github.io/RiC-AG/faq--how_to_describe_activities_such_as_digitization_appraisal_or_disposition.html) has an Activity resulting in an Instantiation, the pattern Provenance and Event profile 0.9.0 now accepts. Its [instantiation FAQ](https://ica-egad.github.io/RiC-AG/faq--the_instantiation_entity.html) is more careful than we were on one point: whether a derived copy is a new record depends on context, and transcription is an in-between case. The profile's design decision Q6 and worked example 2 state the survey photographs' case too generally, and should say this was a judgement for this collection.

## ISAD(G)

26 elements: 18 mapped, 1 mapped more broadly, 2 extensions, 5 unresolved.

| Element | RiC-AG 0.1 (RiC-CM) | OpenRiC mapping | Classification | Rationale |
|---|---|---|---|---|
| 3.1.1 Reference code(s) | attr: Identifier | rico:identifier | Mapped |  |
| 3.1.2 Title | attr: Name | rico:title | Mapped | RiC-O has the specific title property for RiC-CM Name. |
| 3.1.3 Dates | rel: has beginning date; rel: has creation date; rel: has end date; rel: has modification date; rel: has or had all members with creation date date; rel: has or had most members with creation date; rel: has or had some members with creation date; rel: is associated with date | openricx:hasDateRangeSet, expanding in RDF to rico:hasCreationDate, hasBeginningDate, hasEndDate | Extension | A deliberate API shape (Provenance and Event Q4) with a stated expansion to RiC-O. |
| 3.1.4 Level of description | attr: Record Set Type | Level drives the class; rico:hasRecordSetType on a RecordSet | Unresolved | The record set type agrees. A level deciding the class is a migration convention; RiC-AG treats Record, Record Set and Record Part as a contextual judgement. |
| 3.1.5 Extent and medium of the unit | attr: Carrier Extent; attr: Carrier Type; attr: Instantiation Extent; attr: Physical Characteristics Note; attr: Structure | rico:hasExtent to rico:RecordResourceExtent | Mapped |  |
| 3.2.1 Name of creator | attr: Name; rel: has accumulator; rel: has creator; rel: has provenance | rico:hasCreator | Mapped |  |
| 3.2.2 Administrative/Biographical history | attr: History; rel: has creator; rel: is or was affected by | rico:history on the Agent | Mapped |  |
| 3.2.3 Archival history | attr: History; rel: is or was affected by | rico:history on the Record | Mapped |  |
| 3.2.4 Immediate source of acquisition | attr: Activity Type; attr: EventType; attr: History; rel: has or had participant; rel: is or was affected by; rel: is or was performed by; rel: results or resulted from | rico:isOrWasAffectedBy to a transfer Activity, with rico:hasOrHadParticipant | Mapped | Follows RiC-AG since v0.46.0. |
| 3.3.1 Scope and content | attr: Scope and Content | rico:scopeAndContent | Mapped |  |
| 3.3.2 Appraisal, destruction and scheduling | attr: Activity Type; attr: History; rel: is or was affected by; rel: is or was regulated by | openricx:hasAppraisalInformation | Unresolved | RiC-AG models appraisal as an Activity affecting the record, regulated by a Rule. RiC-O can say this, so the text note needs a reason or an activity form. |
| 3.3.3 Accruals | attr: Accruals | rico:accruals | Mapped |  |
| 3.3.4 System of arrangement | attr: Structure | rico:structure | Mapped |  |
| 3.4.1 Conditions governing access | attr: Conditions of Access; attr: Rule Type; rel: is or was regulated by | rico:conditionsOfAccess | Mapped |  |
| 3.4.2 Conditions governing reproduction | attr: Conditions of Use; attr: Rule Type; rel: is or was regulated by | rico:conditionsOfUse | Mapped |  |
| 3.4.3 Language/scripts of material | attr: Language | rico:hasOrHadLanguage on a Record or Record Part; the members forms on a Record Set | Mapped |  |
| 3.4.4 Physical characteristics and technical requirements | attr: Conditions of Access; attr: Physical Characteristics | rico:physicalCharacteristicsNote on the Instantiation | Mapped |  |
| 3.4.5 Finding aids | rel: is or was described by | rico:isOrWasDescribedBy to a finding-aid Record | Mapped |  |
| 3.5.1 Existence and location of originals | rel: has genetic link to record resource; rel: has or had holder; rel: has original | rico:hasOrHadLocation | Unresolved | RiC-AG uses has original and has or had holder. A place does not identify the originals. |
| 3.5.2 Existence and location of copies | rel: has copy; rel: has or had derived instantiation; rel: has or had holder; rel: migrated into | rico:hasOrHadInstantiation | Mapped, broader | RiC-AG offers has copy and has or had derived instantiation. |
| 3.5.3 Related units of description | rel: has genetic link to record resource; rel: is record resource associated with record resource; rel: is related to | rico:isRelatedTo | Mapped |  |
| 3.5.4 Publication note | rel: is or was described by; rel: is or was main subject of; rel: is or was subject of | openricx:publicationInformation | Unresolved | RiC-AG relates the record to the publication. RiC-O can say this; the note needs a reason or a relation form. |
| 3.6.1 Note | attr: General Description | rico:generalDescription | Mapped |  |
| 3.7.1 Archivist's note | attr: General Description; rel: is or was described by; rel: results or resulted from | openricx:descriptiveNote | Unresolved | RiC-AG gives General Description, which RiC-O has: OpenRiC mints extensions only where RiC-O has none. |
| 3.7.2 Rules or conventions | rel: is or was regulated by; rel: results or resulted from | rico:isOrWasRegulatedBy to a rico:Rule | Mapped |  |
| 3.7.3 Date(s) of descriptions | rel: has beginning date; rel: has end date; rel: results or resulted from | openricx:hasDateRangeSet (descriptive) | Extension | The same API shape as 3.1.3, for the description rule set. |

## ISAAR(CPF)

27 elements: 14 mapped, 1 mapped more broadly, 6 extensions, 6 unresolved.

| Element | RiC-AG 0.1 (RiC-CM) | OpenRiC mapping | Classification | Rationale |
|---|---|---|---|---|
| 5.1.1 Type of entity | entity: Corporate Body, Family, Person | Drives the class: rico:Person, CorporateBody or Family | Mapped |  |
| 5.1.2 Authorized form(s) of name | attr: Name | rico:name, also openricx:normalizedForm | Mapped |  |
| 5.1.3 Parallel forms of name | attr: Name (the crosswalk leaves the attribute blank here; read as continuing the authorised form above it) | openricx:alternativeForm | Extension | The extension term is the plain form; since v0.58.0 the name MAY also go out as a rico:AgentName node, the RiC-O form. |
| 5.1.4 Standardized forms of name according to other rules | attr: Name (the crosswalk leaves the attribute blank here; read as continuing the authorised form above it) | openricx:alternativeForm | Extension | The extension term is the plain form; since v0.58.0 the name MAY also go out as a rico:AgentName node, the RiC-O form. |
| 5.1.5 Other forms of name | attr: Name (the crosswalk leaves the attribute blank here; read as continuing the authorised form above it) | openricx:otherName | Extension | The extension term is the plain form; since v0.58.0 the name MAY also go out as a rico:AgentName node, the RiC-O form. |
| 5.1.6 Identifiers for corporate bodies | attr: Identifier | rico:identifier | Mapped |  |
| 5.2.1 Dates of existence | attr: Expressed Date; rel: has birth date; rel: has death date; rel: is beginning date of; rel: is end date of | openricx:hasDateRangeSet (existence), expanding in RDF to the RiC-O date properties | Extension | The API shape of ISAD(G) 3.1.3. |
| 5.2.2 History | attr: History; rel: is or was affected by | rico:history | Mapped |  |
| 5.2.3 Places | attr: Date; attr: Description; attr: Place Type Name; rel: has or had jurisdiction; rel: has or had location; rel: is associated with place | rico:isAssociatedWithPlace | Mapped |  |
| 5.2.4 Legal Status | attr: Corporate Body Type; attr: Legal Status | rico:hasOrHadLegalStatus | Mapped |  |
| 5.2.5 Functions, occupations and activities | attr: Activity Type; attr: Date; attr: Description; attr: Occupation Type; rel: performs or performed | rico:performsOrPerformed to openricx:Function; rico:hasOrHadOccupationOfType for a person | Extension | RiC-AG targets an Activity; the interim openricx:Function class falls outside the property range (mapping 6.4). |
| 5.2.6 Mandates/Sources of authority | attr: Date; attr: Description; attr: Mandate Type; rel: authorized by | rico:authorizingMandate to a rico:Mandate | Unresolved | Defect (D-3): rico:authorizingMandate is a text property. The link to a Mandate is rico:authorizedBy, as RiC-AG has it. |
| 5.2.7 Internal structures/Genealogy | attr: Date; attr: Description; attr: General Description; rel: has or had subdivision | openricx:hasInternalStructure | Unresolved | RiC-AG gives General Description and has or had subdivision, both in RiC-O. |
| 5.2.8 General context | attr: Date; attr: Description; attr: General Description; rel: is associated with event | openricx:generalContext | Unresolved | RiC-AG gives General Description and is associated with event, both in RiC-O. |
| 5.3.1 Identifiers of related corporate bodies, persons or families | attr: Identifier; attr: Name; rel: follows in time; rel: has ancestor; rel: has child; rel: has descendant; rel: has family association with; rel: has or had controller; rel: has or had correspondent; rel: has or had leader; rel: has or had member; rel: has or had spouse; rel: has or had student; rel: has or had subordinate; rel: has or had teacher; rel: has or had work relation with; rel: has sibling; rel: has successor; rel: is agent associated with agent; rel: is child of; rel: is or was controller of; rel: is or was leader of; rel: is or was member of; rel: is or was subordinate to; rel: is successor of; rel: known by; rel: knows; rel: knows of; rel: precedes in time | The target of a relation property (section 8) | Mapped | Section 8 gives the commonest relations and a qualified node; there is no element-level row. |
| 5.3.2 Category of relationship | rel: has or had controller; rel: has or had subordinate; rel: has or had work relation with; rel: has successor; rel: is agent associated with agent; rel: is or was controller of; rel: is or was subordinate to; rel: is successor of | The choice of relation property (section 8) | Mapped | Section 8 gives the commonest relations and a qualified node; there is no element-level row. |
| 5.3.3 Description of relationship | attr: Description; rel: has or had controller; rel: has or had subordinate; rel: has or had work relation with; rel: has successor; rel: is agent associated with agent; rel: is or was controller of; rel: is or was subordinate to; rel: is successor of | Not stated in section 8 | Unresolved | Section 8 does not say where a relation's description goes; RiC-O has rico:generalDescription on a Relation. |
| 5.3.4 Dates of the relationship | attr: Date; rel: has or had controller; rel: has or had subordinate; rel: has or had work relation with; rel: has successor; rel: is agent associated with agent; rel: is or was controller of; rel: is or was subordinate to; rel: is successor of | openricx:hasDateRangeSet on the qualified relation node | Extension | The API date shape on a rico:Relation. |
| 5.4.1 Authority record identifier | attr: Identifier; rel: describes or described | rico:identifier on the describing Record | Mapped |  |
| 5.4.2 Institution identifiers | attr: Identifier; rel: is or was performed by; rel: results or resulted from | The Record results from an Activity performed by the institution | Mapped |  |
| 5.4.3 Rules and/or conventions | rel: is or was regulated by; rel: results or resulted from | rico:isOrWasRegulatedBy to a rico:Rule | Mapped |  |
| 5.4.4 Status | attr: State | Text in rico:generalDescription ("no RiC-O 1.1 property") | Unresolved | Defect (D-4): RiC-O 1.1 has rico:hasRecordState, the RiC-CM State that RiC-AG names. |
| 5.4.5 Level of detail | attr: General Description | rico:generalDescription | Mapped |  |
| 5.4.6 Dates of creation, revision or deletion | rel: is or was performed by; rel: results or resulted from | rico:hasCreationDate and rico:hasModificationDate | Mapped |  |
| 5.4.7 Language(s) and script(s) | attr: Language | rico:hasOrHadLanguage | Mapped |  |
| 5.4.8 Sources | rel: is or was performed by; rel: results or resulted from | rico:generalDescription | Unresolved | RiC-O 1.1 has rico:recordResourceSourceOfInformation, more specific than a general note. |
| 5.4.9 Maintenance notes | rel: is or was performed by; rel: results or resulted from | rico:generalDescription | Mapped, broader | RiC-AG models maintenance as activities the record results from. |

## ISDIAH

31 elements: 16 mapped, 1 mapped more broadly, 3 extensions, 11 unresolved.

| Element | RiC-AG 0.1 (RiC-CM) | OpenRiC mapping | Classification | Rationale |
|---|---|---|---|---|
| 5.1.1 Identifier | attr: Identifier | rico:identifier | Mapped |  |
| 5.1.2 Authorised form(s) of name | attr: Name | rico:name | Mapped |  |
| 5.1.3 Parallel form(s) of name | attr: Name (the crosswalk leaves the attribute blank here; read as continuing the authorised form above it) | openricx:alternativeForm | Extension | The extension term is the plain form; since v0.58.0 the name MAY also go out as a rico:AgentName node, the RiC-O form. |
| 5.1.4 Other form(s) of name | attr: Name (the crosswalk leaves the attribute blank here; read as continuing the authorised form above it) | openricx:otherName | Extension | The extension term is the plain form; since v0.58.0 the name MAY also go out as a rico:AgentName node, the RiC-O form. |
| 5.1.5 Type of institution with archival holdings | attr: Corporate Body Type; attr: Demographic Group; attr: Family Type; attr: Legal Status; attr: Occupation Type | openricx:institutionType | Unresolved | RiC-AG gives Corporate Body Type; RiC-O 1.1 has rico:hasOrHadCorporateBodyType. |
| 5.2.1 Location and address(es) | attr: Location; rel: has or had location | rico:hasOrHadLocation to a rico:Place with openricx:streetAddress | Mapped | The street address is an extension on the Place. |
| 5.2.2 Telephone, fax, email | entity: Corporate Body, Family, Group | openricx:contact to openricx:ContactPoint | Extension | RiC-O 1.1 has no contact details. |
| 5.2.3 Contact persons | attr: Name; rel: had or has position | openricx:contact; a named person as rico:Person with rico:hasOrHadPosition | Unresolved | Defect (D-5): rico:hasOrHadPosition runs from a Group to a Position, so it cannot sit on a Person as the mapping reads. |
| 5.3.1 History of the institution with archival holdings | attr: History | rico:history | Mapped |  |
| 5.3.2 Geographical and cultural context | rel: is associated with place | openricx:generalContext | Unresolved | RiC-AG gives is associated with place, in RiC-O. |
| 5.3.3 Mandates/Sources of authority | rel: authorized by | rico:authorizingMandate | Unresolved | Defect (D-3), as ISAAR(CPF) 5.2.6: the link to a Mandate is rico:authorizedBy. |
| 5.3.4 Administrative structure | attr: General Description | openricx:hasInternalStructure | Unresolved | RiC-AG gives General Description, in RiC-O. |
| 5.3.5 Records management and collecting policies | rel: is or was regulated by | openricx:hasOrHadPolicy | Unresolved | RiC-AG gives is or was regulated by a Rule, in RiC-O. |
| 5.3.6 Building(s) | attr: General Description; rel: has or had location | rico:hasOrHadLocation | Mapped |  |
| 5.3.7 Archival and other holdings | attr: General Description | rico:isOrWasHolderOf | Mapped |  |
| 5.3.8 Finding aids, guides and publications | rel: is or was described by | rico:isOrWasDescribedBy to a finding-aid Record | Mapped |  |
| 5.4.1 Opening times | attr: General Description; rel: is or was regulated by; rel: performs or performed | openricx:openingHours | Unresolved | RiC-AG gives General Description or a Rule, in RiC-O. A structured value may justify the extension; the reason is not yet written. |
| 5.4.2 Conditions and requirements for access and use | attr: Rule Type; rel: is or was regulated by | rico:conditionsOfAccess | Unresolved | Defect (D-1): rico:conditionsOfAccess applies to a Record Resource or Instantiation, not an agent. RiC-AG gives a Rule regulating access. |
| 5.4.3 Accessibility | attr: Rule Type; rel: is or was regulated by | openricx:accessibility | Unresolved | RiC-AG gives a Rule regulating access, in RiC-O. |
| 5.5.1 Research services | rel: performs or performed | rico:performsOrPerformed to a rico:Activity, or text | Mapped |  |
| 5.5.2 Reproduction service | entity: Corporate Body, Family, Group | As 5.5.1 | Mapped |  |
| 5.5.3 Public areas | attr: General Description; rel: has or had location | rico:hasOrHadLocation with rico:generalDescription | Mapped |  |
| 5.6.1 Description identifier | attr: Agent; attr: Identifier; rel: describes or described | rico:identifier on the describing Record | Mapped |  |
| 5.6.2 Institution identifier | attr: Activity; attr: Identifier; attr: is or was performed by; rel: results or resulted from | The Record results from an Activity performed by the institution | Mapped |  |
| 5.6.3 Rules and/or conventions used | attr: Activity; attr: is or was regulated by; rel: results or resulted from | rico:isOrWasRegulatedBy to a rico:Rule | Mapped |  |
| 5.6.4 Status | attr: State | Text in rico:generalDescription ("no RiC-O 1.1 property") | Unresolved | Defect (D-4): RiC-O 1.1 has rico:hasRecordState, the RiC-CM State that RiC-AG names. |
| 5.6.5 Level of detail | attr: General Description | rico:generalDescription | Mapped |  |
| 5.6.6 Dates of creation, revision or deletion | attr: Activity; attr: is or was performed by; rel: Date of Relation; rel: results or resulted from | rico:hasCreationDate and rico:hasModificationDate | Mapped |  |
| 5.6.7 Language(s) and script(s) | attr: Language | rico:hasOrHadLanguage | Mapped |  |
| 5.6.8 Sources | attr: Activity; attr: is or was performed by; rel: Source of Relation; rel: results or resulted from | rico:generalDescription | Unresolved | RiC-O 1.1 has rico:recordResourceSourceOfInformation, more specific than a general note. |
| 5.6.9 Maintenance notes | attr: Activity; attr: is or was performed by; rel: results or resulted from | rico:generalDescription | Mapped, broader | RiC-AG models maintenance as activities the record results from. |

## ISDF

23 elements: 14 mapped, 1 mapped more broadly, 2 extensions, 6 unresolved.

| Element | RiC-AG 0.1 (RiC-CM) | OpenRiC mapping | Classification | Rationale |
|---|---|---|---|---|
| 5.1.1 Type | attr: Activity Type | rico:hasActivityType | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.1.2 Authorised form(s) of name | attr: Name | rico:name | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.1.3 Parallel form(s) of name | attr: Name (the crosswalk leaves the attribute blank here; read as continuing the authorised form above it) | openricx:alternativeForm | Extension | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.1.4 Other form(s) of name | attr: Name (the crosswalk leaves the attribute blank here; read as continuing the authorised form above it) | openricx:otherName | Extension | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.1.5 Classification | attr: Activity Type | rico:classification | Unresolved | Defect (D-2): rico:classification applies to a Record Resource. RiC-AG gives Activity Type. |
| 5.2.1 Dates | rel: has beginning date; rel: has end date; rel: has modification date; rel: is associated with date | rico:hasBeginningDate, hasEndDate; text in rico:date | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.2.2 Description | attr: General Description | rico:generalDescription | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.2.3 History | attr: History; rel: is or was affected by | rico:history | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.2.4 Legislation | attr: Rule Type; rel: is or was regulated by | rico:isOrWasRegulatedBy to a rico:Rule | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.3.1 Authorised form(s) of name/ | attr: Identifier; attr: Name | The target of the relation (5.3.x) | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.3.2 Type | attr: Activity Type | Not stated | Unresolved | The mapping groups 5.3.x; the related function's type has no stated place. |
| 5.3.3 Category of relationship | attr: Description; rel: is related to | rico:isRelatedTo, rico:followsInTime or rico:isOrWasPartOf | Mapped | OpenRiC serves a function as the interim openricx:Function; RiC-AG maps ISDF to rico:Activity (mapping 6.4). |
| 5.3.4 Description of relationship | rel: affects or affected; rel: follows in time; rel: follows or followed; rel: has or had part; rel: has or had participant; rel: has or had subevent; rel: is associated with event; rel: is event associated with; rel: is or was affected by; rel: is or was part of; rel: is or was participant in; rel: precedes in time; rel: precedes or preceded; rel: results or resulted from; rel: results or resulted in | Not stated | Unresolved | The mapping groups 5.3.x; a relation's description has no stated place. |
| 5.3.5 Dates of relationship | attr: Date; rel: affects or affected; rel: follows in time; rel: follows or followed; rel: has or had part; rel: has or had participant; rel: is associated with event; rel: is event associated with; rel: is or was affected by; rel: is or was part of; rel: is or was participant in; rel: is related to; rel: precedes in time; rel: precedes or preceded; rel: results or resulted from; rel: results or resulted in | Not stated | Unresolved | The mapping groups 5.3.x; a relation's dates have no stated place. |
| 5.4.1 Function description identifier | attr: Identifier; rel: describes or described | rico:identifier on the describing Record | Mapped |  |
| 5.4.2 Institution identifiers | attr: Identifier; rel: is or was performed by; rel: results or resulted from | The Record results from an Activity performed by the institution | Mapped |  |
| 5.4.3 Rules and/or conventions used | rel: is or was regulated by; rel: results or resulted from | rico:isOrWasRegulatedBy to a rico:Rule | Mapped |  |
| 5.4.4 Status | attr: State | Text in rico:generalDescription ("no RiC-O 1.1 property") | Unresolved | Defect (D-4): RiC-O 1.1 has rico:hasRecordState, the RiC-CM State that RiC-AG names. |
| 5.4.5 Level of detail | attr: General Description | rico:generalDescription | Mapped |  |
| 5.4.6 Dates of creation, revision or deletion | attr: Date of Relation; rel: is or was performed by; rel: results or resulted from | rico:hasCreationDate and rico:hasModificationDate | Mapped |  |
| 5.4.7 Language(s) and script(s) | attr: Language | rico:hasOrHadLanguage | Mapped |  |
| 5.4.8 Sources | attr: Source of Relation; rel: is or was performed by; rel: results or resulted from | rico:generalDescription | Unresolved | RiC-O 1.1 has rico:recordResourceSourceOfInformation, more specific than a general note. |
| 5.4.9 Maintenance notes | rel: is or was performed by; rel: results or resulted from | rico:generalDescription | Mapped, broader | RiC-AG models maintenance as activities the record results from. |
