---
layout: default
title: Learn and model
description: What Records in Contexts is, how to decide which entity fits what you have, and worked examples of modelling real archival material.
permalink: /learn.html
---

# Learn and model

Records in Contexts is a model, not a format. The hard part is rarely the syntax - it is deciding whether the thing in front of you is a record or a record set, an activity or a function, an agent or a corporate body.

<div class="task-cards">
  <a class="task-card" href="{{ '/wizard/' | relative_url }}">
    <div class="task-card-icon">🧭</div>
    <div class="task-card-title">Model something</div>
    <p>Describe what you actually have and the wizard works through the decisions with you, saying <em>why</em> each entity fits or does not, and building the model as it goes. Twenty-one worked scenarios, including an unknown creator, a chain of custody and a closed record.</p>
    <span class="task-card-go">Open the wizard →</span>
  </a>
  <a class="task-card" href="https://ric.theahg.co.za/reference/ric-cm/">
    <div class="task-card-icon">🗂</div>
    <div class="task-card-title">The model, entity by entity</div>
    <p>Every RiC-CM entity, attribute and relation, navigable. The reference when you know roughly what you are looking for and need the precise definition.</p>
    <span class="task-card-go">Open the model navigator ↗</span>
  </a>
  <a class="task-card" href="{{ '/for-archivists.html' | relative_url }}">
    <div class="task-card-icon">📖</div>
    <div class="task-card-title">RiC in plain language</div>
    <p>What changed from ISAD(G), ISAAR(CPF), ISDF and ISDIAH, why the four became one connected model, and what that means for description you already hold.</p>
    <span class="task-card-go">Start reading →</span>
  </a>
</div>

## Where people get stuck

These are the distinctions that cost the most time. Each is a real decision, not a naming preference.

| The question | The short answer |
|---|---|
| Record or Record Set? | A Record Set groups; a Record is the thing described. A file of correspondence is a set whose members are records. |
| Record or Record Part? | A part has no independent existence - a single letter within a bound volume is a part, not a record in its own right. |
| Activity or Function? | A Function is ongoing responsibility; an Activity is something that happened. "Licensing" is a function, "issued licence 4021" is an activity. |
| Agent or Corporate Body? | Agent is the umbrella. Person, Family and Corporate Body are its kinds - describe the kind you actually have. |
| Record or Instantiation? | The Record is the intellectual thing; the Instantiation is a physical or digital manifestation of it. One record, many instantiations. |

The [model navigator](https://ric.theahg.co.za/reference/ric-cm/) carries the formal definitions, and the [mapping specification](/spec/mapping.html) says how each maps from the legacy ICA standards.

## The standards underneath

OpenRiC targets a specific version of each RiC document, and the [RiC baseline page](/ric-baseline.html) names all four in one place. In short: RiC-O 1.1 is the normative target, and RiC-AG 0.1 is the upstream authority for the crosswalks from the legacy standards.

## Once you have modelled something

Publishing it is [Build](/for-developers.html). Seeing what modelled data looks like in practice is [Explore](/explore.html).

## Further reading

These four works are listed on the ICA's RiC Resource List. They range from a full textbook to a short sceptical note. We have marked where a work is not free to read.

**Tetsuji Kuboyama, *Records in Contexts: An Introduction* (Gakushuin University, 2026).**
A free textbook (CC BY 4.0) for archivists meeting RiC for the first time. It works from all four parts of the standard and comes with sample data and SPARQL queries you can run. Its reading guide tells a descriptive archivist which chapters to read closely and which can wait. It is not a cheerleader: section 3.6 sets out what RiC's freedom costs, from more judgement and harder consistency to immature tools. It also notes that the shared identifiers RiC needs to work across institutions mostly do not exist yet (section 7.6).
[English edition (PDF)](https://tkub.github.io/edu/ric/en/ric-introduction-en.pdf) - [Japanese edition](https://tkub.github.io/edu/ric/)

**Richard Dancy, "Waiting for RiC: The Release of Records in Contexts, version 1.0", *Archivaria* 98 (2024), 166-191.**
If you want the sceptic's case, start here. Dancy, a Canadian archivist who spent years on RAD, calls RiC a commendable effort but argues that its benefits stay theoretical until software exists - "if the proof is in the pudding, RiC is just an ingredients list" (p. 178). He also argues that RiC lacks a content standard and so cannot yet do the practical job of the standards it replaces. He picks out real gaps, such as the missing repository entity and single, non-repeatable histories that leave no room for other voices. His advice is practical: map your existing finding aids to RiC and see what breaks.
[Read the article (free PDF)](https://archivaria.ca/index.php/archivaria/article/view/13997)

**Anouk Stephano, "A recontextualization of provenance: Records in Contexts and the principle of provenance", *Archival Science* 24 (2024), 783-800.**
A theoretical paper on one question: what happens to the principle of provenance under RiC. According to its abstract, RiC's documentation says contradictory things about provenance, and describing RiC as an "expansion" of the principle is misleading. The article is behind a paywall; we have read only the abstract.
[doi:10.1007/s10502-024-09460-y](https://doi.org/10.1007/s10502-024-09460-y)

**Merel Geerlings, *Records in Contexts: Searching and Finding Archival Records* (thesis, Archival science B, Amsterdam University of Applied Sciences, 2021).**
Written while the Stadsarchief Amsterdam was building a RiC-based search platform, this thesis asks whether RiC would make archives easier to search than ISAD(G) does. It gathers what Dutch user studies say people want, analyses a month of search terms typed into the city archive's search box, and sketches a knowledge-graph interface. Her answer is "to a large extent", with caveats. RiC does nothing to explain why a search gave the results it did, and its entity names may confuse the public. She advises keeping the classic inventory tree for now. Her designs were not tested with users.
[English translation (PDF)](https://assets.amsterdam.nl/publish/pages/1002802/thesis_records_in_contexts_merel_geerlings_definitive_1.pdf) - [Dutch original (PDF)](https://assets.amsterdam.nl/publish/pages/1002802/scriptie_records_in_contexts_merel_geerlings_definitief.pdf)
