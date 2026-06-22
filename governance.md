---
layout: default
title: OpenRiC - Governance
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Governance · draft · community input welcome</div>
    <h1>How OpenRiC evolves</h1>
    <p class="hero-lede">
      OpenRiC is run as an open specification with visible governance, not as a vendor product. This page describes who stewards the spec, how changes are proposed, how implementations influence decisions, and how external collaborators can take part.
    </p>
  </div>
</div>

## Current state

OpenRiC is at **v0.2.0** - a stable spec with one reference implementation, a live toolchain (viewer, capture, API explorer, conformance probe), and one operational consumer (Heratio). The spec is published under CC-BY 4.0; the reference code is AGPL-3.0.

Governance is deliberately **lightweight** at this stage - the goal is to attract a second independent implementation before formalising. Heavy governance structures before that happens can deter the very contributors the project needs.

---

## Roles

### Maintainer

Currently: **Johan Pieterse** ([johan@theahg.co.za](mailto:johan@theahg.co.za)) - The Archive and Heritage Group (Pty) Ltd. Wrote the initial spec + reference implementation; operates `ric.theahg.co.za`; merges changes.

This is a **single-maintainer-for-now** model. It will change once additional stewards are invited (see Phase 3 below).

### Implementers

Anyone running a server that passes the conformance probe. Implementers have a strong voice in spec changes because their feedback is concrete: *"this endpoint is ambiguous", "this shape doesn't round-trip", "this constraint is impossible in our database"*.

### Contributors

Anyone who opens an issue, a discussion, or a pull request against the spec or any of the four ecosystem repositories. No CLA is required.

### Reviewers (planned)

The goal for **Phase 3** is to invite 2-3 external spec editors - people with standing in the archival standards community (ideally EGAD-adjacent or running another implementation) - to form a small review group. Until that happens, major changes are circulated via Discussions before being merged.

---

## How changes get made

### Small changes (typo, clarification, broken link)

Open a pull request against the relevant repo. Merged if sensible.

### Spec changes that affect conformance

Minor spec changes (new optional endpoint, new SHACL warning, relaxed constraint) happen via:

1. **GitHub Discussion** with a concrete proposal (what changes, why, migration note if any).
2. At least **one week** of visibility before merge, so implementers can object.
3. Merged to the `main` branch if no objection; labelled in the changelog with the target minor version.

Major changes (breaking shape change, new required endpoint, new conformance level) require:

1. **Discussion** as above.
2. **Prototype implementation** in the reference server before merging.
3. **Conformance fixture** demonstrating the change.
4. Explicit announcement tagged with the target version.

Breaking changes bump the **minor** version until v1.0; the **major** version after that.

### Code changes to the reference implementation

PRs against `openric/service` (reference API) or any of `openric/viewer`, `openric/capture`, `openric/spec` are welcome under AGPL-3.0 / CC-BY 4.0 respectively. PRs that don't touch the protocol contract can be merged at the maintainer's discretion; PRs that do change the contract follow the spec-change process above.

---

## Compatibility policy

- **`v0.x` series** - Breaking changes allowed between minor versions, but must be documented in the changelog and announced ahead of time. Conformance version stamps (e.g., `openric:L1-v0.2.0`) let implementations advertise exactly what they support.
- **`v1.0` onward** - Breaking changes only on major version bumps. Deprecations announced at least one minor version before removal.
- **JSON Schemas, SHACL shapes, OpenAPI** - versioned with the spec. A server that claims conformance to `v0.2.0` MUST validate against the `v0.2.0` shape files.

---

## How to contribute feedback

| I want to… | Do this |
|---|---|
| Report a bug in the spec | [Open an issue](https://github.com/openric/spec/issues) |
| Propose a new endpoint / change | [Open a Discussion](https://github.com/openric/spec/discussions) first; PR after the discussion settles |
| Share an implementation experience | [Discussion #2](https://github.com/openric/spec/discussions/2) - "second-implementer questions" |
| Push back on the mapping | [Discussion #3](https://github.com/openric/spec/discussions/3) - "mapping sanity-check" |
| Ask a general question | [Open a Discussion](https://github.com/openric/spec/discussions) (the Q&A category) |
| Propose yourself as a spec editor | Email the maintainer directly with a short motivation + implementation or archival-standards background |

---

## Becoming a conformant implementation

You don't need permission - run the conformance probe:

```bash
git clone https://github.com/openric/spec
BASE=https://your.server/api/ric/v1 \
KEY=your-write-key \
bash spec/conformance/probe.sh
```

If it passes, you can publicly claim `OpenRiC v0.2.0` conformance. If you'd like your server **listed on openric.org** as a known implementation, open a Discussion with the URL and a one-paragraph context note - that triggers the (planned) implementation registry (see the [roadmap](/)).

---

## Roadmap for governance itself

| Phase | When | What |
|---|---|---|
| **Now** | v0.30.x-v0.35.x | Single maintainer; Discussions-based spec changes; lightweight policy. Six of seven profiles normative. |
| **Next** | v0.35.0 → v1.0 | Invite 2-3 external spec editors. Formalise proposal-template. Add implementation registry. Move to a `MAINTAINERS.md` file. |
| **v1.0** | when a second implementation exists and passes conformance | Cut `v1.0`. Freeze the core contract. Major changes only on major bumps. |
| **Post-v1.0** | later | Move governance to a working group or steering committee if community size warrants. Adopt a CoC if the contributor base grows beyond a handful. |

---

## Why lightweight for now

Heavy governance ahead of community is cargo cult. Until OpenRiC has:

- **A second independent implementation** passing conformance,
- **At least one external institution** committing to deploy,
- **2-3 active non-maintainer contributors** with sustained engagement,

…formal working groups would add process without matching substance. The current model gets the spec out, the tools public, and the probe in adopters' hands. When those three adoption signals arrive, governance scales up accordingly.

## Licence

Specification: [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).
Reference implementation + viewer + capture client + conformance probe: [GNU AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.html).

Contributors retain copyright in their contributions. By opening a PR you agree to license your contribution under the same terms.

## Contact

- Mailing list: currently via [GitHub Discussions](https://github.com/openric/spec/discussions)
- Maintainer: Johan Pieterse - [johan@theahg.co.za](mailto:johan@theahg.co.za)
