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
    <p>Describe what you actually have and the wizard works through the decisions with you, saying <em>why</em> each entity fits or does not, and building the model as it goes.</p>
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
