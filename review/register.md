---
layout: default
title: OpenRiC - Review register
description: Every review of OpenRiC so far - who reviewed, what they found, how the project responded, and what is still unresolved.
permalink: /review/register/
kind: current
---

# Review register

Every review OpenRiC has received, what it found, what we did about it, and what is still open. A reviewer is named only with their permission; otherwise the entry says "not named". The [review page](/review/) explains how to add to it, and [known issues](/spec/known-issues.html) holds the problems we know about and have not fixed.

None of these reviews is the formal external technical review the [Standard Acceptance Gate](https://github.com/openric/spec/blob/main/docs/gates/S-GATE.md) requires: that reviewer is not yet appointed ([K-1](/spec/known-issues.html)).

## Reviews

| # | Date | Reviewer | Scope | Main findings | Response | Status |
|---|---|---|---|---|---|---|
| R-1 | April 2026 | Not named (a reviewer from the ICA-EGAD community) | RiC-O conformance of the terms OpenRiC emits | Terms in the RiC-O namespace that RiC-O 1.1 does not define | The [RiC-O 1.1 audit](/audit/ric-o-1.1-audit.html); every non-RiC-O term moved to the `openricx:` extension namespace (v0.37.0) | Resolved |
| R-2 | 14 Oct 2026 | Not named | openric.org site and the plan for a full application | Contradictory profile counts and hand-typed figures; a stale drift log; a demonstration record presented with a real institution's name; "contract" and "application" confused; keys in browser storage, open anonymous writes and a wide CORS policy on the reference service | Site figures rendered from release data and checked in CI (v0.44.0 to v0.46.0); evidence labels; the application named OpenRiC Workspace and separated from the specification; service security fixes (v0.17.x) | Resolved, except the second independent implementation ([K-6](/spec/known-issues.html)) |
| R-3 | 15 Oct 2026 | Not named | Website deep review and enhancement plan | Getting-started writes not safe to copy; status unreadable without JavaScript; demonstration data unlabelled in the viewer; no SPARQL probe | Safe getting-started and minimal-server writes, a no-script status snapshot, demonstration labels, a SPARQL Access probe | Resolved |
| R-4 | 19 Oct 2026 | Not named | Developers, status and institutions pages | OpenAPI 3.1 and 3.0 both claimed; "four documents" against seven; release and tested versions confused; institutional claims stronger than the evidence | Each corrected (v0.49.3) | Resolved |
| R-5 | 19 Oct 2026 | Not named | How review and evaluation work | No single entry point for reviewers; RiC and OpenRiC easily confused; conformance reporting not explicit about skips; no way to test without AHG's code | [Review page](/review/), [RiC and OpenRiC compared](/ric-baseline.html#ric-and-openric), status-page sections on version alignment, what a pass proves and every check that did not pass, and [evaluating independently](/guides/evaluate-independently.html) (v0.50.0) | Resolved |
| R-6 | 19 Oct 2026 | Comparison by the maintainer against independently published work: Matthew Bruton's ISAD(G) to RiC crosswalk (MIT), the RiC-O Converter by Sparna and the Archives nationales de France Lab (CeCILL-B), and the biax and ITDT extension ontologies | The mapping and the extension ontology | Literal values on RiC-O object properties (dates, date type, legal status); `rico:hasOrHadLanguage` used on record sets outside its domain; a non-existent finding-aid IRI; a false claim of alignment with the converter; extension terms RiC-O 1.1 already covers | Fixed in specification v0.50.0 and service v0.17.18; four extension terms deprecated and the rest anchored to RiC-O in v0.50.1 | Resolved |
| R-7 | 19 Oct 2026 | Not named | Version figures, governance and known issues | Pages showing different versions; the v1.0 gate stated two ways; the reference service shown as tested against an old release; known issues keyed to an old baseline | Version mismatch traced to page caching during two releases, not to the data; a hand-typed figure removed; governance separates the v1.0 gate from maturity goals; known issues given a status per entry (v0.50.2) | Resolved |
| R-8 | 19 Oct 2026 | Not named | Governance, review evidence, conformance claims, known issues | The developers page still listed three v1.0 conditions; review findings not public; Round-Trip Editing reported as a pass while its writes are skipped; open, resolved and accepted issues mixed together | The single v1.0 gate stated the same way on every page; this register; skipped write checks reported as "not verified"; known issues split into open, accepted and resolved | Resolved |

## Unresolved objections

What reviewers have raised that OpenRiC has not resolved, and why.

| Raised in | Objection | Where it stands |
|---|---|---|
| R-2 | OpenRiC has no implementation outside the organisation that wrote it, so its claims to portability are not yet tested. | Accepted as the central gap. It is the [v1.0 gate](/governance.html#release-gates-and-maturity-goals) and known issue [K-6](/spec/known-issues.html). |
| R-2 | Every fixture is synthetic or comes from the reference service's demonstration data. | Open, [K-7](/spec/known-issues.html): it closes when an institution contributes publishable data. |
| R-5 | Nothing about RiC's usability for the public has been tested with users. | Open. The [review page](/review/#3-archival-usability) asks reviewers for exactly this, and summarises what earlier research found. |
| R-4 | The reference service still publishes its own OpenAPI document as version 3.0.3, while the specification's contract is 3.1. | Open. The 3.1 contract is the normative one; the service's document is to be regenerated as 3.1. |
