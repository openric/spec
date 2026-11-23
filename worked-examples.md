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

**Three things added on 23 November 2026.** The first published description gave only the two digital copies, and this example listed what it left out. It now says:
- the paper page itself, as a third instantiation of the record ("Scrapbook page 1 (original)"), on paper, kept by Smuts House Museum at Smuts House;
- that the transcript was derived from the photograph (`rico:hasOrHadDerivedInstantiation`, with a note that it is a machine transcription not yet proofread);
- the photography as an activity of its own, *Survey photography of the Smuts funeral scrapbook*, dated 19 November 2026 and performed by The Archive and Heritage Digital Commons Group.

**And what the photography resulted in.** The activity *resulted in* the 45 photographs (`rico:resultsOrResultedIn`), and each photograph says what it *resulted from*. Until v0.60.0 OpenRiC's [Provenance and Event profile](/spec/profiles/provenance-event.html) accepted only a Record Set, Record or Record Part as an activity's result, narrower than RiC-O 1.1, which allows any thing. This collection showed why that was too narrow: photographing a page makes copies of it, not a record. Profile 0.9.0 accepts an instantiation too (its design decision Q6), and the Workspace follows it from v0.0.166.

**Where you might decide differently.** You could leave the photography out as an activity and keep only its date and photographer in each photograph's description. Making it an activity costs one more entity, and in return a reader can ask what one survey visit produced and who did it.

**Check it.** [Page 1](https://workspace.openric.org/discover/records/01a1f4da-cba3-739d-b65c-eced7038ee1a), [its photograph](https://workspace.openric.org/api/ric/v1/instantiations/01a1f4da-cbe7-7050-862d-930cd98c6191) and [its transcript](https://workspace.openric.org/api/ric/v1/instantiations/01a1f4da-cd7a-726b-a861-7f8998783697) as JSON-LD, and [the survey photography](https://workspace.openric.org/api/ric/v1/activities/01a2075e-8208-7023-ad27-8fe9fe1b4c1b) with its 45 results.

## 3. Events, dates and subjects

**What there is.** Pages reporting a death on 11 September 1950 and the funeral that followed: the body lying in state in the Groote Kerk, the service and procession in Pretoria on 15 September, the train to Johannesburg and the cremation at Braamfontein, and later the scattering of the ashes on Smuts Koppie. Eight pages carry a printed dateline. Most carry none.

**The decision.** The funeral is a `rico:Activity`, *State funeral of General J.C. Smuts*, with three published parts joined by `rico:hasOrHadSubevent`. The death is an activity of its own, outside the funeral. Each has its dates (`rico:isAssociatedWithDate`) and places (`rico:isAssociatedWithPlace`). The Union Defence Force performed the service and procession (`rico:isOrWasPerformedBy`), and five people named in press reports took part in it (`rico:hasOrHadParticipant`), among them Sir Evelyn Baring, the United Kingdom's High Commissioner.

A page relates to these in two different ways. Page 1 has The Star as its creator (`rico:hasCreator`), and Smuts and his death as its subjects (`rico:hasOrHadSubject`). Smuts made nothing in this scrapbook; he is what it is about.

Every page keeps the date it can honestly claim, in words and in a form a machine can compare:

| What the page gives | Pages | Expressed as | Normalised |
|---|---|---|---|
| A printed dateline | 8 | Tuesday 12 September 1950 (printed dateline) | `1950-09-12` |
| Only the events it shows | 35 | c. 15-18 September 1950 (dated from the events shown) | a range |
| Neither | 2 | September 1950 | `1950-09-11/1950-09-30` |

The wide date stays on all 45 pages beside any closer one.

**Why.** Separate events let a reader ask which pages show the procession (17) or the cremation journey (14), which one long description of "the funeral" could not answer. Keeping the wording beside the normalised value shows how each date was reached: a dateline is evidence, and "dated from the events shown" is an inference, even when both end up as a day or two in September.

Where the sources disagree, the description says so. They differ on whether the cremation was on the 15th or the 16th, so that event runs over both days and its note records the disagreement. The dates of the lying in state are not confirmed: it is given as 12 to 15 September, the span between the death and the funeral, and is expressed in those words.

The scattering of the ashes shows the rule at its strictest. No source we hold dates it. OpenRiC's [Provenance and Event profile](/spec/profiles/provenance-event.html) requires every activity to carry a date, and we would not invent one, so it stays a draft. Two pages are about it, and the public record does not show that link until someone finds the date.

**Where you might decide differently.**
- The Star is recorded as the creator of page 1 because it is named there, but it created the *cutting*. Whoever pasted it in made the page, and that person is unknown. This sits awkwardly with example 1, which treats the page as the compiler's deliberate whole. Describing each cutting as its own Record would put the newspaper's authorship where it belongs.
- You could publish the scattering with a broad date such as "after 16 September 1950". That is true, and it would make the event visible. We held back because the range would have no closing date to rest on.
- The funeral's five named participants come from captions and reports. A stricter description would record each one's role, or cite the page that names them as evidence on the relation.

**How far to trust these relations.** The 166 relations to people, places and events were proposed from the pages' text and a research note. For this demonstration they were accepted in two batches, 54 and then 112, and were not checked one by one against their sources. The Workspace shows them as accepted; read them as a worked illustration, and check a relation before you cite it.

**Check it.** [The state funeral](https://workspace.openric.org/api/ric/v1/activities/01a1f4db-0889-7205-8683-81591e19c61e), [the service and procession](https://workspace.openric.org/api/ric/v1/activities/01a1f4db-07cc-7245-8556-2587f8011064), [the cremation journey](https://workspace.openric.org/api/ric/v1/activities/01a1f4db-080d-7165-8622-381e558aeac2), [the lying in state](https://workspace.openric.org/api/ric/v1/activities/01a1f4db-078e-7279-9831-8c10d8b7ddcf) and [the death](https://workspace.openric.org/api/ric/v1/activities/01a1f4db-075b-7297-abdb-3b3e48b174a0) as JSON-LD, and [page 1's RiC-O](https://workspace.openric.org/api/ric/v1/records/01a1f4da-cba3-739d-b65c-eced7038ee1a/export?format=turtle) for its creator, subjects and two dates.

## RiC-O 1.1 and the next version

OpenRiC and these examples use **RiC-O 1.1** (released 27 May 2025), the latest release. ICA-EGAD develops the next version in the open, on the RiC-O repository's `next-version` branch. Recent changes there include:

- *has author* extended to a Record Part ([#184](https://github.com/ICA-EGAD/RiC-O/pull/184), 19 November 2026), the RiC-O side of the RiC-CM 1.0.1 change;
- `rico:hasOrHadActivityOfType` and its inverse ([#182](https://github.com/ICA-EGAD/RiC-O/pull/182), 15 November 2026);
- a `scale` property ([#180](https://github.com/ICA-EGAD/RiC-O/pull/180), 19 November 2026);
- measurements as properties of their own (height, width, length, thickness, duration) and `physicalOrLogicalExtent` renamed `extent` (October 2026).

None of these is normative until ICA-EGAD releases them. OpenRiC does not use them yet; where it needed a concept first, it uses its own [`openricx:`](/ns/ext/v1.html) term and will bind it to the RiC-O term once released ([openric/service#12](https://github.com/openric/service/issues/12)). The [drift log](/drift-log.html) records what is tracked.
