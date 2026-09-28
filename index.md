---
layout: default
title: OpenRiC - Records in Contexts, made navigable
description: An open, free way to describe, explore and share archival records together with the people, activities, places and dates that give them context.
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Records in Contexts · open &amp; free</div>
    <h1>Records make sense in context.</h1>
    <p class="hero-lede">
      OpenRiC connects archival records to the people and organisations behind them, the activities that created them, and the places and dates that tie them together - so those connections can be followed across tools and institutions instead of living in one catalogue.
    </p>
    <div class="hero-cta">
      <a class="btn-primary" href="{{ '/demo/browse/' | relative_url }}">Explore real records →</a>
      <a class="btn-ghost" href="{{ '/wizard/' | relative_url }}">Model something ↗</a>
    </div>
    <p class="hero-sub"><a href="{{ '/for-developers.html' | relative_url }}">Build with OpenRiC</a> - the specification, API and conformance tooling.</p>
  </div>
</div>

## OpenRiC in 60 seconds

<div class="flow">
  <div class="flow-steps">
    <div class="flow-step"><strong>A record</strong><span>a file, a letter, a photograph, a recording</span></div>
    <div class="flow-arrow">→</div>
    <div class="flow-step"><strong>Someone made it</strong><span>a person, a family, an organisation</span></div>
    <div class="flow-arrow">→</div>
    <div class="flow-step"><strong>Doing something</strong><span>an activity, in the course of a function</span></div>
    <div class="flow-arrow">→</div>
    <div class="flow-step"><strong>Somewhere, at some time</strong><span>a place and a date</span></div>
  </div>
  <p class="flow-note">Archival description has always implied those links. Traditionally they sit in prose, readable by a person and invisible to everything else. RiC - the International Council on Archives' model, replacing ISAD(G), ISAAR(CPF), ISDF and ISDIAH with one connected picture - makes them explicit. OpenRiC is an open contract for publishing and exchanging that picture, so any conformant tool can follow the links. Rather like IIIF for images: nobody had to agree on storage, only on how to ask.</p>
</div>

## Try it now

<div class="task-cards">
  <a class="task-card" href="{{ '/demo/browse/' | relative_url }}">
    <div class="task-card-icon">📚</div>
    <div class="task-card-title">Browse a collection</div>
    <p>A real archival dataset as a catalogue. Search it, filter by type, open any record. No account, no server address, no API key.</p>
    <span class="task-card-go">Open Browse →</span>
  </a>
  <a class="task-card" href="https://viewer.openric.org/">
    <div class="task-card-icon">🗺</div>
    <div class="task-card-title">Follow a relationship</div>
    <p>The same data as a graph. Start at a record and walk out to its creator, the activity behind it, and where it happened.</p>
    <span class="task-card-go">Open the Graph Explorer ↗</span>
  </a>
  <a class="task-card" href="{{ '/wizard/' | relative_url }}">
    <div class="task-card-icon">🧭</div>
    <div class="task-card-title">Model a real scenario</div>
    <p>Describe what you actually hold and work through the decisions, with the reasoning shown rather than assumed.</p>
    <span class="task-card-go">Open the wizard →</span>
  </a>
</div>

## Why it is worth the trouble

<ul class="why">
  <li><strong>The context survives the system.</strong> Relationships live in the data, not in one vendor's schema, so they still mean something after a migration.</li>
  <li><strong>Description already written maps forward.</strong> ISAD(G), ISAAR(CPF), ISDF and ISDIAH records have a documented route into RiC - see the <a href="{{ '/spec/mapping.html' | relative_url }}">mapping specification</a>.</li>
  <li><strong>Conformance is testable, not asserted.</strong> A black-box probe, SHACL shapes and a fixture pack decide whether an implementation actually conforms.</li>
  <li><strong>It is a contract, not a product.</strong> Any system can implement it and no system is privileged by it. Specification CC-BY 4.0, reference code AGPL-3.0.</li>
</ul>

<p>What OpenRiC deliberately does not try to replace - IIIF, Linked Art, CIDOC CRM, Wikidata, or the catalogue you already run - is set out in <a href="{{ '/about.html' | relative_url }}">About</a>.</p>

## Where to go next

<div class="task-cards">
  <a class="task-card" href="{{ '/learn.html' | relative_url }}">
    <div class="task-card-icon">📖</div>
    <div class="task-card-title">Archivists &amp; researchers</div>
    <p>What RiC is, which entity fits what you have, and the distinctions that cost people the most time.</p>
    <span class="task-card-go">Learn &amp; model →</span>
  </a>
  <a class="task-card" href="{{ '/for-developers.html' | relative_url }}">
    <div class="task-card-icon">🧑‍💻</div>
    <div class="task-card-title">Developers &amp; implementers</div>
    <p>The HTTP contract, JSON-LD, profiles, SHACL, OpenAPI, OAI-PMH and the conformance probe.</p>
    <span class="task-card-go">Build with OpenRiC →</span>
  </a>
  <a class="task-card" href="{{ '/for-institutions.html' | relative_url }}">
    <div class="task-card-icon">🏛️</div>
    <div class="task-card-title">Institutions &amp; decision-makers</div>
    <p>What adopting this commits you to, what is production versus draft, and what is honestly still missing.</p>
    <span class="task-card-go">Read the brief →</span>
  </a>
</div>

<div class="evidence">
  <h2>Technical state</h2>
  <ul class="evidence-items">
    <li>Specification <strong>v{{ site.data.version.version }}</strong></li>
    <li>12 profiles, 7 normative</li>
    <li>RiC-O 1.1 conformant</li>
    <li><a href="{{ '/ric-baseline.html' | relative_url }}">Standards baseline</a></li>
    <li><a href="{{ '/proof.html' | relative_url }}">Proof of implementation</a></li>
    <li><a href="{{ '/drift-log.html' | relative_url }}">Known drift</a></li>
    <li><a href="https://github.com/openric/spec">GitHub</a></li>
  </ul>
</div>
