---
layout: default
title: RiC baseline and conformance
permalink: /ric-baseline.html
description: The exact Records in Contexts standards OpenRiC targets - RiC-FAD 1.0, RiC-CM 1.0, RiC-O 1.1 and RiC-AG 0.1 - and how OpenRiC relates to each.
---

# RiC baseline and conformance

Records in Contexts is four documents, not one, and OpenRiC targets a specific version of each. This page names them. If you need to know in one minute what OpenRiC conforms to, this is the page.

## The stack OpenRiC targets

| Standard | Version | What it is | How OpenRiC uses it |
|---|---|---|---|
| **RiC-FAD** | 1.0 | Foundational principles for archival description | Assumed. OpenRiC does not restate it. |
| **RiC-CM** | 1.0 | The conceptual model - entities, attributes, relations | The model OpenRiC's [RiC-CM navigator](https://ric.theahg.co.za/reference/ric-cm/1.0) presents, and the vocabulary its user-facing labels map back to. |
| **RiC-O** | 1.1 | The OWL ontology - the normative RDF implementation target | **The normative target.** Every IRI OpenRiC emits is a RiC-O 1.1 term, or an [`openricx:`](/ns/ext/v1.html) term where RiC-O 1.1 has no equivalent. |
| **RiC-AG** | 0.1 | Application guidelines, including crosswalks from the four legacy ICA standards | The upstream authority for the ISAD(G) / ISAAR(CPF) / ISDF / ISDIAH crosswalk. [`spec/mapping.md` §1.2](/spec/mapping.html) defers to it where the two agree. |

OpenRiC itself is at **v{{ site.data.version.version }}** ({{ site.data.version.release_date }}). That version line describes the OpenRiC contract - the HTTP API, the profiles, the schemas and shapes - and moves independently of the RiC versions above.

## The rule about namespaces

**OpenRiC never mints a term in the RiC-O namespace.** Where an implementation needs a concept RiC-O 1.1 does not define, the term goes in the OpenRiC extension namespace `https://openric.org/ns/ext/v1#`, prefix `openricx`, published as [an ontology page and Turtle file](/ns/ext/v1.html).

That namespace currently holds 48 terms in three groups: response-envelope classes that are protocol concerns rather than archival semantics; pragmatic API shortcuts that have a clean canonical expansion in RiC-O 1.1; and a small set of genuine archival concepts that RiC-O 1.1 does not yet model. Only the third group is a candidate for going upstream, and those are [drafted as proposals](https://github.com/openric/spec/tree/main/docs/upstream-proposals) to ICA-EGAD.

The per-term disposition, with confidence flags, is in the [RiC-O 1.1 conformance audit](/audit/ric-o-1.1-audit.html).

## What conformance means here

Conformance is claimed **per profile**, not as a single overall level. OpenRiC defines twelve profiles - seven normative, five draft - and an implementation declares each one it supports, with its own version and conformance degree. See the [profile index](/spec/profiles/) and the [conformance specification](/spec/conformance.html).

The older `L1`-`L4` level vocabulary is legacy. It survives as a `level` field in responses for compatibility, but it no longer frames conformance and should not be used in new material.

## Tracking upstream

RiC is still moving, and OpenRiC does not guess ahead of it. Changes to the normative core wait for an official ICA-EGAD release; open proposals in the RiC-O repository are watched, not adopted. What OpenRiC is tracking, and where the reference implementation currently lags the specification, is recorded in the [drift log](/drift-log.html).

Where OpenRiC has contributed upstream - on agent roles in relations, language on relations, SHACL, and a PROF profile - those threads are linked from [related implementations](/related-implementations.html).

## What OpenRiC does not replace

OpenRiC is an access contract over RiC data. It is not a replacement for IIIF (presentation and delivery of digital representations), Linked Art or CIDOC CRM (museum and cultural-object semantics), Wikidata (shared external identity), or the operational source standards an institution already runs. Where those overlap with RiC, the right answer is a documented mapping, not forcing foreign semantics into RiC-O.
