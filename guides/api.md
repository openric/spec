---
layout: default
title: OpenRiC — API client guide
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Guide · API client</div>
    <h1>Talk to the OpenRiC API from code</h1>
    <p class="hero-lede">Every OpenRiC-conformant server exposes the same <code>/api/ric/v1/*</code> surface. This guide shows how to call it from <code>curl</code>, JavaScript, Python, and PHP — enough to build your own capture tool, viewer, analytics pipeline, or integration.</p>
    <div class="hero-cta">
      <a class="btn-primary" href="../spec/viewing-api.html">Full endpoint reference</a>
      <a class="btn-ghost" href="https://ric.theahg.co.za/api/ric/v1/openapi.json">OpenAPI JSON</a>
    </div>
  </div>
</div>

## The base URL

Every example uses the reference deployment:

```
https://ric.theahg.co.za/api/ric/v1
```

Substitute your own server's base for production. All endpoints below hang off that root.

## Quick sanity check — `/health`

```bash
curl https://ric.theahg.co.za/api/ric/v1/health
# {"status":"ok","service":"RIC-O Linked Data API","version":"1.0"}
```

No auth needed. If this works from wherever you're running, the rest of the guide applies.

## Read-side: no key needed

Reads are wide-open. Browser clients can hit these cross-origin without any authentication.

### Fetch a single record

```bash
curl https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat
```

### List records, paginate

```bash
curl "https://ric.theahg.co.za/api/ric/v1/records?page=1&per_page=10"
```

List endpoints follow the `openric:items` / `openric:total` / `openric:next` pattern — see [Viewing API §7](../spec/viewing-api.html#7-pagination).

### Subgraph — the central endpoint

```bash
curl "https://ric.theahg.co.za/api/ric/v1/graph?uri=/informationobject/egyptian-boat&depth=2"
```

Returns an `openric:Subgraph` document — `{@type, openric:root, openric:depth, openric:nodes, openric:edges}`. Feed this directly to `@openric/viewer` to render.

### Search across all entity types

```bash
curl "https://ric.theahg.co.za/api/ric/v1/autocomplete?q=egypt&limit=5"
```

### Vocabulary (type pickers)

```bash
curl https://ric.theahg.co.za/api/ric/v1/vocabulary/ric_place_type
```

Drives "Place type" dropdowns — always pull it live; don't bundle a stale copy.

## Write-side: key + scope

### The headers

```
Content-Type: application/json
Accept: application/json
X-API-Key: <your 64-char hex key>
```

Alternative header names `X-REST-API-Key` and `Authorization: Bearer <key>` SHOULD be accepted by conformant servers.

### Create a Place

```bash
curl -X POST https://ric.theahg.co.za/api/ric/v1/places \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $RIC_KEY" \
  -d '{
    "name": "Cradle of Humankind",
    "type_id": "region",
    "latitude": -25.9333,
    "longitude": 27.7667,
    "authority_uri": "https://www.geonames.org/1005330"
  }'
# 201 Created
# {"id":912500,"slug":"cradle-of-humankind","type":"place","href":"/api/ric/v1/places/cradle-of-humankind"}
```

### Update (PATCH)

```bash
curl -X PATCH https://ric.theahg.co.za/api/ric/v1/places/912500 \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $RIC_KEY" \
  -d '{"description": "UNESCO World Heritage Site."}'
# 200 OK
# {"success":true,"id":912500}
```

### Delete

```bash
curl -X DELETE https://ric.theahg.co.za/api/ric/v1/places/912500 \
  -H "X-API-Key: $RIC_KEY"
# 200 OK
# {"success":true,"id":912500}
```

### Create a relation

```bash
curl -X POST https://ric.theahg.co.za/api/ric/v1/relations \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $RIC_KEY" \
  -d '{
    "subject_id": 553,
    "object_id": 912500,
    "relation_type": "took_place_at",
    "certainty": "probable",
    "evidence": "Per the 1972 excavation report, p.42."
  }'
```

## Error shapes

All errors are JSON with a predictable shape:

```json
{ "error": "forbidden", "message": "API key is missing the 'write' scope" }
```

Common status codes:

| Status | Meaning |
|---|---|
| 200 | OK — success for GET / PATCH / DELETE |
| 201 | Created — success for POST |
| 400 | Bad request — missing or malformed query param |
| 401 | Unauthorized — no / invalid key |
| 403 | Forbidden — key present but missing scope |
| 404 | Not found — unknown entity id / slug / path |
| 422 | Unprocessable entity — body validation failed |
| 429 | Too many requests — rate limit hit (default 60/min) |
| 500 | Server error — bug on the server side |

## Client snippets

### JavaScript / browser

```js
const API = 'https://ric.theahg.co.za/api/ric/v1';
const key = 'YOUR_KEY';

async function createPlace(data) {
  const r = await fetch(`${API}/places`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-API-Key': key },
    body: JSON.stringify(data),
  });
  if (!r.ok) throw new Error(`${r.status}: ${await r.text()}`);
  return r.json();
}

const place = await createPlace({ name: 'Cradle of Humankind' });
console.log(place.slug);
```

### Python

```python
import requests

API = 'https://ric.theahg.co.za/api/ric/v1'
KEY = 'YOUR_KEY'
HEADERS = {'X-API-Key': KEY}

# Read
r = requests.get(f'{API}/autocomplete', params={'q': 'egypt', 'limit': 3})
r.raise_for_status()
for hit in r.json():
    print(hit['type'], hit['id'], hit['label'])

# Write
r = requests.post(f'{API}/places', headers=HEADERS, json={'name': 'Cradle of Humankind'})
r.raise_for_status()
place = r.json()
print(place['slug'])
```

### PHP (Laravel's Http facade)

```php
use Illuminate\Support\Facades\Http;

$api = 'https://ric.theahg.co.za/api/ric/v1';
$key = env('RIC_API_KEY');

$client = Http::withHeaders(['X-API-Key' => $key])->acceptJson();

// Read
$results = $client->get("$api/autocomplete", ['q' => 'egypt', 'limit' => 3])->json();

// Write
$place = $client->asJson()->post("$api/places", [
    'name' => 'Cradle of Humankind',
    'type_id' => 'region',
])->json();
```

(This is essentially what Heratio's `RicApiClient.php` does — source at [github.com/ArchiveHeritageGroup/heratio](https://github.com/ArchiveHeritageGroup/heratio/blob/main/packages/ahg-ric/src/Http/RicApiClient.php).)

### Shell — one-liner stats

```bash
export RIC_KEY="..."
curl -s "https://ric.theahg.co.za/api/ric/v1/places?per_page=1" | jq '."openric:total"'
```

## Rate limits

The reference server caps at 60 requests / minute per IP. Higher-volume workloads should:

1. Batch — there's no bulk endpoint in v0.1, but a tight loop with sleeps is fine up to the limit.
2. Ask the operator for a key with a higher rate limit (the `ahg_api_key.rate_limit` column can be bumped per key).

## CORS

All GET endpoints send `Access-Control-Allow-Origin: *`. Write endpoints handle the CORS preflight and accept the `X-API-Key` header from any origin. Browser-based capture clients (like [capture.openric.org](https://capture.openric.org)) work without proxy.

## Monitoring / alerting

- `/health` — cheap; poll from your uptime monitor.
- `/openapi.json` — the full OpenAPI description if you want to auto-generate client bindings.
- `HEAD` requests are accepted on most read endpoints.

## Next steps

- [Viewing API](../spec/viewing-api.html) — full endpoint-by-endpoint reference
- [Conformance](../spec/conformance.html) — if you're building your *own* OpenRiC server and want to claim conformance
- [Architecture](../architecture.html) — how the reference API fits into the wider ecosystem
