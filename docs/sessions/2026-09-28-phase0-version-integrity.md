# 2026-09-28 - OpenRiC Phase 0: version integrity, drift guard, RiC baseline

Commit `2421926` on `openric/spec`. Closes #6, #7, #8, #9; #5 reopened for one sub-item.

## What prompted it

Two planning documents were handed over - a "RiC Monday Action Plan" and a "UX & Streamlining Review", both dated September 2026. Neither had been written against the repositories, and that mattered:

- The Monday plan asked for work that already exists. The `openricx:` extension register is published at `ns/ext/v1.md` with 48 terms and a machine-readable Turtle file; the no-minting-in-RiC-O commitment is standing policy; RiC-AG v0.1 has been first-class since v0.38.1; `drift-log.md` already tracks upstream exactly as the plan's "watch list" proposes. Its workstream A (assertion provenance) is substantially covered by the **Inferred-Provenance** draft profile shipped in v0.43.0.
- The UX review's headline P0 named the wrong target. It says to synchronise the site on **v0.37.0** and calls that the current state. The actual current version is **0.43.10**. Following the document literally would have entrenched a version two generations stale.

Corrections recorded in `openric/service` at `docs/plans/2026-09-28-action-plan-corrections.md`.

## The real defect

`version.json` already existed and was already correct at 0.43.10. The UX review's recommendation to "define one source of truth, for example version.json" had already been done.

**Nothing consumed it.** There was no `_data` directory, no page referenced `site.data`, and every version string on the site was typed by hand into prose. That is why three generations coexisted: 0.43.10 in the file, v0.37.0 on home / spec / README / for-developers, and v0.2.0 plus retired L1-L4 conformance wording on governance and for-institutions.

Two pages were not merely stale but wrong. `faq.md` claimed "Specification at v0.2.0 frozen"; `architecture.md` claimed "Current tagged release: v0.2.0". Both rewritten against verified state.

## What shipped

- `_data/version.json` mirrors `version.json` so Jekyll can render `site.data.version.*`. `bin/release` writes both; CI fails if they disagree. The root file stays the published `https://openric.org/version.json` endpoint.
- Every current-facing page renders the value instead of stating it.
- `README.md` hardcodes it, because README is in `_config.yml`'s `exclude` and cannot use Liquid. `bin/release` rewrites that line by regex and CI asserts it.
- Conformance narrative moved off L1-L4 in four places. Naming L1-L4 while explicitly marking it legacy stays allowed - the `level` field still exists in responses.
- New `/ric-baseline.html` naming RiC-FAD 1.0, RiC-CM 1.0, RiC-O 1.1, RiC-AG 0.1 in one table. Linked from the primary nav.
- CHANGELOG backfilled for v0.43.1 to v0.43.10, ten releases that shipped with no entries - which is why the v0.37.0 pages went unnoticed for three months.

## The lesson worth carrying

**A naive version-drift checker is unusable.** The obvious design - flag every semantic version that is not the current one - produced hundreds of false positives: CIDOC-CRM 7.1.3, Node 18.14.1, per-profile versions (independent by design, see core-discovery Q8), sample API payloads, and the legitimate roadmap history on the developer page.

`bin/check-versions.py` inverts it. It looks for **currency claims** - "is current", "Current version", "Current tagged release", "currently tracking", "OpenRiC is at", hero eyebrows, "publicly claim" - and checks only the versions on those lines. Plus the root/`_data` equality check and the README banner. Signal instead of noise, and green on the first real CI run.

## Left deliberately undone

The **Compatibility component** (spec version shown alongside reference-service version). Hardcoding the service's v0.17.0 into the spec repo recreates the drift one layer down. It needs the service publishing its own version at a URL the site reads. #5 stays open for it.

Note the service and spec carry **separate version lines on purpose** - service 0.17.0 against spec 0.43.10 is not drift, and the site should say so rather than merge them.

## Operational note

`openric-spec/version.json` is mode 0620 root:root, so it is unreadable to non-root tooling and git cannot hash it. It needs `chmod 0644`. Its `description` field still contains an em dash, which the house style forbids; flattening it is blocked on the same permission.
