---
title: What is OpenRiC?
category: Getting started
order: 2
summary: OpenRiC is an open, free contract for publishing and exchanging RiC data over HTTP - like IIIF for images, but for archival description. A spec, a reference API, and browser clients.
---

**OpenRiC is an open specification for how archival descriptions map to RiC-CM / RiC-O, how that data is served over HTTP for reading and writing, and how graph interfaces render it - consistently across any conformant server.**

It is **not a product**. It is a *contract* anyone can implement - the way [IIIF](https://iiif.io/) is a contract for images. Any system that implements it can be read, written to, harvested and graph-walked the same way.

## What's in OpenRiC

| Surface | What it is | Where |
|---|---|---|
| **Specification** | Four documents, JSON Schemas, SHACL shapes, [profiles](/spec/profiles/), a conformance probe | openric.org |
| **Reference API** | A Laravel service implementing the contract over real archival data - 8-entity CRUD, SPARQL, OAI-PMH | [ric.theahg.co.za](https://ric.theahg.co.za/) |
| **Clients** | Pure-browser apps: [viewer](https://viewer.openric.org/), [capture](https://capture.openric.org/), the [modelling wizard](/wizard/) | openric.org / subdomains |
| **Model navigator** | The RiC-CM model, browsable | [ric.theahg.co.za/reference/ric-cm](https://ric.theahg.co.za/reference/ric-cm/) |

See how they connect in the **[system map](/help/system-map/)**.

## Why it matters

- **Vendor independence** - systems are comparable on a defined, testable surface, not marketing claims.
- **Portability** - read, write, validate, harvest and graph-walk over the same HTTP contract; no proprietary-only path.
- **Longevity** - the spec is CC-BY 4.0, the implementations AGPL-3.0; the data outlives any one vendor.

## Licensing

Specification: **CC-BY 4.0**. Reference implementation, viewer, capture: **GNU AGPL 3.0**.

## Next

- [A 5-minute tour](/help/quick-tour/)
- [For institutions](/help/for-institutions/) - the adoption case
- [For developers](/help/build-a-conformant-server/) - build a conformant server
