---
layout: default
title: OpenRiC
---

# OpenRiC

**An open specification for Records in Contexts (RiC) — implementation-neutral, IIIF-inspired.**

OpenRiC defines how archival descriptions (ISAD(G), ISAAR(CPF), ISDIAH) map to **Records in Contexts** (RiC-CM / RiC-O), how RiC data is served for viewing, and how graph-based interfaces can render it consistently across different systems.

OpenRiC is not a product. It is a specification. Any system — AtoM, Heratio, Archivematica, a bespoke national-archive platform — can implement it.

---

## The four specification documents

| Document | Purpose |
|---|---|
| [Mapping Spec](spec/mapping.html) | How to translate archival-description schemas into RiC-CM / RiC-O |
| [Viewing API](spec/viewing-api.html) | REST + JSON-LD contract for delivering RiC for interactive viewing |
| [Graph Primitives](spec/graph-primitives.html) | Abstract concepts — node, edge, cluster, drill, layout hints |
| [Conformance](spec/conformance.html) | JSON Schemas, fixtures, and a validator CLI |

*All four are drafts. Comment issues are welcome on the [GitHub repository](https://github.com/ArchiveHeritageGroup/openric-spec).*

---

## Reference implementation

[**Heratio**](https://github.com/ArchiveHeritageGroup/heratio) is the first reference implementation of OpenRiC. The 2D and 3D graph viewer will be published separately as `@openric/viewer`, usable against any OpenRiC-conformant server.

---

## Licence

- **Specification** — [Creative Commons Attribution 4.0 (CC-BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
- **Reference implementation** — [GNU AGPL 3.0](https://www.gnu.org/licenses/agpl-3.0.html)

---

## Contact

Johan Pieterse — [johan@theahg.co.za](mailto:johan@theahg.co.za)
The Archive and Heritage Group (Pty) Ltd
