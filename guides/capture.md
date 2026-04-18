---
layout: default
title: OpenRiC — Capture guide
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Guide · Capture</div>
    <h1>Capture RiC entities from a browser</h1>
    <p class="hero-lede"><a href="https://capture.openric.org">capture.openric.org</a> is a pure-browser data-entry tool for any OpenRiC-conformant server. No install, no backend on our side — you paste a server URL + an API key and create Places, Rules, Activities, Instantiations, and relations straight into that server's database.</p>
    <div class="hero-cta">
      <a class="btn-primary" href="https://capture.openric.org">Open the capture app ↗</a>
      <a class="btn-ghost" href="https://github.com/openric/capture">Source ↗</a>
    </div>
  </div>
</div>

## What you need

1. **A server URL.** The base of an OpenRiC API — e.g. `https://ric.theahg.co.za/api/ric/v1`. The reference API is pre-filled as a default.
2. **An API key with `write` scope.** The server operator gives you one. See [Getting a key](#getting-a-key) below.
3. A modern browser. The tool uses `fetch()`, `localStorage`, and ES6 — works everywhere current.

## First use

1. Visit **[capture.openric.org](https://capture.openric.org)**.
2. **Settings panel at the top** — confirm the server URL, paste your API key, hit **Save**. The tool runs `/health` against the server as a sanity check. If it returns 200, you're connected; the key is stored in your browser's `localStorage` and never leaves that origin except to talk to the server you configured.
3. **Pick a tile** — Place, Rule, Activity, Instantiation, or Relation. A form opens below.
4. **Fill fields and submit.** Type pickers (Place Type, Carrier Type, Relation Type, etc.) are populated live from the server's `/vocabulary/{taxonomy}` endpoint — so you always pick from whatever vocabulary the target server actually publishes, not a stale bundled list.

On success, the entity appears in the **Recent captures** log at the bottom (last 20, localStorage-backed). Click its label to open its JSON-LD representation on the server.

## Getting a key

The tool doesn't issue keys — the server operator does. For the reference instance at `ric.theahg.co.za`:

- Email [johan@theahg.co.za](mailto:johan@theahg.co.za) with a short note about what you're building.

For your own server, see the reference implementation's mint command:

```bash
cd /usr/share/nginx/OpenRiC
php artisan ric:mint-service-key --owner=<your-user-id> --name="openric-capture"
```

Keys carry **scopes** — `write` lets you create + update; `delete` lets you delete. Ask the operator for the scopes you need.

## Creating each entity type

### Place

Geographic or topographical. Name is required; everything else helps later search + linking.

| Field | Notes |
|---|---|
| Name | e.g. `Gqeberha`, `Ain Soukhna`. Required. |
| Type | From the server's `ric_place_type` taxonomy. |
| Authority URI | Geonames / Getty / Wikidata IRI if you have one. Emitted as `owl:sameAs` in RiC-O. |
| Latitude / Longitude | Decimal degrees. |
| Address | Free-text. |
| Description | Free-text. |

### Rule / Mandate

Legislation, policy, retention schedule, authorising instrument.

| Field | Notes |
|---|---|
| Title | e.g. `Protection of Personal Information Act No. 4 of 2013`. Required. |
| Type | From `ric_rule_type`. |
| Jurisdiction | Country / region / organisation the rule applies in. |
| Start / End date | Enactment + repeal. |
| Authority URI | Link to an authoritative source (government gazette, etc.). |
| Description / Legislation / Sources | Free-text context. |

### Activity

A production, accumulation, custody, reproduction, or mandate event — anything that *happened* and shaped records.

| Field | Notes |
|---|---|
| Name | Short descriptive name of the activity. Required. |
| Type | From `ric_activity_type`. Maps to `rico:Production`, `rico:Accumulation`, etc. |
| Date display | Free-text for uncertain dates: `c. 2400 BC`, `late 19th century`. |
| Start / End date | Structured dates if known. |
| Place ID | Optional — numeric id of an existing Place this activity took place at. |
| Description | Free-text. |

### Instantiation

A physical or digital manifestation of a record — TIFF scan, photocopy, microfilm, audio file.

| Field | Notes |
|---|---|
| Title | e.g. `Baptism register vol. 3 — scanned TIFF`. Required. |
| Carrier type | From `ric_carrier_type` (paper, microfilm, TIFF, PDF, …). |
| MIME type | Standard IANA MIME, e.g. `image/tiff`. |
| Extent value + unit | `12` + `pages`, `4.5` + `MB`, `22` + `minutes`. |
| Parent record id | Optional — numeric id of the Record this instantiation manifests. |
| Description / Technical characteristics | Equipment, resolution, colour depth, etc. |

### Relation

Link two existing entities with a `rico:*` predicate.

| Field | Notes |
|---|---|
| Subject id | Numeric id of the "from" entity. Required. |
| Object id | Numeric id of the "to" entity. Required. |
| Relation type | From `ric_relation_type`. Required. |
| Start / End date | When the relation was active. |
| Certainty | How sure you are: `certain`, `probable`, `possible`, `uncertain`, `unknown`. |
| Evidence | Source citation, archival reference, or a note. |

The server knows each relation type's domain and range — if you try to link (say) a Person to a MIME type, it will 422.

## Errors you might hit

| Status | What it means |
|---|---|
| 401 | No API key, or key is wrong / inactive. |
| 403 | Key is valid but missing the scope the operation needs (usually `write` or `delete`). |
| 422 | Body validation failed — missing required field, or a relation between incompatible types. Inspect the response JSON for the exact error. |
| Server URL probe fails | Wrong URL, or the server's CORS config doesn't allow your origin. The reference server opens CORS wide; custom servers may not. |

## Tips

- **Search before you create.** The top-bar search hits `/autocomplete` — finds matching entities across all types. Avoid duplicates.
- **Link as you go.** When you create a Place, immediately create an Activity at that Place (you'll need the Place's numeric id — it appears in the Recent captures log or via the search bar).
- **Bulk imports via curl, not this UI.** For more than ~20 entries, use the API directly with a script. This tool is optimised for careful single-entity capture, not batch.
- **The key is per-browser.** If you want to capture from a colleague's laptop they need their own key — or their own browser profile with the key saved there.

## Privacy

- API key lives only in your browser's `localStorage`. Never transmitted anywhere except the server URL you configured.
- Recent-captures log is browser-local. Clearing site data wipes it.
- The tool makes no analytics calls, no third-party requests except to the server you pointed it at and to the CDN serving the page itself.

## Licence + source

[AGPL-3.0-or-later](https://github.com/openric/capture/blob/main/LICENSE). Code: [github.com/openric/capture](https://github.com/openric/capture).
