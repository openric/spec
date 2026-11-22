---
layout: default
title: OpenRiC Language-Use-Type Vocabulary
permalink: /vocab/language-use-type.html
---

# OpenRiC Language-Use-Type Vocabulary

**Scheme IRI:** `https://openric.org/vocab/language-use-type/`
**Status:** Provisional (spec v{{ site.data.version.version }}) · **Issued:** 2026-11-22 · **Licence:** [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
**Machine-readable:** [language-use-type.ttl](language-use-type.ttl) (Turtle)

A SKOS ConceptScheme of the ways a language is used in the context of a relation, referenced from `openricx:languageWithUsage`. It answers *how* a language was used; `openricx:relationHasLanguage` on the same relation answers *which* language. The pair is the language analogue of `openricx:relationHasAgentRole` and the [role-type vocabulary](role-type.html). The concepts are those Sylvain Loiseau listed on [RiC-O issue #146](https://github.com/ICA-EGAD/RiC-O/issues/146); ICA-EGAD has not yet decided that issue, so the vocabulary is provisional, and an archive with a finer local list keeps its own concepts and matches them to these with `skos:broadMatch`.

## Concepts

| IRI | prefLabel | Definition |
|---|---|---|
| [`primary-text`](https://openric.org/vocab/language-use-type/primary-text) | Primary text | The main language of the text or of the activity: the language in which the record, or the performance, chiefly is. |
| [`secondary`](https://openric.org/vocab/language-use-type/secondary) | Secondary language | A language used alongside the primary one without being separable into its own part, for example for loanwords or a localised passage. |
| [`commentary`](https://openric.org/vocab/language-use-type/commentary) | Commentary | A language used to comment on the primary text or activity. |
| [`gloss`](https://openric.org/vocab/language-use-type/gloss) | Gloss | A language used for glosses: short explanations of words or passages of the primary text. |
| [`transcription`](https://openric.org/vocab/language-use-type/transcription) | Transcription | A language or script in which spoken or written content is transcribed. |
| [`translation`](https://openric.org/vocab/language-use-type/translation) | Translation | A language into which the primary text or activity is translated, including live translation for part of an audience. |
| [`code-switching`](https://openric.org/vocab/language-use-type/code-switching) | Code-switching | A language a speaker or writer alternates with another within the same text or activity. |

## Usage example

A performance given in isiZulu, with an English live translation for part of the audience: two relations, each naming its language and how it was used.

```turtle
<.../activity/concert#perf-1> a rico:PerformanceRelation ;
    openricx:relationHasLanguage <.../language/zul> ;
    openricx:languageWithUsage <https://openric.org/vocab/language-use-type/primary-text> .
<.../activity/concert#perf-2> a rico:PerformanceRelation ;
    openricx:relationHasLanguage <.../language/eng> ;
    openricx:languageWithUsage <https://openric.org/vocab/language-use-type/translation> .
```

The language of a resulting record or record part stays on `rico:hasOrHadLanguage`; the language of the activity sits on the relation.
