---
layout: default
title: OpenRiC - For institutions and decision-makers
kind: current
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

OpenRiC is governed as **open standard** (CC-BY 4.0) and has a reference implementation under AGPL-3.0. Those licences mean the specification and the reference code stay readable and implementable whatever happens to any single vendor, including the one that wrote them. Keeping a server *running* is a different matter: that still needs an institution or supplier to host and maintain it, and today the only running implementation is AHG's.

### 3. Interoperability, not just export

Many platforms advertise "linked data export". That exports once. OpenRiC defines a live HTTP contract instead: read, harvest (OAI-PMH) and walk the graph, and, for servers that claim the optional [Round-Trip Editing](/spec/profiles/round-trip-editing.html) profile, write and validate. A server claims only the profiles it implements, so check which ones before relying on any of them.

This means:
- Federated search across institutions becomes possible once more than one institution runs a conformant server. None does yet besides the reference service.
- Migration between two conformant platforms should need less bespoke mapping, because both sides read and write the same contract. It still needs mapping, checking and reconciliation, and it has not yet been tried between two independent implementations.
- An aggregator (a national archive, a thematic portal, a research project) can write one client for each profile it needs and use it against any server that claims that profile.

### 4. Alignment with ICA's RiC

RiC is the International Council on Archives' next-generation conceptual model and ontology, replacing ISAD(G), ISAAR(CPF), ISDF, and ISDIAH as separate standards.

Describing in RiC terms now should reduce the re-description an institution faces if RiC becomes the dominant standard. It will not remove it: RiC-O is still being revised (OpenRiC targets RiC-O 1.1), and some mapping choices will be revisited as practice settles. OpenRiC provides the practical bridge between existing ISAD(G)-shaped catalogues and RiC-CM / RiC-O output.

### 5. Implementation flexibility

The spec defines **{{ site.data.profiles | size }} named profiles** - {{ site.data.profiles | where: "status", "normative" | size }} normative, {{ site.data.profiles | where: "status", "draft" | size }} draft - and an implementation claims each one independently. An institution does not have to support the full semantic range on day one. A server conforming to [Core Discovery](/spec/profiles/core-discovery.html) alone - basic read-only mapped endpoints - is useful immediately. How much work it takes depends on the catalogue: the [minimal example server](https://github.com/openric/spec/tree/main/examples/minimal-server) shows the shape of the contract in a few hundred lines, but mapping a real catalogue's data is most of the effort, and we have no measured figure from an outside institution yet. (The older L1-L4 level vocabulary is legacy and no longer part of a conformance claim.)

---

## What's already delivered

| Component | What it is | Status |
|---|---|---|
| **Specification** (v{{ site.data.version.version }}) | The base documents, {{ site.data.inventory.schemas }} JSON Schemas, SHACL shapes, {{ site.data.inventory.fixtures }}-case fixture pack | Tagged release, under [openric.org](/spec/) |
| **Reference API** | Endpoints covering read, write, graph, harvest (OAI-PMH), validation | Live at [ric.theahg.co.za](https://ric.theahg.co.za/api/ric/v1/health) |
| **Conformance probe** | Pure bash + jq; points at any server, returns pass/fail across every required endpoint | Live at [/conformance/](/conformance/) |
| **API Explorer** | Interactive Swagger UI - any reviewer can try every endpoint from a browser | Live at [/api-explorer/](/api-explorer/) |
| **Viewer + Capture** | Two browser-based client apps written against the contract; so far tested against the reference service only | Live at viewer.openric.org + capture.openric.org |
| **OAI-PMH endpoint** | Standard OAI-PMH 2.0, so a standard harvester should be able to read it; not yet tested against a named national or thematic aggregator | Live at `ric.theahg.co.za/api/ric/v1/oai` |
| **Related platform** | Heratio, a GLAM platform from the same maintainers, can read graph data from the API. It still writes through its own copy of the RiC routes on a shared database, so it is not independent proof that the API alone is enough for production. | Live at heratio.theahg.co.za |

---

## What it doesn't do (yet)

Honesty matters for institutional evaluation:

- **SPARQL is outside the conformance contract.** A [SPARQL Access](/spec/profiles/sparql-access.html) profile exists in draft, so an implementation may offer it, but no conforming client may assume it. Institutions needing SPARQL should ask. The `/graph?uri=…&depth=N` endpoint covers most traversal needs without SPARQL.
- **Single reference implementation.** A second independent implementation is a goal for v1.0. Until that exists, portability claims rest on the conformance probe being a fair test (which adopters can and should verify themselves).
- **No commercial vendor yet** has shipped OpenRiC-conformant products. This is the state of a v0.x open spec. Institutions asking vendors for OpenRiC support is the path from v0.x to v1.0.

---

## Cost, risk, and lock-in

| Question | Answer |
|---|---|
| What does OpenRiC cost? | **No licence fee.** The spec is CC-BY 4.0 and the reference implementation is AGPL-3.0. Running a server is not free: it needs hosting, someone to map and maintain the data, and upgrades as the specification moves. |
| What if the maintainer disappears? | The spec is self-contained and published under a permissive content licence. A successor maintainer can fork and continue. See the [governance page](/governance.html). |
| Can we be locked in? | Less than with a closed format. The contract is open, and a conformant server exports its data as JSON-LD, Turtle and OAI-PMH, which other OpenRiC servers and RDF tools can read. Moving still takes work on the receiving side, and a move between two independent implementations has not been demonstrated yet. |
| What's the audit story? | In the reference implementation, every write action is logged in an audit table with timestamp, actor (API key id), IP, and payload. The `/{type}/{id}/revisions` endpoint exposes this. |
| What about sensitive data? | The spec supports access restrictions, personal-data flags, and ODRL policy extensions. The reference implementation applies them to its public read endpoints; test this against your own restricted records before relying on it. Per-institution extensions (GDPR, POPIA, PAIA, etc.) ship as separate shape files, not in the core. |

---

## Readiness checklist

Before asking a vendor for OpenRiC, or adopting it yourself, an institution can answer these from its own records:

- **Data ownership.** Who owns the catalogue data, and may it be published, in whole or in part?
- **Source schemas.** Which standards the descriptions follow today (ISAD(G), ISAAR(CPF), ISDIAH, ISDF, local schemes), and how consistently. The [mapping](/spec/mapping.html) starts from these.
- **Rights and restrictions.** Which records or fields are restricted, embargoed or carry personal data, and where that is recorded.
- **Stable identifiers.** Whether records, agents and places have identifiers that will not change when the system does.
- **Accessibility.** Who will use the published description, and what they need from it.
- **Operating model.** Who would run an OpenRiC server, update it and answer for it.
- **Which profiles.** [Core Discovery](/spec/profiles/core-discovery.html) is the minimum; the others are added as the data supports them.
- **Evidence to demand.** A vendor's claim is a declaration; ask for the conformance probe's result against their server, dated, with any skipped checks.

Adopting OpenRiC means adopting an open contract, not installing a product. [OpenRiC Workspace](/application/), an application built on it, is planned and not yet available, so it is not part of a decision today.

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

Dr Johan Pieterse · [johan@theahg.co.za](mailto:johan@theahg.co.za) · The Archive and Heritage Digital Commons Group (Pty) Ltd · South Africa.

Available to present OpenRiC to archival institutions, standards bodies, or technical working groups on request.
