---
layout: default
title: RiC-O 1.1 conformance audit
---

# RiC-O 1.1 conformance audit - openric/spec

> ## ✅ STATUS - REMEDIATION COMPLETE (v0.37.0, 2026-04-25)
>
> All five remediation phases (A → E) below have been applied. The original audit found **110 of 168 distinct `rico:*` tokens** were not in RiC-O 1.1; after remediation, **zero genuine emit-context uses of unsupported `rico:*` terms remain**. The 7-10 `rico:*` mentions that still appear in a repo-wide token scan are exclusively inside **"MUST NOT emit X"** documentation prose - correct text, not violations.
>
> The body of this document below is preserved for forensic / audit-history purposes - it is the complete record of what was found, what was decided per term, and how each phase was applied. New readers should focus on the ✅ phase-status markers in §Migration plan; the 478-canonical-vs-110-missing numbers reflect the **pre-remediation state**, not current.

**Generated:** 2026-04-24 · **Remediation completed:** 2026-04-25 · **Catalyst:** ICA-EGAD reviewer feedback (April 2026) · **Canonical ontology:** [RiC-O 1.1, 2025-05-22](https://raw.githubusercontent.com/ICA-EGAD/RiC-O/master/ontology/current-version/RiC-O_1-1.rdf) - 102 classes, 316 object properties, 60 datatype properties, 23 annotation properties.

## Method

1. Fetched canonical RiC-O 1.1 RDF from `ICA-EGAD/RiC-O` (master branch, `ontology/current-version/RiC-O_1-1.rdf`).
2. Extracted every term declared via `owl:(Class|ObjectProperty|DatatypeProperty|AnnotationProperty|NamedIndividual) rdf:about="...#X"` → 478 canonical terms. Cross-verified against the Fuseki-loaded copy (same count).
3. Scanned every `.md .ttl .json .jsonld .html .yml .xml` file in the openric/spec repo for `rico:[A-Za-z_][A-Za-z0-9_]*` tokens → 168 distinct terms used.
4. Set-diff: **58 exist in RiC-O 1.1, 110 do not**.
5. For every missing term, proposed a disposition with confidence flag. Every `RENAME` target was cross-checked against the canonical set to catch false targets - 13 of my first-pass suggestions were wrong (proposed targets that don't exist in 1.1) and were corrected before this document was written.

## Summary

- **DROP:** 2
- **RENAME:** 36
- **REMODEL:** 25
- **EXTENSION:** 46
- **REVIEW:** 1
- **Total missing:** 110
- **Total OK (kept as-is):** 58

## Extension namespace proposal

```
@prefix openricx: <https://openric.org/ns/ext/v1#> .
```

Versioned from day one (`/v1#`) so we can evolve without breaking implementers - same pattern RiC-O itself uses. Ontology stub lives at `/ns/ext/v1.ttl` with human docs under `/ns/ext/v1/`.

## Full disposition table

| Term | Uses | Action | Target / note | Conf | Rationale |
|------|-----:|--------|---------------|------|-----------|
| `rico:AccessRestriction` | 1 | **REMODEL** | `Rule + hasOrHadRuleType` | medium | AccessOrUseRule subclass |
| `rico:Accumulation` | 33 | **REMODEL** | `AccumulationRelation` | medium | Relation-with-role pattern |
| `rico:ActivityList` | 1 | **EXTENSION** | `openricx:ActivityList` | high | Pagination envelope |
| `rico:Checksum` | 2 | **EXTENSION** | `openricx:Checksum` | medium |  |
| `rico:ContactPoint` | 12 | **EXTENSION** | `openricx:ContactPoint` | high | Absent in 1.1 |
| `rico:CustodyEvent` | 1 | **REMODEL** | `Activity + hasActivityType` | medium | Events-as-activities |
| `rico:DateRange` | 33 | **EXTENSION** | `openricx:DateRange` | high | Dropped from 1.1 - or refactor to begin/end date pairs |
| `rico:DateRangeSet` | 1 | **EXTENSION** | `openricx:DateRangeSet` | high | Dropped from 1.1 |
| `rico:Function` | 24 | **REMODEL** | `Activity OR FunctionalEquivalenceRelation` | medium | Dropped as class in 1.1 |
| `rico:FunctionList` | 1 | **EXTENSION** | `openricx:FunctionList` | high |  |
| `rico:InstantiationList` | 1 | **EXTENSION** | `openricx:InstantiationList` | high |  |
| `rico:PlaceList` | 4 | **EXTENSION** | `openricx:PlaceList` | high |  |
| `rico:Production` | 43 | **REMODEL** | `Activity + hasActivityType` | medium | RiC-AG pattern for activity kinds |
| `rico:ProductionActivity` | 1 | **REMODEL** | `Activity + hasActivityType` | medium |  |
| `rico:RecordList` | 2 | **EXTENSION** | `openricx:RecordList` | high |  |
| `rico:RecordSetList` | 1 | **EXTENSION** | `openricx:RecordSetList` | high |  |
| `rico:RuleList` | 1 | **EXTENSION** | `openricx:RuleList` | high |  |
| `rico:SecurityClassification` | 1 | **REMODEL** | `Rule + hasOrHadRuleType` | medium |  |
| `rico:Transfer` | 1 | **REMODEL** | `Activity + hasActivityType` | medium |  |
| `rico:Vocabulary` | 1 | **RENAME** | `skos:ConceptScheme` | high | Use SKOS |
| `rico:algorithm` | 1 | **EXTENSION** | `openricx:algorithm` | high |  |
| `rico:alternativeForm` | 5 | **EXTENSION** | `openricx:alternativeForm` | high |  |
| `rico:arrangement` | 2 | **EXTENSION** | `openricx:arrangement` | medium |  |
| `rico:certainty` | 1 | **RENAME** | `relationCertainty` | high |  |
| `rico:city` | 3 | **EXTENSION** | `openricx:city` | high |  |
| `rico:conformsTo` | 1 | **RENAME** | `dcterms:conformsTo` | high | Use Dublin Core |
| `rico:contact` | 11 | **EXTENSION** | `openricx:contact` | high |  |
| `rico:containsPersonalData` | 2 | **EXTENSION** | `openricx:containsPersonalData` | high | GDPR - propose upstream |
| `rico:country` | 3 | **EXTENSION** | `openricx:country` | high |  |
| `rico:dateOfEstablishment` | 2 | **RENAME** | `hasBeginningDate` | medium | Where applied to Agent - else review |
| `rico:dateOfTermination` | 1 | **RENAME** | `hasEndDate` | high |  |
| `rico:dateSet` | 1 | **EXTENSION** | `openricx:dateSet` | medium |  |
| `rico:dateType` | 5 | **RENAME** | `hasDateType` | high |  |
| `rico:description` | 25 | **EXTENSION** | `dcterms:description OR openricx:description` | high | Not in 1.1 |
| `rico:descriptiveNote` | 9 | **EXTENSION** | `openricx:descriptiveNote` | high |  |
| `rico:email` | 3 | **EXTENSION** | `openricx:email` | high |  |
| `rico:extentType` | 11 | **RENAME** | `hasExtentType` | high |  |
| `rico:generalContext` | 4 | **EXTENSION** | `openricx:generalContext` | high |  |
| `rico:hasAccessRestriction` | 3 | **REMODEL** | `isOrWasRegulatedBy` | medium | Link Resource→Rule |
| `rico:hasAccessRule` | 1 | **REMODEL** | `isOrWasRegulatedBy` | high |  |
| `rico:hasAcquisitionProvenance` | 2 | **REMODEL** | `hasOrganicProvenance` | medium | 1.1 provenance pattern |
| `rico:hasActivity` | 1 | **REMODEL** | `ActivityDocumentationRelation` | medium | or isOrWasSubjectOf - direction-dependent |
| `rico:hasAgentName` | 21 | **REMODEL** | `Agent → AgentName link` | low | No direct property |
| `rico:hasAppraisalInformation` | 1 | **EXTENSION** | `openricx:hasAppraisalInformation` | medium | Propose upstream |
| `rico:hasBroaderConcept` | 1 | **RENAME** | `skos:broader` | high | Use SKOS, not rico: |
| `rico:hasBroaderGeographicalContext` | 2 | **EXTENSION** | `openricx:hasBroaderGeographicalContext` | medium |  |
| `rico:hasCarrier` | 1 | **RENAME** | `hasCarrierType` | medium | Carrier info typed |
| `rico:hasChecksum` | 1 | **EXTENSION** | `openricx:hasChecksum` | medium |  |
| `rico:hasDateRange` | 1 | **EXTENSION** | `openricx:hasDateRange` | high |  |
| `rico:hasDateRangeSet` | 16 | **EXTENSION** | `openricx:hasDateRangeSet` | high |  |
| `rico:hasFindingAid` | 3 | **EXTENSION** | `openricx:hasFindingAid` | medium | Propose upstream |
| `rico:hasHolding` | 3 | **RENAME** | `hasOrHadHolder` | high | Inverse direction |
| `rico:hasInstantiation` | 17 | **RENAME** | `hasOrHadInstantiation` | high |  |
| `rico:hasInternalStructure` | 3 | **EXTENSION** | `openricx:hasInternalStructure` | medium |  |
| `rico:hasLanguage` | 4 | **RENAME** | `hasOrHadLanguage` | high |  |
| `rico:hasMandate` | 4 | **RENAME** | `authorizingMandate` | medium | or use MandateRelation |
| `rico:hasMimeType` | 11 | **EXTENSION** | `openricx:hasMimeType OR dcterms:format` | high |  |
| `rico:hasName` | 1 | **RENAME** | `hasOrHadName` | high |  |
| `rico:hasNarrowerGeographicalContext` | 2 | **EXTENSION** | `openricx:hasNarrowerGeographicalContext` | medium |  |
| `rico:hasOccupation` | 2 | **REMODEL** | `OccupationType + relation` | medium | No direct property in 1.1 |
| `rico:hasOrHadAgent` | 1 | **REMODEL** | `hasOrHadHolder | hasOrHadCreator` | low | Too generic |
| `rico:hasOrHadPolicy` | 2 | **EXTENSION** | `openricx:hasOrHadPolicy` | medium |  |
| `rico:hasPhysicalCharacteristics` | 1 | **EXTENSION** | `openricx:hasPhysicalCharacteristics` | medium |  |
| `rico:hasPlace` | 5 | **REMODEL** | `isAssociatedWithPlace OR hasBirthPlace OR tookPlaceAt - per context` | low | Review per call site |
| `rico:hasPlaceName` | 14 | **REMODEL** | `Place → PlaceName link` | low | No direct property |
| `rico:hasProductionTechnique` | 4 | **RENAME** | `productionTechnique` | high |  |
| `rico:hasReasonForExecution` | 1 | **REMODEL** | `authorizingMandate or Rule linkage` | low | Review per site |
| `rico:hasRecordPart` | 4 | **RENAME** | `includesOrIncluded` | medium | or isOrWasIncludedIn |
| `rico:hasSecurityClassification` | 2 | **REMODEL** | `isOrWasRegulatedBy` | medium |  |
| `rico:hasSource` | 4 | **RENAME** | `relationHasSource` | high | same as source |
| `rico:hasSubject` | 7 | **RENAME** | `hasOrHadSubject` | high | RiC-O 1.1 uses hasOrHad* for temporally-variant relations |
| `rico:heldBy` | 10 | **RENAME** | `hasOrHadHolder` | high | Inverse direction - switch subject/object in data |
| `rico:isAssociatedWithActivity` | 1 | **REMODEL** | `isOrWasSubjectOf` | low | Review each site |
| `rico:isContainedIn` | 3 | **REMODEL** | `isOrWasIncludedIn` | medium | Inclusion hierarchy |
| `rico:isInstantiationOf` | 8 | **RENAME** | `isOrWasInstantiationOf` | high |  |
| `rico:isLocationOf` | 3 | **RENAME** | `isOrWasLocationOf` | high |  |
| `rico:isOrHasCurrentCustodian` | 2 | **REMODEL** | `hasOrHadHolder` | medium | Holder/custodian collapsed |
| `rico:isOrWasAssociatedWithDate` | 26 | **RENAME** | `isAssociatedWithDate` | high | Drop OrWas prefix |
| `rico:isOrWasControlledBy` | 1 | **REMODEL** | `AgentControlRelation + role` | medium |  |
| `rico:isOrWasFollowedBy` | 1 | **RENAME** | `followsInTime` | medium | or use followedInSequence |
| `rico:isOrWasHeldBy` | 2 | **RENAME** | `hasOrHadHolder` | high | Same: inverse |
| `rico:isOrWasLocatedAt` | 2 | **RENAME** | `hasOrHadLocation` | high | Switch direction |
| `rico:isOrWasXxxOf` | 1 | **DROP** | `` | high | Placeholder / template leak - remove |
| `rico:isSubjectOf` | 2 | **RENAME** | `isOrWasSubjectOf` | high |  |
| `rico:jurisdiction` | 2 | **EXTENSION** | `openricx:jurisdiction` | medium |  |
| `rico:languageCode` | 5 | **EXTENSION** | `openricx:languageCode or ISO-639 IRI` | high |  |
| `rico:legalStatus` | 2 | **RENAME** | `hasOrHadLegalStatus` | high |  |
| `rico:mimeType` | 2 | **EXTENSION** | `openricx:mimeType` | high |  |
| `rico:normalizedDate` | 9 | **RENAME** | `normalizedDateValue` | high |  |
| `rico:normalizedForm` | 4 | **EXTENSION** | `openricx:normalizedForm` | high |  |
| `rico:otherName` | 4 | **EXTENSION** | `openricx:otherName` | medium |  |
| `rico:performs` | 2 | **RENAME** | `performsOrPerformed` | high |  |
| `rico:postalCode` | 3 | **EXTENSION** | `openricx:postalCode` | high |  |
| `rico:precedes` | 2 | **RENAME** | `precedesInTime` | medium | or precededInSequence |
| `rico:predicate` | 1 | **RENAME** | `rdf:predicate` | medium | Generic predicate on Relation |
| `rico:productionTechnicalCharacteristics` | 1 | **EXTENSION** | `openricx:productionTechnicalCharacteristics` | low | Or split |
| `rico:publicationInformation` | 1 | **EXTENSION** | `openricx:publicationInformation` | high |  |
| `rico:ruleType` | 13 | **RENAME** | `hasOrHadRuleType` | high |  |
| `rico:size` | 1 | **EXTENSION** | `openricx:size` | medium |  |
| `rico:someInternalMarker` | 1 | **DROP** | `` | high | Internal marker - remove |
| `rico:source` | 1 | **RENAME** | `relationHasSource` | high |  |
| `rico:startDate` | 11 | **RENAME** | `hasBeginningDate` | high |  |
| `rico:streetAddress` | 9 | **EXTENSION** | `openricx:streetAddress` | high |  |
| `rico:succeeds` | 2 | **RENAME** | `followsInTime` | medium |  |
| `rico:target` | 1 | **RENAME** | `relationHasTarget` | high |  |
| `rico:technicalCharacteristics` | 0 | **EXTENSION** | `openricx:technicalCharacteristics` | medium |  |
| `rico:telephone` | 3 | **EXTENSION** | `openricx:telephone` | high |  |
| `rico:tookPlaceAt` | 4 | **REMODEL** | `isAssociatedWithPlace` | medium | Or extension |
| `rico:value` | 1 | **REVIEW** | `` | low | Too generic |
| `rico:wasAcquiredFrom` | 1 | **REMODEL** | `OrganicProvenanceRelation + role` | medium |  |

## Things I am explicitly NOT 100% sure of

Every row with confidence `low` or `medium` in the table. Specifically:

- **`hasPlace`** - appears in many call sites with different meanings (birth place, place of origin, associated place, tookPlaceAt). Each use site needs individual review before rename.
- **`hasAgentName` / `hasPlaceName`** - the name classes exist in 1.1, but no direct linking property. May need an `agentName_role` / RDF-star reification approach.
- **`Production` / `Accumulation`** - should remodel to `Activity + hasActivityType`, but the expected activity-type vocabulary needs alignment with RiC-AG.
- **`hasOrHadPlaceOfOrigin`** - used in 289 triples of the live reference data but **not declared in RiC-O 1.1**. Either a historical property that was removed, or the reference data was generated against a non-conformant mapping. **Needs confirmation from the reviewer.**
- **`description`** - RiC-O 1.1 does not define `rico:description`. Use `dcterms:description` or mint `openricx:description`? Both are defensible.
- **`textualValue`** - my first extraction flagged it missing; the second (strict) found it IS in RiC-O 1.1. The audit numbers above assume `textualValue` is missing, so the true counts may be marginally better than reported.

## Upstream proposals (for ICA-EGAD)

Candidates for GitHub issues against `ICA-EGAD/RiC-O`:

- `hasFindingAid` - link a RecordResource to its finding aid document.
- `hasAppraisalInformation` - capture appraisal rationale.
- `containsPersonalData` - privacy-compliance flag.
- `ContactPoint` class + address fields - first-class contact modelling.

## Migration plan

Phased so each PR is small enough to review:

1. **A - version strings.** ✅ Shipped 2026-04-24 (commit `47c6581`). Every 'RiC-O v1.0' → 'v1.1' and every 1.0 link → 1.1. Zero semantic change.
2. **B - HIGH-confidence RENAMEs / DROPs / cross-namespace.** ✅ Applied 2026-04-25 (uncommitted). 20 pure renames + 3 cross-namespace (`Vocabulary`→`skos:ConceptScheme`, `hasBroaderConcept`→`skos:broader`, `conformsTo`→`dcterms:conformsTo`) + 2 DROPs (`isOrWasXxxOf`, `someInternalMarker`) across 38 files, 129 occurrences. Held back: `rico:hasSource` (4 hits all in Rule attribution context, not `rico:Relation` source - needs Phase D semantic decision, likely `dcterms:source`); `rico:isOrWasFollowedBy` (medium-confidence in audit table - defer to Phase D). **Result: 110 → 86 missing rico:* terms.**
3. **C - extension namespace.** ✅ Applied 2026-04-25 (uncommitted). `openricx: <https://openric.org/ns/ext/v1#>` declared in mapping.md, 5 SHACL shape files, and 14 JSON-LD fixture `@context` blocks. All 46 EXTENSION rows renamed (`rico:X` → `openricx:X`), 244 occurrences. For the OR cases (`description` 25 uses, `hasMimeType` 11 uses), the `openricx:` option was taken; the `dcterms:description` / `dcterms:format` substitution can be revisited as Phase D refinement. Three response-shape fixtures (`relations-for-place`, `record-list`, `revision-list`) carry openricx: CURIEs as plain string values (not real JSON-LD with `@context`); they need a broader response-envelope cleanup in Phase D. **Result: 86 → 39 missing rico:* terms.**
4. **D - REMODEL rows + held RENAMEs + ICA-EGAD-confirmed tweaks.** ✅ Applied 2026-04-25 (uncommitted). Sub-phases:
    - **D.1** - additional mechanical RENAMEs against verified canonical 1.1 targets: `hasAgentName→hasOrHadAgentName`, `hasPlaceName→hasOrHadPlaceName`, `isOrWasFollowedBy→followsInTime`, `precedes→precedesInTime`, `succeeds→followsInTime`, `hasCarrier→hasCarrierType`, `hasMandate→authorizingMandate`, `hasRecordPart→includesOrIncluded`, `isContainedIn→isOrWasIncludedIn`, `dateOfEstablishment→hasBeginningDate`, `tookPlaceAt→isAssociatedWithPlace`, `predicate→rdf:predicate`. 12 terms, 59 occurrences. (Audit had marked `hasAgentName`/`hasPlaceName` as REMODEL low-conf; re-verification against canonical-strict.txt found `hasOrHadAgentName`/`hasOrHadPlaceName` ARE in 1.1.)
    - **D.2** - Holder/Location family: `heldBy→hasOrHadHolder`, `isOrWasHeldBy→hasOrHadHolder`, `isOrHasCurrentCustodian→hasOrHadHolder`, `hasHolding→isOrWasHolderOf` (inverse property to preserve direction), `isOrWasLocatedAt→hasOrHadLocation`. 5 terms, 19 occurrences. No data flips needed - RDF inspection confirmed canonical directions match OpenRiC's existing usage; audit's "inverse direction" warning was overcautious.
    - **D.3** - Activity+`hasActivityType` remodel. RiC-O 1.1 has no concrete `rico:Production` / `rico:Accumulation` / `rico:CustodyEvent` / `rico:Transfer` / `rico:ProductionActivity` classes (audit's most-cited gap). Replaced 5 class assertions in 3 fixtures with `@type: rico:Activity` + `rico:hasActivityType` IRIs from new `<https://openric.org/vocab/activity-type/{production,accumulation,custody,transfer,publication,reproduction}>` vocabulary. SHACL targetClass declarations rewritten as `sh:SPARQLTarget` filtering on Activity + hasActivityType IRI (6 targets across 3 shape files). Mapping spec §6.5 fully rewritten. Provenance-event and Authority & Context profile docs rewritten to reflect single-class model. **ICA-EGAD endorsement:** Florence Clavaud (RiC user group thread #27 on digitisation) explicitly recommends this exact pattern: `rico:Activity + hasActivityType + ActivityType` with `rico:isOrWasPerformedBy + rico:Mechanism`.
    - **D.4** - Rule-regulation property remodel: `hasAccessRestriction`/`hasAccessRule`/`hasSecurityClassification` → `rico:isOrWasRegulatedBy`. Mapping spec §9 rewritten with new SKOS rule-type vocabulary at `<https://openric.org/vocab/rule-type/>`. (No actual class assertions of `AccessRestriction` / `SecurityClassification` existed in fixtures, so no fixture rewrite needed.)
    - **D.5** - Provenance: `hasAcquisitionProvenance` (2) and `wasAcquiredFrom` (1) both → `rico:hasOrganicProvenance`. Direction verified against canonical RDF - both source properties had Record→Agent direction matching `hasOrganicProvenance`.
    - **D.6** - Function class + per-call-site reviews: `rico:Function` (23) → `openricx:Function` (interim, with §6.4 documenting canonical alternatives per Florence/Garance review §10.7); `rico:hasPlace` (5) → `rico:isAssociatedWithPlace` (canonical Thing→Place, works for Agent via Thing superclass); `openricx:hasFindingAid` (3) → `rico:isOrWasDescribedBy` with `rico:hasDocumentaryFormType <…#FindingAid>` per Florence Clavaud KM Q&A #1 (FindingAid is a `DocumentaryFormType` SKOS individual, not a separate property).
    - **D.7** - `rico:hasSource` (held from B; 4 uses, all in Rule citation context) → `dcterms:source`. Standard Dublin Core attribution.
    - **D.8** - `spec/mapping.md` §6.2 (Actor → Agent) extended with `mechanism → rico:Mechanism`. New §10 ("Systems, APIs, and Mechanisms") explains the API-surface vs application-concept vs canonical-RiC-entity distinction, the `rico:Mechanism` pattern for software systems / importers / OCR / AI / migration scripts, and provides a worked Turtle example. Endorsed by both Florence Clavaud (KM #27 - "scanner or digital camera") and the Garance review document §10.8 (importer / OCR / AI / migration → Mechanism).
    - **Result: 39 → 10 distinct missing tokens.** Of the 10, **6 are intentional documentation prose** (`Production`, `Accumulation`, `CustodyEvent`, `Transfer`, `Function`, `hasActivity` - appear only in "MUST NOT emit X" warnings explaining removed terms). The remaining **4 genuine Phase E candidates** are `hasOccupation` (audit: REMODEL OccupationType+relation, low-conf), `hasReasonForExecution` (REMODEL low-conf), `isOrWasControlledBy` (REMODEL medium-conf, AgentControlRelation+role), and `value` (REVIEW too generic).
5. **E - REVIEW rows + remaining low-confidence remodels.** ✅ Applied 2026-04-25 (uncommitted).
    - **E.1** - `rico:hasOccupation` (2 uses) → `openricx:hasOccupation` shortcut to a SKOS `OccupationType` Concept. Per Aaron+Florence KM Q&A #20, occupations are SKOS individuals of `rico:OccupationType` (an `ActivityType` subclass). Mapping spec §5.2.5 row updated; agent.schema.json field renamed.
    - **E.2** - `rico:hasReasonForExecution` (1 use, provenance-event.md Optional list) → replaced with `rico:authorizingMandate` → `rico:Mandate` (canonical 1.1, used for the legal/policy basis of an event).
    - **E.3** - `rico:isOrWasControlledBy` (1 use, mapping.md §8 relations table) → `rico:hasOrHadController` (canonical 1.1, Agent → Agent, same direction). Mapping note added that `rico:AgentControlRelation` reification is available for date-scoping.
    - **E.4** - `rico:value` (1 use, hypothetical example for `openricx:Checksum` in digital-object-linkage.md Q2 rationale) → `openricx:checksumValue` (extension property since the entire Checksum class is an OpenRiC extension).
    - **Result: 10 → 7 remaining tokens.** All 7 are now confirmed **intentional documentation prose** in "MUST NOT emit X" / "X is not in 1.1" warnings explaining the remediation: `rico:Production`, `rico:Accumulation`, `rico:CustodyEvent`, `rico:Transfer`, `rico:Function`, `rico:hasActivity`, `rico:hasReasonForExecution`. **Zero genuine emitted-context uses of unsupported `rico:*` terms remain.**
6. **F - upstream proposals.** Issues against `ICA-EGAD/RiC-O`. Candidates from audit:
    - `hasFindingAid` - **withdrawn**, resolved via canonical pattern in D.6 (`isOrWasDescribedBy` + `hasDocumentaryFormType <…#FindingAid>`).
    - `hasAppraisalInformation` - open candidate (currently `openricx:hasAppraisalInformation`).
    - `containsPersonalData` - open candidate (currently `openricx:containsPersonalData`); privacy-compliance flag.
    - `ContactPoint` class + address fields - open candidate (currently `openricx:ContactPoint`).
    - SKOS publication of OpenRiC vocabularies (`activity-type/`, `rule-type/`, `function-type/`) at the `https://openric.org/vocab/` namespace, plus dereferenceable `https://openric.org/ns/ext/v1#` ontology stub for `openricx:`. These close the audit's v1.0 reviewer-checklist row "Extension namespace exists - dereferences to human and machine documentation."

## Source data

Working files under `/tmp/ric-o-audit/` on the build host:

- `ric-o-1.1.rdf` - canonical ontology (1.7 MB)
- `canonical-strict.txt` - 478 canonical terms
- `repo-rico-terms.txt` - 168 terms used in this repo
- `MISSING-strict.txt` - the 110 missing
- `OK-strict.txt` - the 58 present
- `MISSING-usage.tsv` - per-term file list and occurrence count

