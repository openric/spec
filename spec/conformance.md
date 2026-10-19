---
layout: default
title: OpenRiC Conformance
description: What it means for a server to conform to OpenRiC - profiles, the shapes, schemas and fixtures that define them, and the tools that test them.
kind: spec
---

# OpenRiC Conformance

**Last revised in:** v0.47.0

---

## 1. Purpose

This page says what it means for an implementation to conform to OpenRiC, what defines each requirement, and how a claim is tested. Conformance is checkable by machine: the [conformance probe](/conformance/) runs against a live server and reports, profile by profile, which checks pass, fail or were skipped.

## 2. Conformance is claimed per profile

A server conforms to one or more **profiles**. Each profile is a bounded set of endpoints and response requirements with its own version. The specification has {{ site.data.profiles | size }} profiles; the [profile index](profiles/) lists them with their status and version. Only a profile with status *normative* is a stable conformance target; a *draft* profile may change.

A server declares what it claims in its service description, `GET /`:

```json
{
  "openric_conformance": {
    "spec_version": "{{ site.data.version.version }}",
    "profiles": [
      { "id": "core-discovery", "version": "0.5.0", "conformance": "full" }
    ]
  }
}
```

That declaration is the authoritative claim. A claim is only as good as its test: the [status page](/status/) shows, for the reference service, what is declared next to what the probe found and when.

Earlier versions of this page defined four conformance levels, L1 to L4. They are kept in the appendix for readers of old material, and no current server or tool should report them.

## 3. What defines each requirement

| Artefact | Where | Role |
|---|---|---|
| Profiles | [`spec/profiles/`](profiles/) | The normative text: which endpoints, which fields, which MUSTs. |
| API contract | [`contract/openapi.json`](/contract/openapi.json) | OpenAPI 3.1: every operation the profiles define, tagged with its profile. |
| JSON Schemas | [`schemas/`](https://github.com/openric/spec/tree/main/schemas) | {{ site.data.inventory.schemas }} schemas, JSON Schema 2020-12, for response and request bodies. |
| SHACL shapes | [`shapes/`](https://github.com/openric/spec/tree/main/shapes) | `openric.shacl.ttl` for every entity, and one shape file per profile in `shapes/profiles/`. Shapes use W3C SHACL 1.0. |
| Fixtures | [`fixtures/`](/fixtures/) | {{ site.data.inventory.fixtures }} done and {{ site.data.inventory.fixtures_planned }} planned cases, listed with their profiles and provenance in [`manifest.json`](https://github.com/openric/spec/blob/main/fixtures/manifest.json). |

Where these disagree, the profile text wins, and the disagreement is a defect to report.

JSON-LD framing order, property order within a node and prefix choice are not significant. Two RDF outputs are equal when their graphs are isomorphic under blank-node bijection.

## 4. Testing an implementation

### 4.1 The conformance probe

The probe is the conformance test. It is a shell script in the specification repository, [`conformance/probe.sh`](/conformance/), and needs only `bash`, `curl` and `jq`:

```bash
# Every profile the server declares
BASE=https://archives.example.org/api/ric/v1 bash conformance/probe.sh

# One profile, with a machine-readable result
BASE=https://archives.example.org/api/ric/v1 bash conformance/probe.sh --profile=core-discovery --json=result.json
```

Public servers limit how fast they may be called; the reference service allows 60 requests a minute per address and answers more with 429. The probe waits between profiles; for your own full checks against a public server, pace them at about one request a second, and send a `User-Agent` that names your client, since some servers refuse library defaults. Without a key the probe is read-only and skips every check that would write; a profile with skipped checks is never reported as a plain pass. With `KEY=...` it also runs the write, update and delete cycle. Only run the write checks against a server whose data you may change. On the reference service that means a disposable copy, never `ric.theahg.co.za` itself.

CI proves on every change that the [minimal server](https://github.com/openric/spec/tree/main/examples/minimal-server), a standard-library Python server with no connection to Heratio, passes Core Discovery.

### 4.2 The validator

[`openric-validate`](https://github.com/openric/spec/tree/main/validator) checks responses and files against the JSON Schemas and SHACL shapes:

```bash
openric-validate --record https://archives.example.org/api/ric/v1/records/my-fonds
openric-validate --file my-record.jsonld --output=json
```

It still accepts a legacy `--level` option; profile-based testing is the probe's job.

## 5. Badge

A server MAY expose `GET {base}/conformance/badge?profile=<id>`, which returns a [shields.io](https://shields.io) endpoint badge for a declared profile. The [badge page](/conformance/badge.html) describes it. The reference service exposes it.

## 6. Certification

There is no certification authority. Conformance is self-declared and independently checkable with the probe, as with IIIF. Third-party implementations that pass the probe for the profiles they declare can be listed on [related implementations](../related-implementations.html).

## 7. Versioning

A claim names the specification version and the profile versions it was tested against. How each kind of change is versioned, and when a release may break a passing server, is set by [change control](change-control.html).

## Appendix - legacy conformance levels

Before profiles (v0.30.0 onwards), conformance was stated as four levels. They are recorded here only so older material can be read:

| Level | Name | Rough profile equivalent |
|---|---|---|
| L1 | Mapping | The mapping requirements inside each profile |
| L2 | Viewing API | Core Discovery |
| L3 | Graph primitives | Graph Traversal |
| L4 | Full | Several profiles together, including Round-Trip Editing |

---

[Back to OpenRiC](../)
