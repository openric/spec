---
layout: default
title: OpenRiC Date-Type Vocabulary
permalink: /vocab/date-type.html
---

# OpenRiC Date-Type Vocabulary

**Scheme IRI:** `https://openric.org/vocab/date-type/`
**Status:** Active (spec v{{ site.data.version.version }}) · **Issued:** 2026-10-19 · **Licence:** [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
**Machine-readable:** [date-type.ttl](date-type.ttl) (Turtle)

A SKOS ConceptScheme of date-type concepts, referenced from `rico:hasDateType` on a date. Each concept is **also** a `rico:DateType`. In RiC-O 1.1, `rico:hasDateType` is an object property whose range is the class `rico:DateType`, so its value has to be a concept, not a string; RiC-O defines the class but publishes no vocabulary for it, so OpenRiC publishes these five.

## Concepts

| IRI | prefLabel | Definition | Source element |
|---|---|---|---|
| [`existence`](https://openric.org/vocab/date-type/existence) | Existence | The dates during which an agent existed, or during which a function was carried out. | ISAAR(CPF) 5.2.1 Dates of existence; ISDF 5.2.1 Dates. |
| [`creation`](https://openric.org/vocab/date-type/creation) | Creation | The dates at which the records were created. | ISAD(G) 3.1.3 Date(s), where the dates are of creation. |
| [`accumulation`](https://openric.org/vocab/date-type/accumulation) | Accumulation | The dates at which the records were accumulated, as distinct from when they were created. | ISAD(G) 3.1.3 Date(s), where the dates are of accumulation. |
| [`descriptive`](https://openric.org/vocab/date-type/descriptive) | Description | The dates at which the description itself was prepared or revised, not the dates of the records it describes. | ISAD(G) 3.7.3 Date(s) of descriptions. |
| [`custody`](https://openric.org/vocab/date-type/custody) | Custody | The dates during which an agent held custody of the records. | ISAD(G) 3.2.3 Archival history, where it dates a period of custody. |

## Use

```json
"openricx:hasDateRangeSet": {
  "@type": "openricx:DateRange",
  "rico:beginningDate": { "@value": "1886-01-01", "@type": "xsd:date" },
  "rico:endDate": { "@value": "1950-09-11", "@type": "xsd:date" },
  "rico:hasDateType": { "@id": "https://openric.org/vocab/date-type/creation" }
}
```

Until v0.50.0, OpenRiC sent `rico:hasDateType` as a plain string (`"existence"`, `"creation"` and so on). The strings map one to one onto these concepts.
