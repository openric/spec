---
layout: default
title: OpenRiC Extension Ontology 1.9.0
description: Version 1.9.0 of the OpenRiC extension ontology (openricx:), the release identified by the version IRI https://openric.org/ns/ext/v1.9.0.
permalink: /ns/ext/v1.9.0/
kind: spec
---

# OpenRiC Extension Ontology, version 1.9.0

**Version IRI:** `https://openric.org/ns/ext/v1.9.0` · **Released:** 2026-11-22 · **Specification:** v0.59.0

The current release. Its Turtle is [`/ns/ext/v1.ttl`](/ns/ext/v1.ttl); the copy fixed at this release is in the specification repository at the `v0.59.0` tag. It adds how a language is used in a relation, as against which language: the class `openricx:LanguageUseType` and the property `openricx:languageWithUsage`, with the [language-use-type vocabulary](/vocab/language-use-type.html) (openric/service#8). They follow Sylvain Loiseau's proposal on [RiC-O #146](https://github.com/ICA-EGAD/RiC-O/issues/146) and are provisional until ICA-EGAD decides it. [1.8.0](/ns/ext/v1.8.0/) is the release before it.

The terms themselves do not change IRI between versions: every term is `https://openric.org/ns/ext/v1#<name>`. The [ontology page](/ns/ext/v1.html) lists them, with the version history.
