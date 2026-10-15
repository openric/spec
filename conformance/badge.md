---
layout: default
title: OpenRiC Conformance Badge
description: How to embed a live conformance badge for any OpenRiC server.
---

# Conformance badge

An OpenRiC server's conformance is public information by design — anyone can `GET /` and read `openric_conformance.profiles[]`. The **conformance badge** is that same information surfaced as a [shields.io](https://shields.io)-compatible JSON endpoint, so implementers can embed a live, always-current badge in their README, documentation site, or admin dashboard.

## Endpoint

A conformant server MAY expose:

```
GET {base}/conformance/badge[?profile=<id>]
```

Response: `application/json`, shields.io schema version 1.

### Request

| Query param | Required | Values |
|---|---|---|
| `profile` | no | One of the profile ids declared in `openric_conformance.profiles`. If omitted, the badge returns a summary of the server's overall spec version + profile count. |

### Response shape (shields.io endpoint schema)

```json
{
  "schemaVersion": 1,
  "label":         "string",
  "message":       "string",
  "color":         "string"
}
```

### Colour conventions

| Colour | Meaning |
|---|---|
| `brightgreen` | Profile is declared and the server claims `conformance: full`. |
| `yellow` | Profile is declared with `conformance: partial` (future; not yet in any current profile). |
| `lightgrey` | Profile is **not declared** on this server. |
| `blue` | Default summary badge (no `profile` param). |

## Embedding — README example

```markdown
![Core Discovery](https://img.shields.io/endpoint?url=https%3A%2F%2Fric.theahg.co.za%2Fapi%2Fric%2Fv1%2Fconformance%2Fbadge%3Fprofile%3Dcore-discovery)
```

Renders as a live badge that updates whenever the server's declaration changes — no CI, no manual version bumps.

### With a link

```markdown
[![Core Discovery](https://img.shields.io/endpoint?url=https%3A%2F%2Fric.theahg.co.za%2Fapi%2Fric%2Fv1%2Fconformance%2Fbadge%3Fprofile%3Dcore-discovery)](https://openric.org/spec/profiles/core-discovery.html)
```

The badge links back to the profile documentation.

## Live example — the reference server

<p>
  <a href="https://openric.org/spec/profiles/core-discovery.html"><img alt="Core Discovery" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fric.theahg.co.za%2Fapi%2Fric%2Fv1%2Fconformance%2Fbadge%3Fprofile%3Dcore-discovery"></a>
  <a href="https://openric.org/spec/"><img alt="OpenRiC" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fric.theahg.co.za%2Fapi%2Fric%2Fv1%2Fconformance%2Fbadge"></a>
</p>

## Building the shields.io URL

The pattern is:

```
https://img.shields.io/endpoint?url=<url-encoded conformance-badge endpoint>
```

Where the inner URL's query string must be URL-encoded so the outer parser doesn't confuse `?` and `&` characters:

- `?` in the inner URL → `%3F`
- `=` in the inner URL → `%3D`
- `&` in the inner URL (if any) → `%26`

Most markdown renderers handle this correctly if you use the literal percent-encoded form above.

## Verifying a server

The `openric.org/conformance` probe also hits this endpoint as part of `--profile=<id>` runs. It cross-checks:

1. `GET /` declares the profile in `openric_conformance.profiles[].id`.
2. `GET /conformance/badge?profile=<id>` returns `brightgreen` / `full`.

Any mismatch between (1) and (2) is a server-side conformance bug — the badge endpoint MUST reflect the same data the service description declares.

## Why not just use a static badge?

Static shields.io badges (`https://img.shields.io/badge/openric-core--discovery-brightgreen`) are easy to misconfigure and go stale silently. A server that once conformed but no longer does still shows a green static badge; the live endpoint updates automatically. **Prefer the live badge.**

## License

This doc — and the shields.io integration pattern it describes — is [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), part of the OpenRiC specification. Reference implementation of the endpoint (`openric/service`) is [AGPL-3.0-or-later](https://www.gnu.org/licenses/agpl-3.0.html); other implementers are free to expose an equivalent endpoint on their own servers under whatever licence they prefer.
