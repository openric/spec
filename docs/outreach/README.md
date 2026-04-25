# OpenRiC outreach drafts

Email/discussion-thread drafts for direct community outreach, drafted by the project to be sent by the maintainer (Johan Pieterse). Each file is a paste-ready body with a recommended subject, recipient, target outcome, and "do not send before" gating.

| Target | Outcome we want | Status |
|---|---|---|
| [Sparna (Garance build team)](sparna-second-implementation.md) | Sanity-check our SPARQL Access draft profile; consider Garance as a second implementation on that profile | draft, gated on B.2 (SPARQL Access fixtures + SHACL shipped) |
| [Damigos / Ionian University](damigos-second-implementation.md) | Run our conformance probe against the Corfu Criminal Court Archives; potentially join as second implementer | draft, ready to send |

## Why outreach matters

The OpenRiC v1.0 governance gate (`governance.md:117`) requires:

1. **A second independent implementation** passing conformance.
2. **One external institution** committing to deploy.
3. **2–3 active non-maintainer contributors** with sustained engagement.

All three are zero today. None is solvable by code; all three require sustained outreach to the EGAD-adjacent community. The two drafts in this directory are the highest-value outreach targets the [external-signals memory](https://github.com/openric/spec/tree/main/.memory) currently identifies.

## Tone guidance

- Lead with what they're doing well; frame OpenRiC as complementary, not competitive.
- Cite their work specifically (paper, repo, tag, version) — generic outreach reads as form-letter.
- Make the ask concrete and small (sanity-check a draft, run one probe, consider one profile).
- No hard pitch on the first contact. Offer; do not ask for commitment.
- Sign as Johan personally, not "OpenRiC project" — community engagement is person-to-person.

## When to send

Sequence matters:

1. **First**: ship the technical artifacts the outreach refers to. A "would you sanity-check our SPARQL Access profile" message is hollow if the profile has no fixtures or SHACL. v0.38.0 ships those — send only after that release is on origin.
2. **Then**: send Sparna first (lower-stakes — they're a vendor, sanity-checking is their day job). If positive, send Damigos next.
3. **Hold**: ResearchSpace / SAPA, Holocaust KG, Min-ji Kim drafts not written yet — gated on positive responses from the first two.
