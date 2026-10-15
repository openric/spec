---
layout: default
title: OpenRiC - Known issues
description: Known issues and residual risks in the OpenRiC specification and its reference service, each with its owner and what closes it.
kind: current
---

# Known issues

Last updated 2026-10-15, against specification v{{ site.data.version.version }}.

This is the known-issues log the Standard Acceptance Gate (S-GATE, programme plan V4) asks for: problems we know about and have not fixed, why, and what closes each. When the external technical review reports, every finding we decide not to fix is added here with the reason, so this page is also the residual issue register. Modelling questions that are still open are kept in the mapping's [open issues](mapping.html#12-open-issues), not repeated here. Security problems are not listed here; report them privately as [SECURITY.md](https://github.com/openric/spec/blob/main/SECURITY.md) describes.

Owner of every entry, unless it says otherwise: Dr Johan Pieterse, Standard owner.

## Specification and release

| # | Issue | Since | Closes when |
|---|---|---|---|
| K-1 | No external technical review yet. Everything has been written and checked inside one organisation. The [review brief](https://github.com/openric/spec/blob/main/docs/reviews/2026-10-external-technical-review-brief.md) is ready; no reviewer is appointed. | 2026-10-15 | A dated reviewer report, our responses and this register exist (plan V4, S2.5). |
| K-2 | Release tags up to and including v0.46.0 are unsigned. Tags are annotated, and change control asks for signed tags once a key is set up. | 2026-10-15 | The first release after signing was set up, expected v0.47.0, carries a signed tag. Older tags stay unsigned. |
| K-3 | Only v0.46.0 has a downloadable bundle with a SHA-256 checksum. Earlier GitHub releases have none; their content is still fixed by the git tag. | 2026-10-15 | Not planned for older releases. Every release from v0.46.0 carries one. |
| K-4 | The v0.46.0 changelog and mapping issue O-8 said `openricx:description` stays "until v0.47.0". [Change control](change-control.html#deprecation) keeps a deprecated item for at least one further minor release, so the earliest removal is v0.48.0. The changelog, O-8, the mapping row for ISAD(G) 3.3.1 and the record schema are corrected. | 2026-10-15 | Fixed in the text; recorded here so nobody plans on the earlier date. |
| K-5 | The licence review of specification artefacts, copied code, fixtures, images and example datasets has not been done (plan V4, S4). Fixtures carry rights labels, reviewed on 2026-10-15. | 2026-10-14 | A recorded licence review. |
| K-12 | `schemas/service-description.schema.json` still accepts the legacy `openric:Service` envelope with L1 to L4 levels, and does not require `openric_conformance`. Every current page, profile and the reference service use `openric_conformance.profiles`. | 2026-10-15 | The next minor release tightens the schema, with a migration note, as change control requires for a breaking change. |

## Evidence and adoption

| # | Issue | Since | Closes when |
|---|---|---|---|
| K-6 | There is no independent implementation. The reference service and the planned OpenRiC Workspace are both from the same organisation, so neither counts. | 2026-10-14 | A second implementation built outside AHG passes at least one profile. It is recruited actively but does not block the first usable release. |
| K-7 | Every fixture is synthetic: 31 captured from the reference service's demonstration data, 5 written by hand. No data comes from an outside institution. | 2026-10-15 | An institution contributes data that can be published, labelled `independent`. |
| K-8 | Closed 2026-10-15. The reference service reported that it verified against specification 0.44.0. Since service v0.17.12 it reports 0.46.0: the probe has not changed since 0.45.0, which the service passed 78 of 78 on staging, and 0.46.0 only adds record terms the service has sent since v0.17.11. | 2026-10-15 | Closed by service v0.17.12. |

## Reference service

| # | Issue | Since | Closes when |
|---|---|---|---|
| K-9 | The reference service at ric.theahg.co.za reads from a database it shares with Heratio, and that database is reset nightly from a demonstration snapshot. The specification, the probe and the [minimal server](https://github.com/openric/spec/tree/main/examples/minimal-server) do not depend on it: CI proves the minimal server passes Core Discovery with no Heratio present. | 2026-10-14 | The reference service has its own database (plan V4, Part II). |
| K-10 | The service does not declare Provenance & Event. The probe has a section for it, but no declared server runs it. | 2026-10-15 | The service declares the profile and passes it. |

## Accessibility

| # | Issue | Since | Closes when |
|---|---|---|---|
| K-11 | Accessibility is checked by a smoke test only: axe at WCAG 2 AA on the thirteen key pages in `bin/a11y-pages.txt`, in CI since 2026-10-15. The graph viewer and the modelling wizard have not had a full WCAG 2.2 AA audit. | 2026-10-15 | A recorded WCAG 2.2 AA audit of the graph viewer and wizard. |
