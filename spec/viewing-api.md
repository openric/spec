---
layout: default
title: OpenRiC Viewing API
---

# OpenRiC Viewing API

**Version:** 0.1.0-draft
**Status:** Draft — open for comment

---

## Purpose

Defines a **REST + JSON-LD** contract that any OpenRiC-conformant server exposes so that viewers can render RiC data consistently.

Analogous in spirit to the [IIIF Presentation API](https://iiif.io/api/presentation/): the server decides what to surface; the viewer decides how to render it.

## Base path

```
https://<server>/openric/v1/
```

## Endpoints (draft)

| Method & Path | Returns |
|---|---|
| `GET /description/{id}` | Single RiC entity with first-order neighbours |
| `GET /description/{id}/graph` | Subgraph suitable for 2D / 3D viewer |
| `GET /description/{id}/drill?depth=N` | Expanded subgraph at depth N |
| `GET /search?q=...&type=Agent` | RiC-typed search results |
| `GET /vocabulary` | Server's enabled RiC-O vocabulary subset |

## Response shape

`application/ld+json` with:
- RiC-O vocabulary as the primary namespace
- OpenRiC viewing hints as a secondary namespace (`@context` includes `openric:`)
- Content-negotiable to `text/turtle` for raw RiC consumers

## Authentication

Out of scope for v0.1 — servers are free to apply their own auth. ODRL-based rights enforcement may be layered on top (see OpenRiC-Rights, forthcoming).

## Canonical response examples

*TBD.*

---

[Back to OpenRiC](../)
