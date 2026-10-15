---
layout: default
title: OpenRiC - Implement a server
description: From nothing to a server that passes the Core Discovery profile, in about twenty minutes, with no OpenRiC software, no Heratio and no account.
---

# Implement an OpenRiC server

This guide takes you from nothing to a server that passes the Core Discovery profile. You need Python 3, `curl` and `jq`. You do not need an account, an API key, Heratio, or any OpenRiC software beyond the files in [the specification repository](https://github.com/openric/spec).

The [getting-started guide](getting-started.html) is for using an OpenRiC server. This one is for building one.

## 1. Get the repository

```bash
git clone https://github.com/openric/spec.git
cd spec
```

## 2. Run the minimal server

[`examples/minimal-server/server.py`](https://github.com/openric/spec/blob/main/examples/minimal-server/server.py) is one file, standard library only. It holds a small invented fonds - one repository, a family, a person, and a fonds with two records - and serves it at the ten Core Discovery endpoints.

```bash
python3 examples/minimal-server/server.py
# OpenRiC minimal server on http://localhost:8080
```

Open <http://localhost:8080/records> in a browser. That is a RiC-O record list, served by about two hundred lines of Python.

## 3. Check it against the schemas

In a second terminal:

```bash
python3 -m pip install jsonschema
BASE=http://localhost:8080 python3 examples/minimal-server/check.py
```

The check fetches every Core Discovery endpoint, and every record, agent and repository the lists name, and validates each response against the [JSON Schemas](https://github.com/openric/spec/tree/main/schemas) published with the specification. It is read-only.

## 4. Run the conformance probe

```bash
BASE=http://localhost:8080 bash conformance/probe.sh --profile=core-discovery
```

The [probe](/conformance/) checks the endpoints the profile requires, and checks that the server declares the profile in its service description. Add `--json=result.json` for a machine-readable result you can publish. Every change to the specification repository runs steps 2 to 4 in CI, so if they stop working, the build fails.

## 5. Make it yours

The minimal server shows the contract; your server keeps your data. Four things to change first:

1. **Your data.** Replace the `RECORDS`, `AGENTS` and `REPOSITORIES` dictionaries with reads from your own catalogue. The response shapes stay the same; the [Core Discovery profile](/spec/profiles/core-discovery.html) and the [mapping](/spec/mapping.html) say which RiC-O terms carry which field.
2. **Your identifiers.** Set `BASE_IRI` to a namespace your institution controls, and keep it stable. A record's `@id` should still resolve after you change hosting.
3. **Honest declarations.** The service description at `/` lists the profiles you claim. Claim a profile only once the probe passes it. The [status page](/status/) shows how the reference service's declarations compare with its test results.
4. **The next profile.** [Authority & Context](/spec/profiles/authority-context.html) adds places, rules and activities; [Graph Traversal](/spec/profiles/graph-traversal.html) adds relationship walks. Each profile lists its endpoints, its required fields and the fixtures that pin the expected output.

The same surface is in one machine-readable file, the [API contract](/contract/openapi.json) (OpenAPI 3.1). It tags every operation with its profile, so you can filter it down to the profiles you declare and generate a client or server stub from it. Path identifiers in it are opaque strings: use slugs, numbers or anything else your catalogue already has. Where the contract and a profile page disagree, the profile is right and the contract is the bug.

## What this server does not do

It is read-only, keeps everything in memory, has no authentication and no search beyond a substring match. It implements one profile. That is deliberate: it is the smallest thing that is honestly conformant, so you can see where the contract ends and your own design choices begin.

When your server passes a profile, tell us on [the specification repository](https://github.com/openric/spec/discussions). An implementation built independently of the maintainers is exactly what the specification needs before it can reach v1.0.
