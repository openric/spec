---
layout: default
title: OpenRiC - For institutions and decision-makers
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">For institutions · executive brief · ~3-minute read</div>
    <h1>What OpenRiC means for archival institutions</h1>
    <p class="hero-lede">
      A concise overview for directors, IT leads, and procurement officers evaluating whether OpenRiC is worth adopting, requesting from vendors, or endorsing institutionally. Non-technical, decision-focused.
    </p>
  </div>
</div>

## The one-sentence version

OpenRiC is an **open, royalty-free specification** that lets any archival system publish and exchange **Records in Contexts (RiC)**-modelled data in a consistent way - so institutions are not locked into a single vendor's interpretation of the standard.

---

## Why this matters to an institution

### 1. Vendor independence

Without a shared contract, every vendor's "RiC support" means something slightly different. You cannot move data between systems without bespoke migrations. You cannot compare offerings objectively.

OpenRiC is that shared contract. Systems that implement it are comparable on a **defined, testable surface** - not just marketing claims.

### 2. Longevity

Archival data has a timescale measured in decades or centuries. Any format that depends on one company staying solvent is a risk.

OpenRiC is governed as **open standard** (CC-BY 4.0) and has a reference implementation under AGPL-3.0. The spec and the reference will remain readable, implementable, and operable regardless of what happens to any single vendor - including the one that authored it.

### 3. Interoperability, not just export

Many platforms advertise "linked data export". That exports once. OpenRiC is **bidirectional**: read, write, validate, harvest (OAI-PMH), and walk the graph - using the same HTTP contract every conformant server implements.

This means:
- Federated search across institutions becomes feasible.
- Controlled migration between platforms becomes feasible.
- Aggregators (national archives, thematic portals, research projects) can harvest from every OpenRiC server with one integration.

### 4. Alignment with ICA's RiC

RiC is the International Council on Archives' next-generation conceptual model and ontology, replacing ISAD(G), ISAAR(CPF), ISDF, and ISDIAH as separate standards.

Institutions that adopt RiC-native description formats now will not need to re-describe holdings when RiC becomes the dominant standard. OpenRiC provides the practical bridge between existing ISAD(G)-shaped catalogues and RiC-CM / RiC-O output.

### 5. Implementation flexibility

The spec defines **four conformance levels (L1-L4)**. An institution does not have to support the full semantic range on day one. An L1-conformant server - basic read-only mapped endpoints - is useful immediately and can be deployed with a weekend of developer effort against an existing catalogue.

---

## What's already delivered

| Component | What it is | Status |
|---|---|---|
| **Specification** (v0.2.0) | Four documents, 19 JSON Schemas, SHACL shapes, 27-case fixture pack | Frozen tag, under [openric.org](/spec/) |
| **Reference API** | ~40 endpoints covering read, write, graph, harvest (OAI-PMH), validation | Live at [ric.theahg.co.za](https://ric.theahg.co.za/api/ric/v1/health) |
| **Conformance probe** | Pure bash + jq; points at any server, returns pass/fail across every required endpoint | Live at [/conformance/](/conformance/) |
| **API Explorer** | Interactive Swagger UI - any reviewer can try every endpoint from a browser | Live at [/api-explorer/](/api-explorer/) |
| **Viewer + Capture** | Two browser-based client apps that talk to any conformant server | Live at viewer.openric.org + capture.openric.org |
| **OAI-PMH endpoint** | Standard archival harvest protocol - works with every OAI harvester (ArchiveSpace, DPLA hub, etc.) | Live at `ric.theahg.co.za/api/ric/v1/oai` |
| **Operational consumer** | Heratio - a real GLAM platform - uses the API as its only write path, proving it's sufficient for production | Live at heratio.theahg.co.za |

---

## What it doesn't do (yet)

Honesty matters for institutional evaluation:

- **No SPARQL endpoint** in v0.2.0. The stub exists but is marked experimental. Institutions needing SPARQL should ask; it's deferred until concrete demand. The `/graph?uri=…&depth=N` endpoint covers most traversal needs without SPARQL.
- **Single reference implementation.** A second independent implementation is a goal for v1.0. Until that exists, portability claims rest on the conformance probe being a fair test (which adopters can and should verify themselves).
- **No commercial vendor yet** has shipped OpenRiC-conformant products. This is the state of a v0.x open spec. Institutions asking vendors for OpenRiC support is the path from v0.x to v1.0.

---

## Cost, risk, and lock-in

| Question | Answer |
|---|---|
| What does OpenRiC cost? | **Nothing.** The spec is CC-BY 4.0; the reference implementation is AGPL-3.0; running your own server requires only standard web hosting. |
| What if the maintainer disappears? | The spec is self-contained and published under a permissive content licence. A successor maintainer can fork and continue. See the [governance page](/governance.html). |
| Can we be locked in? | No. The spec explicitly requires that reads and writes use the same HTTP contract any client uses - no privileged backdoor for the reference implementation. Data and credentials can be exported to any other OpenRiC server. |
| What's the audit story? | Every write action is logged in an audit table with timestamp, actor (API key id), IP, and payload. The `/{type}/{id}/revisions` endpoint exposes this. |
| What about sensitive data? | The spec supports access restrictions, personal-data flags, and ODRL policy extensions. The reference implementation respects them. Per-institution extensions (GDPR, POPIA, PAIA, etc.) ship as separate shape files, not in the core. |

---

## How to get started

**For a technical evaluation (developer, IT lead):**

1. Run the conformance probe against your existing catalogue or a prototype - [/conformance/](/conformance/).
2. Follow the 15-minute [getting-started guide](/guides/getting-started.html).
3. Browse the live data at [/demo/browse/](/demo/browse/) to see what a RiC-shaped dataset looks like.

**For a strategic evaluation (director, funder, board):**

1. Read this page.
2. Read the [one-page architecture overview](/architecture.html) - 5 minutes, mostly diagrams.
3. Talk to the maintainer: [johan@theahg.co.za](mailto:johan@theahg.co.za).

**For a procurement conversation:**

Ask vendors whether they can pass the OpenRiC conformance probe. If they can't, ask what would be required for them to implement it. Vendor answers to that question are a strong signal of their standards orientation.

---

## Endorsement

If your institution wants to publicly support OpenRiC - formally or informally - please say so in [Discussion #1](https://github.com/openric/spec/discussions/1). Even "we're watching this" is useful signal for other institutions weighing adoption.

## Contact

Johan Pieterse · [johan@theahg.co.za](mailto:johan@theahg.co.za) · The Archive and Heritage Group (Pty) Ltd · South Africa.

Available to present OpenRiC to archival institutions, standards bodies, or technical working groups on request.
