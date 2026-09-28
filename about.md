---
layout: default
title: About OpenRiC
description: What OpenRiC is for, who runs it, how decisions get made, what it does not replace, and what an institution is actually committing to.
permalink: /about.html
---

# About OpenRiC

OpenRiC is an open contract for publishing and exchanging Records in Contexts data. Any archival system can implement it; no system is privileged by it. The specification is CC-BY 4.0 and the reference code is AGPL-3.0.

The comparison that explains it fastest is IIIF. IIIF did not tell anyone how to store images - it agreed on how to ask for them, and the tooling followed. OpenRiC does that for archival description and its context.

<div class="task-cards">
  <a class="task-card" href="{{ '/for-institutions.html' | relative_url }}">
    <div class="task-card-icon">🏛️</div>
    <div class="task-card-title">For institutions</div>
    <p>What adopting this commits you to, what it does not, and what is production versus draft. Non-technical.</p>
    <span class="task-card-go">Read the brief →</span>
  </a>
  <a class="task-card" href="{{ '/governance.html' | relative_url }}">
    <div class="task-card-icon">⚖️</div>
    <div class="task-card-title">Governance</div>
    <p>Who decides, how a change is proposed and accepted, the compatibility policy, and what has to be true before v1.0.</p>
    <span class="task-card-go">How decisions get made →</span>
  </a>
  <a class="task-card" href="{{ '/ric-baseline.html' | relative_url }}">
    <div class="task-card-icon">📐</div>
    <div class="task-card-title">Standards baseline</div>
    <p>The exact RiC versions targeted, the rule against minting terms in the RiC-O namespace, and how upstream is tracked.</p>
    <span class="task-card-go">See the baseline →</span>
  </a>
</div>

## What OpenRiC does not replace

Worth stating plainly, because an access contract is easy to mistake for a land grab.

- **IIIF** owns presentation and delivery of digital representations. OpenRiC links to a Manifest; it does not reimplement one.
- **Linked Art and CIDOC CRM** own museum and cultural-object semantics. Where they overlap with RiC the answer is a documented mapping, not forcing foreign semantics into RiC-O.
- **Wikidata** owns shared external identity. OpenRiC reconciles against it rather than competing with it.
- **The standards you already run.** ISAD(G), ISAAR(CPF), ISDF and ISDIAH description maps forward; it does not have to be rewritten first.
- **Your catalogue.** OpenRiC is a contract over data, not a system to migrate into.

## Honest state of things

One reference implementation, live and operating against a real archive. One operational consumer. Twelve profiles defined, seven of them normative. A conformance probe, a validator, JSON Schemas, SHACL shapes and a fixture pack.

What is missing is the thing that matters most for a standard: **a second independent implementation**, and an external institution committing to deploy. Those are explicit gates on v1.0 rather than aspirations, and they are written into [governance](/governance.html). The [drift log](/drift-log.html) records where the reference service currently lags the specification, including the parts that are awkward to admit.

## Related work

Other RiC implementations, the ICA-EGAD tooling OpenRiC tracks, and the upstream proposals filed from this project are on [related implementations](/related-implementations.html). Contributions made back to RiC-O - on agent roles in relations, language on relations, SHACL and a PROF profile - are linked from there too.

## Get in touch

Questions about the spec, the API, conformance or modelling go to [Ask a question](/ask/), which reaches the maintainers directly. Anything that belongs in the open goes to [the specification repository](https://github.com/openric/spec).

Maintained by Johan Pieterse, The Archive and Heritage Digital Commons Group, South Africa.
