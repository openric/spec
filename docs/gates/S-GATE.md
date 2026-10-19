# Standard Acceptance Gate (S-GATE) - sign-off record

Draft prepared 16 October 2026 for Dr Johan Pieterse, Standard owner; baseline set 19 October 2026. Programme plan V4, section I.8.

Part II (OpenRiC Workspace) does not start until this record is signed. Signing freezes an implementable release baseline; corrections, security fixes and version maintenance continue afterwards under change control and do not reopen Part I.

## How this record is signed

1. The baseline release below is cut, tagged and bundled.
2. Each signer reads the evidence and records their decision in the sign-off table, with the date in UTC.
3. Signers with a GitHub account approve the pull request that completes this record; the approval is the signature. A signer without one sends an email to Dr Johan Pieterse stating the release and their decision, and the email is filed in the incident-style evidence folder with its hash noted here.
4. The gate is signed when the last approval is in and the pull request is merged. The merge commit identifies the gate.
5. On that day a reminder is set for deleting the full database backup 90 days later, as the S0 retention decision requires.

## Baseline release

Chosen by Dr Johan Pieterse on 19 October 2026: specification **v0.48.0**. It carries the corrections of 15 to 19 October, the K-12 schema tightening of v0.47.0, and the validation fixes of v0.48.0 that came out of testing against real institutional RiC-O 1.1 data.

| Field | Value |
|---|---|
| Release | v0.48.0, 2026-10-19 (https://github.com/openric/spec/releases/tag/v0.48.0) |
| Tag commit | `39cc48a9f54335f1172cadf11d51e016e7ba5682` |
| Tag signature | SSH, ED25519 `SHA256:dTmsTQEuuSikPeM3TZzlB6/KQQQWJylRFwWPboID0nY`; verifies with `git tag -v` against that key. GitHub shows it as unverified until the key is registered there. |
| Bundle | `openric-spec-v0.48.0.tar.gz` on the GitHub release |
| Bundle SHA-256 | `92899d9d9dae3ddc4080a5a4268b3cf481c44ad92ea494d8e49d5d7d1eff71ab` (checked by download, 19 October) |
| Reference service at baseline | v0.17.15; it still reports that it verifies against spec 0.46.0, so a service release must re-verify against v0.48.0 before the gate is signed |

## Acceptance criteria and evidence

| Criterion | Evidence | State |
|---|---|---|
| **Safety gate S0 closed** | `openric/service` `docs/plans/2026-10-15-s0-closure-record.md`: incident record and impact decision; anonymous production writes closed; authorisation and key fixes tested (`ApiSecurityTest`); backup restore-tested on 14 October; rollback archives for every release v0.17.1 to v0.17.13 in the incident folder with checksums; evidence retention accepted 15 October. The 37 removed ids re-checked after the 16 October reset: all 404. | Met |
| **Contract internally coherent** | The v0.48.0 tag carries `release.json`, the profiles, JSON Schemas, SHACL shapes, fixtures (manifest with provenance labels), the API contract and the implementer guide. CI checks versions, links, the contract (OpenAPI 3.1, examples validated against schemas), the vocabulary and the fixture manifest. K-12 closed in v0.47.0. Testing against real institutional data led to v0.48.0's fixes; two questions from that test (how strict naming and record rules should be) are open and can be accepted as residuals. | Met |
| **Public claims supportable** | Demonstration-data labels on Browse, the graph demo, Explore, the viewer and the evidence pages; current and legacy separated (page kinds, versions page, conformance legacy appendix); `/status/` shows declared against tested, dated, readable without JavaScript; the daily read-only probe publishes to the `conformance-results` branch (first run 15 October 15:21 UTC). | Met; the scheduled daily run has not yet fired on its own |
| **Release reproducible** | Release tags protected by the GitHub ruleset "Protect release tags"; the baseline tag is signed (v0.47.0 was the first); release bundle with SHA-256 attached by `bin/release` (v0.48.0 verified by download); CI green on a clean runner, including a full GitHub Pages build, an accessibility check and the getting-started commands. Open: GitHub shows the signature as unverified until the signing key is registered there. | Met, apart from GitHub's verification of the signature |
| **Implementable independently** | The minimal server (standard library only, no Heratio) passes Core Discovery in CI, and CI runs the getting-started guide's commands against it exactly as published. Open: an external developer or reviewer has not yet followed the quick-start and run a conformance test themselves. | Open: external run |
| **Governance and residual risks accepted** | Version, deprecation and approval policy (`spec/change-control.md`, in force since 15 October); licence review (K-5, software AGPL-3.0, specification CC BY 4.0); known-issues log (`spec/known-issues.md`, also the residual issue register); named owner (Dr Johan Pieterse). Open: the external technical review report, our responses, and formal sign-off. | Open: reviewer opinion and sign-off |

## Residual risks to accept or close at signing

From the known-issues log at the baseline release: K-1 (no external review yet - must be closed, not accepted), K-2 (unsigned tags before the baseline), K-3 (bundles only from v0.46.0), K-5 residual (demonstration media in the shared database not reviewed item by item), K-6 (no independent implementation - an adoption milestone, not a gate condition), K-7 (all fixtures synthetic), K-9 (reference service on a database shared with Heratio, reset nightly), K-10 (Provenance & Event not demonstrable on the current data), K-11 (accessibility smoke test only), K-12 (legacy shapes in two schemas), and the open drift-log rows.

## Sign-off

| Role | Name | Decision | Date (UTC) |
|---|---|---|---|
| Standard owner | Dr Johan Pieterse | | |
| External technical reviewer | | | |
| Security and production acceptance | | | |

| Field | Value |
|---|---|
| Release ID and hash | |
| Residual risks accepted | |
| Gate merge commit | |
