---
layout: default
title: OpenRiC Extension Ontology 1.6.0
description: Version 1.6.0 of the OpenRiC extension ontology (openricx:), the release identified by the version IRI https://openric.org/ns/ext/v1.6.0.
permalink: /ns/ext/v1.6.0/
kind: spec
---

# OpenRiC Extension Ontology, version 1.6.0

**Version IRI:** `https://openric.org/ns/ext/v1.6.0` · **Released:** 2026-10-20 · **Specification:** v0.55.0

The current release. Its Turtle is [`/ns/ext/v1.ttl`](/ns/ext/v1.ttl); the copy fixed at this release is in the specification repository at the `v0.55.0` tag. It adds physical storage, which RiC-O 1.1 does not model: `openricx:Container` and `openricx:ContainerType`, `openricx:isOrWasStoredIn` with its inverse `openricx:storesOrStored`, and `openricx:hasContainerType` with its inverse. A container is placed in a `rico:Place` with RiC-O's own `rico:hasOrHadLocation`. No term is changed or removed; [1.5.0](/ns/ext/v1.5.0/) is the release before it.

The terms themselves do not change IRI between versions: every term is `https://openric.org/ns/ext/v1#<name>`. The [ontology page](/ns/ext/v1.html) lists them, with the version history.
