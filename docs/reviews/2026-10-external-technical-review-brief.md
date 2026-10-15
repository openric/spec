# OpenRiC external technical review - brief for reviewers

Prepared 15 October 2026 for Dr Johan Pieterse, Standard owner. Plan V4, item S2.5.

## What we are asking for

OpenRiC is an open specification for publishing archival description built on the ICA's Records in Contexts (RiC-CM 1.0, RiC-O 1.1) over HTTP: a set of conformance profiles, JSON Schemas, SHACL shapes, a fixture pack, an OpenAPI contract and a conformance probe, with a reference implementation at ric.theahg.co.za. Everything so far has been written and checked inside one organisation. Before the specification passes its gate (S-GATE), someone outside that organisation needs to read it critically and tell us where it is unclear, wrong or untestable.

We are asking for two things, which may be done by one reviewer or split between two:

1. **A review of the specification's clarity and of two conformance profiles** - can an implementer who has never spoken to us build a conformant server from the documents alone?
2. **A review of the security changes made during the S0 incident response** - these were made and approved by one person, and the plan requires a retrospective independent look.

Terms, including any payment and how the reviewer is credited, are agreed with Dr Johan Pieterse before the review starts.

## Who we are looking for

- For part 1: someone who has implemented or reviewed an archival or cultural-heritage API (IIIF, OAI-PMH, Linked Art, the RiC-O Converter, an AtoM or ArchivesSpace integration), and who reads RDF and JSON-LD comfortably. Knowledge of RiC is welcome but not required; part of the point is to find out what a newcomer misreads.
- For part 2: someone with web-application security experience (API key handling, CORS, CSP, authorisation on destructive endpoints).
- Independence: the reviewer works outside The Archive and Heritage Digital Commons Group and Plain Sailing Information Systems and had no part in writing OpenRiC. Any connection to either organisation or to the project is stated in the report.

## Part 1 - specification and profiles

Read against **specification v0.45.0** (git tag `v0.45.0`, <https://github.com/openric/spec/tree/v0.45.0>). The two profiles chosen for close review are:

- **Core Discovery 0.4.0** (`spec/profiles/core-discovery.md`) - the entry profile most implementers start with; its list envelope changed in 0.4.0.
- **Round-Trip Editing 0.7.0** (`spec/profiles/round-trip-editing.md`) - the write surface, where mistakes cost data.

Supporting material: the mapping (`spec/mapping.md`, including §1.3 on what it does and does not claim), Graph Primitives, the conformance page, the change-control policy, the API contract (`contract/openapi.json`), the JSON Schemas (`schemas/`), the SHACL shapes (`shapes/`), the fixtures (`fixtures/`, with provenance labels), the RiC-AG comparison (`audit/ric-ag-crosswalk-comparison.md`) and the implementer guide with its minimal server (`guides/implement-a-server.md`, `examples/minimal-server/`).

Questions we would like answered:

1. Using only the documents, could you build a server that passes Core Discovery? Where did you have to guess?
2. Is every MUST in the two profiles testable? Which ones does the probe (`conformance/probe.sh`) not test, or test wrongly?
3. Do the profile text, the JSON Schemas, the SHACL shapes, the fixtures and the OpenAPI contract say the same thing? List every disagreement you find.
4. Are the RiC-O terms used correctly? In particular, review the open findings in the RiC-AG comparison (mapping issue O-8) and say which you would fix first.
5. Is the line between RiC itself and what OpenRiC adds (`openric:`, `openricx:`) clear enough that nobody would mistake OpenRiC terms for RiC?
6. Is the change-control policy workable for an outside implementer: would you know when a release can break your server?

Running the probe against the reference service is welcome (`bash conformance/probe.sh --profile=core-discovery`, read-only). Please do not run the write tests against ric.theahg.co.za; they create and delete data. We will provide a disposable server and a key on request.

## Part 2 - S0 security changes

Context: on 14 October 2026 anonymous writes to the production database were found to be possible through an open-write setting. The response (S0) is recorded in `docs/plans/2026-10-15-s0-closure-record.md` in openric/service. Scope for review:

- Service releases v0.17.1 to v0.17.10 (openric/service tags): delete scope enforced per route, CORS allow-list for writes, key revocation, status-row allocation, input validation on writes.
- The Content-Security-Policy on ric.theahg.co.za, enforcing since 15 October.
- API key handling in the browser: Browse and the API explorer on openric.org, capture.openric.org and the service's `/api/ric/v1/docs` page keep keys for the browser session only.
- The tests that cover these: `ApiSecurityTest`, `ListEnvelopeTest`, `StatusRowTest`.

Questions:

1. Is any destructive or write endpoint still reachable without the right scope?
2. Are the CORS and CSP settings sound for a public read API with keyed writes?
3. Is browser key handling acceptable for a developer tool, and what would you require before keys could be used by non-developers?
4. Do the tests actually prove what the closure record says they prove?

## What we need back

A dated report, which we will publish with the specification, containing:

- the reviewer's name (or a statement that they asked not to be named) and any connection to the project;
- findings, each with a location (file and section, or endpoint) and a severity: blocking, should fix, or suggestion;
- answers to the questions above, or a note where a question could not be answered.

We will reply to each finding in writing, and keep a residual issue register of findings we do not fix, with the reason. The S-GATE cannot be signed until the report, the responses and the register exist.

## Contact

Dr Johan Pieterse, johan@theahg.co.za. Specification repository: <https://github.com/openric/spec>; security issues should be reported privately as described in `SECURITY.md`.
