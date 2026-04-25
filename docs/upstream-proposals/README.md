# Upstream proposals to ICA-EGAD/RiC-O

Drafts of GitHub issue / discussion bodies to be opened against [`ICA-EGAD/RiC-O`](https://github.com/ICA-EGAD/RiC-O) for consideration in a future RiC-O release.

These are drafts — the maintainer (Johan Pieterse / OpenRiC) opens the actual issues. Each file in this directory is a paste-ready issue body with rationale, suggested IRI, and OpenRiC's interim placement.

| Proposal | OpenRiC interim term | Status |
|---|---|---|
| [hasAppraisalInformation](hasAppraisalInformation.md) | `openricx:hasAppraisalInformation` | draft, ready to file |
| [containsPersonalData](containsPersonalData.md) | `openricx:containsPersonalData` | draft, ready to file |
| [ContactPoint class + address fields](ContactPoint.md) | `openricx:ContactPoint` + `openricx:contact` + 6 address properties | draft, ready to file |

**Withdrawn** (resolved canonically): `hasFindingAid` — now expressed as `rico:isOrWasDescribedBy` + `rico:hasDocumentaryFormType <…#FindingAid>` per Florence Clavaud's KM Q&A #1 thread.

## Filing protocol

1. Open an Issue (not a PR) against `ICA-EGAD/RiC-O`.
2. Paste the body from the relevant `.md` file in this directory.
3. Use the title as suggested at the top of each draft.
4. Cross-link from the OpenRiC [audit](../../audit/ric-o-1.1-audit.html) §F (upstream proposals) once the issue URL is known.
5. Update the table above with the issue URL + status.

## Why these three

The OpenRiC namespace remediation (spec v0.37.0) moved 48 terms from `rico:` to `openricx:`. Of these, most are pragmatic API/protocol shapes (List envelopes, address fields, etc.) that don't belong upstream. The three above are different — they have **genuine archival semantics that RiC-O 1.1 simply doesn't model yet**, and that other RiC-O implementations would also benefit from. Proposing them upstream is the cleanest way to retire the openricx prefix on those specific terms over time.
