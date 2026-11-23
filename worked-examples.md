---
layout: default
title: Worked examples
description: Real archival material described in RiC, step by step, from a 1950 newspaper scrapbook held by Smuts House Museum - each decision explained, with the live records and their RiC-O to check it against.
permalink: /learn/examples/
---

# Worked examples

These examples use one real collection, published in [OpenRiC Workspace](https://workspace.openric.org): a scrapbook of newspaper cuttings on the death and funeral of General J.C. Smuts in September 1950. It is held by Smuts House Museum at Doornkloof, Irene, and was photographed during a survey visit on 19 November 2026; it is published with the museum's permission.

Each example sets out one modelling decision, why it was taken, and where another archivist could reasonably decide differently. Every claim links to the live record and its RiC-O, so you can check it rather than take it on trust. They follow the themes ICA-EGAD's draft [RiC Application Guidelines (RiC-AG) 0.1](https://ica-egad.github.io/RiC-AG/index.html) asks implementers to explain. RiC-AG is guidance, not a test, and these are one reading of it, not a certificate of conformance.

The collection: [General J.C. Smuts - death and funeral newspaper scrapbook, September 1950](https://workspace.openric.org/discover/records/01a1f4da-cb39-7308-81a3-b88da21e921c) ([its explorer](https://workspace.openric.org/discover/records/01a1f4da-cb39-7308-81a3-b88da21e921c/explorer)).

## 1. Record Set, Record or Record Part?

**What there is.** One scrapbook. Each of its 45 photographed pages carries one or more cuttings; nine pages name their newspaper (The Star, the Rand Daily Mail, Die Vaderland, the Sunday Express). Who compiled it is not recorded. Page 4 is the cover, lettered "J.C. Smuts".

**The decision.** The scrapbook is a `rico:RecordSet`, of the record set type *File* (`rico:hasRecordSetType`). Each page is a `rico:Record`, included in it (`rico:isDirectlyIncludedIn`) and placed in order (`rico:directlyPrecedesInSequence`). The cuttings on a page are described in the page's scope and content, not as entities of their own.

**Why.** In RiC-CM a Record Set is a grouping of records, and a Record is a discrete piece of information with fixed content and structure. The compiler made each page a deliberate whole: the choice and arrangement of cuttings on it and the order of the pages are part of what the scrapbook is, and the page is the smallest unit that was photographed and can be cited and found again.

**Where you might decide differently.**
- A single cutting is a Record in its own right, created by its newspaper on its date. If a researcher needs to cite one article, or the cuttings are ever lifted and rehoused, describe each cutting as a Record and the page as a Record Set of them, or the cutting as a `rico:RecordPart` of the page if it can never stand alone. RiC-CM 1.0.1 widened *has author* (RiC-R079) to a Record Part for this kind of case (see the [baseline](/ric-baseline.html#ric-cm-101-what-changed)).
- The cover could be a Record Part of the scrapbook rather than a page among pages. It is kept in sequence here because it was photographed and numbered with the pages.
- "File" is a level of description brought over from ISAD(G). RiC does not require it; it is kept as the record set type because archivists searching the catalogue still think in levels.

**Check it.** The [scrapbook's RiC-O](https://workspace.openric.org/api/ric/v1/records/01a1f4da-cb39-7308-81a3-b88da21e921c/export?format=turtle) and [page 1's](https://workspace.openric.org/api/ric/v1/records/01a1f4da-cba3-739d-b65c-eced7038ee1a/export?format=turtle).

## 2. A record and its instantiations

**What there is.** The paper page. A survey photograph of it, taken on 19 November 2026. A machine transcription of the photograph, made with one model and checked against a second, not yet proofread.

**The decision.** The page is one Record. The photograph (`smuts-funeral-scrapbook-p01.jpg`) and the transcription (`smuts-funeral-scrapbook-p01.txt`) are two `rico:Instantiation`s of it (`rico:hasOrHadDigitalInstantiation`), each with its carrier type, its MIME type, its size as a `rico:InstantiationExtent` in bytes, and its SHA-256 checksum. Photographing the page did not make a new record.

**Why.** RiC-CM separates the intellectual record from each physical or digital manifestation of it. The photograph and the transcript carry the same record, with different properties: the photograph keeps the layout and the pictures, the transcript is searchable. Describing them as new records would double the collection and lose the fact that both are the same page. The quality of the transcript is said where a reader will see it, in the page's scope and content: machine transcription, not yet proofread.

**What this description does not yet say.** Three things RiC can express, which an archivist would add before calling it complete:
- The paper page itself as an instantiation, with its carrier (paper and paste) and where it is kept. Only the digital copies are described.
- That the transcript was derived from the photograph (`rico:isOrWasDerivedFromInstantiation`).
- The photography as an activity of its own (a `rico:Activity` on 19 November 2026, performed by The Archive and Heritage Digital Commons Group, resulting in the photographs), so that its date and purpose are data rather than a sentence. Today the date and the fact that these are survey photographs, not a preservation capture, are given only in the access conditions and the history note.

**Check it.** [Page 1](https://workspace.openric.org/discover/records/01a1f4da-cba3-739d-b65c-eced7038ee1a), [its photograph](https://workspace.openric.org/api/ric/v1/instantiations/01a1f4da-cbe7-7050-862d-930cd98c6191) and [its transcript](https://workspace.openric.org/api/ric/v1/instantiations/01a1f4da-cd7a-726b-a861-7f8998783697) as JSON-LD.

## 3. Events, dates and subjects

To follow: the state funeral as an activity with its own events, dates as printed and as normalised, and the difference between a newspaper as a page's creator and Smuts as its subject. The scrapbook's relations to people, places and events are under review: each was proposed from the text and the research note, and only those a person has accepted are published. This example is written from the accepted relations once the review is done.

## RiC-O 1.1 and the next version

OpenRiC and these examples use **RiC-O 1.1** (released 27 May 2025), the latest release. ICA-EGAD develops the next version in the open, on the RiC-O repository's `next-version` branch. Recent changes there include:

- *has author* extended to a Record Part ([#184](https://github.com/ICA-EGAD/RiC-O/pull/184), 19 November 2026), the RiC-O side of the RiC-CM 1.0.1 change;
- `rico:hasOrHadActivityOfType` and its inverse ([#182](https://github.com/ICA-EGAD/RiC-O/pull/182), 15 November 2026);
- a `scale` property ([#180](https://github.com/ICA-EGAD/RiC-O/pull/180), 19 November 2026);
- measurements as properties of their own (height, width, length, thickness, duration) and `physicalOrLogicalExtent` renamed `extent` (October 2026).

None of these is normative until ICA-EGAD releases them. OpenRiC does not use them yet; where it needed a concept first, it uses its own [`openricx:`](/ns/ext/v1.html) term and will bind it to the RiC-O term once released ([openric/service#12](https://github.com/openric/service/issues/12)). The [drift log](/drift-log.html) records what is tracked.
