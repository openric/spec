---
layout: default
title: OpenRiC Name-Type Vocabulary
permalink: /vocab/name-type.html
---

# OpenRiC Name-Type Vocabulary

**Scheme IRI:** `https://openric.org/vocab/name-type/`
**Status:** Active (spec v{{ site.data.version.version }}) · **Issued:** 2026-11-16 · **Licence:** [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
**Machine-readable:** [name-type.ttl](name-type.ttl) (Turtle)

A SKOS ConceptScheme of the kinds of name or title that ISAAR(CPF), ISDIAH and ISDF distinguish, referenced from `openricx:hasNameType` on `rico:Name` instances (`rico:AgentName`, `rico:PlaceName`, `rico:Title`). RiC-O 1.1 models names as entities, with their dates of use, but has no property for their kind ([#64](https://github.com/openric/spec/issues/64)). An implementation with a finer local vocabulary, such as historical or abbreviated names, keeps its own concepts and matches them to these with `skos:broadMatch` or `skos:exactMatch`.

## Concepts

| IRI | prefLabel | Definition | Source elements |
|---|---|---|---|
| [`authorised`](https://openric.org/vocab/name-type/authorised) | Authorised form | The standard form of name that identifies the entity, built by the rules the describing institution follows. | ISAAR(CPF) 5.1.2; ISDIAH 5.1.2; ISDF 5.1.2; ISAD(G) 3.1.2 for a title |
| [`parallel`](https://openric.org/vocab/name-type/parallel) | Parallel form | The authorised form in another language or script, of equal standing. | ISAAR(CPF) 5.1.3; ISDIAH 5.1.3; ISDF 5.1.3 |
| [`standardised`](https://openric.org/vocab/name-type/standardised) | Standardised form under other rules | The name as it is constructed under rules other than those used for the authorised form, such as a library's. | ISAAR(CPF) 5.1.4 |
| [`other`](https://openric.org/vocab/name-type/other) | Other form | Any other name the entity was known by: an acronym, an earlier or later name, a variant. | ISAAR(CPF) 5.1.5; ISDIAH 5.1.4; ISDF 5.1.4 |

## Usage example

```turtle
<.../agent/naidoo> rico:hasOrHadAgentName <.../agent/naidoo#name-2> .
<.../agent/naidoo#name-2> a rico:AgentName ;
    rico:textualValue "Miss P. Naidoo"@en ;
    openricx:hasNameType <https://openric.org/vocab/name-type/other> .
```

A title or name that translates another also carries `openricx:isTranslationOf`, pointing to the one it translates.
