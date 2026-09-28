---
layout: default
title: OpenRiC Activity-Type Vocabulary
permalink: /vocab/activity-type.html
---

# OpenRiC Activity-Type Vocabulary

**Scheme IRI:** `https://openric.org/vocab/activity-type/`
**Status:** Active (spec v{{ site.data.version.version }}) · **Issued:** 2026-04-25 · **Licence:** [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
**Machine-readable:** [activity-type.ttl](activity-type.ttl) (Turtle)

A SKOS ConceptScheme of activity-type concepts referenced from `rico:hasActivityType` on `rico:Activity` instances. Each concept is **also** a `rico:ActivityType` (RiC-O 1.1 defines `ActivityType` as a class for categorising activities).

## Concepts

| IRI | prefLabel | Definition |
|---|---|---|
| [`production`](https://openric.org/vocab/activity-type/production) | Production | An activity that produces a record — creation, contribution, drafting, authoring. |
| [`accumulation`](https://openric.org/vocab/activity-type/accumulation) | Accumulation | An activity that aggregates or accumulates records — building a collection, gathering files, inheriting custody. |
| [`custody`](https://openric.org/vocab/activity-type/custody) | Custody | A custody event — taking, holding, or transferring physical or intellectual control of records. |
| [`transfer`](https://openric.org/vocab/activity-type/transfer) | Transfer | A transfer event — records moving between custodians, repositories, or jurisdictions. |
| [`publication`](https://openric.org/vocab/activity-type/publication) | Publication | A publication event — issuing or releasing records to a wider audience. |
| [`reproduction`](https://openric.org/vocab/activity-type/reproduction) | Reproduction | A reproduction event — copying, digitising, or duplicating records. |

## Source-data mapping (AtoM `event_type`)

| AtoM `event_type` | Activity-type IRI |
|---|---|
| `creation` | `<…/production>` |
| `contribution` | `<…/production>` |
| `accumulation` | `<…/accumulation>` |
| `collection` | `<…/accumulation>` |
| `custody` | `<…/custody>` |
| `publication` | `<…/publication>` |
| `reproduction` | `<…/reproduction>` |
| *(other)* | — (fall back to bare `rico:Activity` with `openric:localType` carrying the source string) |

## Usage example

```turtle
<.../activity/910378> a rico:Activity ;
    rico:hasActivityType <https://openric.org/vocab/activity-type/production> ;
    rico:name "Production of funeral boat model" ;
    rico:isAssociatedWithDate [
        a openricx:DateRange ;
        rico:beginningDate "1961-01-01"^^xsd:date ;
        rico:endDate       "1999-01-01"^^xsd:date
    ] ;
    rico:hasOrHadParticipant <.../corporatebody/905206> ;
    rico:resultsOrResultedIn  <.../recordset/905228> .
```

See [mapping.md §6.5](/spec/mapping.html) and [provenance-event.md](/spec/profiles/provenance-event.html) for the full pattern.
