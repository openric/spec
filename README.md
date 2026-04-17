# OpenRiC — Specification

An open, implementation-neutral specification for **Records in Contexts (RiC)** — mapping from archival-description standards, a viewing API, graph primitives, and a conformance test suite.

Published at **[openric.org](https://openric.org)**.

## Structure

```
openric-spec/
├── index.md             — landing page (rendered as openric.org/)
├── spec/
│   ├── mapping.md       — archival description → RiC-CM / RiC-O
│   ├── viewing-api.md   — REST + JSON-LD API for RiC viewing
│   ├── graph-primitives.md — node, edge, cluster, drill abstractions
│   └── conformance.md   — JSON Schemas, fixtures, validator spec
├── schemas/             — JSON Schema files (TBD)
├── fixtures/            — example inputs + expected outputs (TBD)
├── CNAME                — openric.org (GitHub Pages custom domain)
├── _config.yml          — Jekyll config
└── LICENSE              — CC-BY 4.0
```

## Licence

Specification: **CC-BY 4.0**.
Reference implementation (Heratio): **AGPL 3.0**, separate repo.

## Status

Drafting. Version 0.1.0 target: initial public review by end 2026-Q2.

## Contributing

RFCs via GitHub issues. Spec editor: Johan Pieterse (johan@theahg.co.za).
External reviewers and spec-editors welcome — see [index.md](index.md).
