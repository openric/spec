---
layout: default
title: OpenRiC - Architecture
kind: current
---

# Architecture

OpenRiC is a specification plus four public deployments that implement it. The deployments are deliberately small, separately-hosted, and interoperable - any of them can be replaced by a third party's implementation without touching the others.

This page explains what's where, how they talk to each other, and what the boundaries are.

---

## The four surfaces

| URL | Role | Implementation | Licence |
|---|---|---|---|
| **[openric.org](https://openric.org)** | Specification, schemas, fixtures, validator | Jekyll site (`github.com/openric/spec`) | CC-BY 4.0 |
| **[viewer.openric.org](https://viewer.openric.org)** | 2D/3D graph viewer demo | `@openric/viewer` npm package (`github.com/openric/viewer`) | AGPL-3.0 |
| **[capture.openric.org](https://capture.openric.org)** | Browser-based data-entry client | Pure HTML/JS (`github.com/openric/capture`) | AGPL-3.0 |
| **[ric.theahg.co.za/api/ric/v1](https://ric.theahg.co.za/api/ric/v1/health)** | Reference API endpoint | Laravel 12 (loads Heratio's `ahg-ric` package via composer path repo) | AGPL-3.0 |

Plus one supporting deployment:

| URL | Role |
|---|---|
| **[heratio.theahg.co.za](https://heratio.theahg.co.za)** | Operational GLAM platform - the source of the data the reference API exposes. Also a *client* of that API for every admin action. |

---

## Data flow

```
                        ┌───────────────────────────────────┐
                        │  openric.org                      │
                        │  Spec + JSON Schemas + fixtures + │
                        │  SHACL shapes + validator CLI     │
                        └───────────────────────────────────┘
                                      │
                         defines the contract
                                      │
                                      ▼
        ┌─────────────────────────────────────────────────────────┐
        │  /api/ric/v1/*  - the contract                          │
        │  Reads  (no auth) + Writes (X-API-Key with scope)       │
        └─────────────────────────────────────────────────────────┘
               ▲               ▲                ▲
               │               │                │
  implemented by:         consumed by:       consumed by:
               │               │                │
               ▼               ▼                ▼
     ric.theahg.co.za  viewer.openric.org  capture.openric.org
     (ref. deployment) (pure-browser)      (pure-browser)
               │
               │ shares MySQL with
               ▼
       heratio.theahg.co.za
       (operational GLAM platform - also a client of /api/ric/v1
        over HTTP for every mutating admin action)
```

Notably absent: any arrow from Heratio *into* `ric.theahg.co.za` other than HTTP. The two apps share a database; they do not share a process. If tomorrow the database was split, Heratio's HTTP calls would keep working with a different `RIC_API_URL`.

---

## How each surface works

### openric.org - specification

Static Jekyll site, hosted on GitHub Pages. Four spec documents in `spec/`, JSON Schemas in `schemas/`, SHACL in `shapes/`, fixtures in `fixtures/`, validator CLI in `validator/`, conformance probe in `conformance/`, API explorer in `api-explorer/`. Current tagged release: `v{{ site.data.version.version }}` ({{ site.data.version.release_date }}).

The **[live demo](demo/)** is a single HTML page that fetches `/api/ric/v1/graph` from `ric.theahg.co.za` over HTTPS. No server-side code on `openric.org` - proves the spec site is independent of any implementation.

### viewer.openric.org - graph viewer demo

GitHub Pages from `github.com/openric/viewer` (`docs/` branch). Loads `@openric/viewer` from unpkg CDN (the published npm package). Server picker offers:

1. **Reference API** (`ric.theahg.co.za/api/ric/v1`) - real archival data.
2. **Static fixtures** - service-worker intercepts `/api/static-ric/*` requests, serves pre-rendered JSON from the spec's conformance fixture pack. Proves the viewer has no Heratio-specific assumptions.
3. **Custom URL** - paste any OpenRiC-conformant base URL.

`@openric/viewer` is ~500 lines of vanilla JS with cytoscape (2D) and 3d-force-graph (3D) as peer deps.

### capture.openric.org - capture client

GitHub Pages from `github.com/openric/capture` (`docs/` branch). Single-file HTML - no build step. Fields:

- **Server URL** - any OpenRiC-conformant base URL.
- **API key** - must have `write` scope. Stored in `localStorage`.
- Five entity-type tiles (Place, Rule, Activity, Instantiation, Relation).

On submit, POSTs to `${server}/{type}`. Type pickers are fetched live from `${server}/vocabulary/{taxonomy}` so the form always reflects whatever vocabulary the target server publishes.

Recent captures logged in `localStorage` (last 20) - useful for verifying writes actually landed.

### ric.theahg.co.za - reference API

Laravel 12 app at `/usr/share/nginx/OpenRiC/`. Reuses Heratio's `ahg-ric`, `ahg-api`, and `ahg-core` packages via composer path repo (`/usr/share/nginx/heratio/packages/*`). Not a fork - every fix pushed to Heratio's packages is active on the next request here.

nginx vhost serves:

- `/` → static landing page (one-page overview + four-tile navigation)
- `/api/ric/v1/*` → Laravel (front-controller routing)
- back-compat 301s for retired Flask-era paths

Shared MySQL with Heratio. Phase 4.3 Option A (shared DB); separate-DB migration planned but not currently active.

### heratio.theahg.co.za - operational platform + API client

Full-stack GLAM platform. Before the April 2026 split, Heratio served `/api/ric/v1/*` only as in-process Laravel routes. Since the split, as checked against the Heratio source on 2026-10-14:

- Heratio still loads its own `/api/ric/v1/*` routes (`AhgRicServiceProvider::boot`). Its admin write surfaces, such as the modal entity create and the relation editor, call them with the admin's session cookie, so no API key is shipped to the browser.
- Reads such as graph traversal can go to the reference service, through `RicApiClient` and `RIC_API_BASE` (`config('ric.api_url')`).
- Both applications read and write the same MySQL database (see Boundaries below).

So Heratio is not a pure HTTP client of the reference service: it keeps an in-process write path over a shared database. Removing that coupling is planned work, not a current property.

---

## Boundaries

| From | To | Over | Auth |
|---|---|---|---|
| openric.org/demo | ric.theahg.co.za/api/ric/v1 | HTTPS, wide-open CORS | none (reads only) |
| viewer.openric.org | ric.theahg.co.za/api/ric/v1 | HTTPS, wide-open CORS | none (reads only) |
| capture.openric.org | any configured server | HTTPS, wide-open CORS | `X-API-Key` from `localStorage` |
| heratio.theahg.co.za admin (server-side) | ric.theahg.co.za/api/ric/v1 | HTTPS, in-VM hairpin | `X-API-Key` from Heratio's `.env` |
| heratio.theahg.co.za admin (browser-side) | ric.theahg.co.za/api/ric/v1 | HTTPS, cross-origin | cookie-less, admin-session - read-only surfaces |
| Heratio DB | RiC service DB | **shared MySQL** | DB user credentials in both apps' `.env` |

The shared DB is a soft boundary, documented in the split plan (`docs/ric-split-plan.md` in the Heratio repo). Phase 4.3 Option B - separate DBs with a sync layer - is on the roadmap but not executed.

---

## What it takes to build a second implementation

To be an OpenRiC implementation you need to serve `/api/ric/v1/*` per the [Viewing API spec](spec/viewing-api.html), pass the [Conformance fixture pack](spec/conformance.html), and emit JSON-LD that validates against the published SHACL shapes and JSON Schemas.

The reference API is ~2,500 lines of PHP plus the shared packages. It's a sensible reference but not the only shape.

Once your implementation serves `/api/ric/v1/*`:

- The **viewer** (`@openric/viewer`) renders against it with zero config beyond a base URL.
- The **capture client** writes into it with zero config beyond base URL + API key.
- The **validator CLI** (`openric-validate`) reports schema/SHACL/invariant conformance.

---

## Repository map

| Repo | Contents |
|---|---|
| [`openric/spec`](https://github.com/openric/spec) | Jekyll site source + spec documents + JSON Schemas + SHACL shapes + fixtures + validator CLI |
| [`openric/viewer`](https://github.com/openric/viewer) | `@openric/viewer` npm package + GH Pages demo |
| [`openric/capture`](https://github.com/openric/capture) | Capture client + GH Pages demo |
| [`ArchiveHeritageGroup/heratio`](https://github.com/ArchiveHeritageGroup/heratio) | Operational GLAM platform (includes `packages/ahg-ric/` - the code the reference API service reuses) |

---

## Related

- **[Data management & deployment topologies](data-management.html)** - where RiC data lives in the backing store, and three concrete topologies (green-field, AtoM retrofit, consumer-with-own-UI) covering every realistic deployment shape. Read this if you're evaluating how OpenRiC fits alongside an existing system.

---

## Licence

- **Spec** - CC-BY 4.0
- **All implementations** - AGPL-3.0
