---
layout: default
title: OpenRiC - Evaluate OpenRiC independently
description: A reproducible procedure for testing OpenRiC from a published release alone, without Heratio's code, servers or database, or any AHG service.
kind: current
---

# Evaluate OpenRiC independently

The reference service at ric.theahg.co.za runs on a database it shares with Heratio, AHG's GLAM platform, so it cannot show on its own that the specification works without AHG's code. This procedure tests OpenRiC from a published release alone. It uses nothing from Heratio, and no AHG server: once the release is downloaded, every step runs on your own machine.

It was run end to end from an empty directory against v0.49.2 on 19 October 2026, with the results shown under each step. To test another release, change the version number throughout.

**You need:** `git`, Python 3.11 or later, `curl`, `jq`, `sha256sum` and, for step 1, the [GitHub CLI](https://cli.github.com/) (or download the two release files by hand).

## 1. Get the release and check it has not been altered

Download the release bundle and its checksum, and check one against the other:

```bash
mkdir openric-eval && cd openric-eval
gh release download v0.49.2 --repo openric/spec -p 'openric-spec-v0.49.2.tar.gz*'
sha256sum -c openric-spec-v0.49.2.tar.gz.sha256
```

Expected: `openric-spec-v0.49.2.tar.gz: OK`.

Then check that the release tag was signed by the maintainer's key. The public key is published at [`/keys/allowed_signers`](/keys/allowed_signers):

```bash
git clone -q --depth 1 --branch v0.49.2 https://github.com/openric/spec.git spec
curl -s https://openric.org/keys/allowed_signers -o allowed_signers
cd spec
git fetch -q --depth 1 origin tag v0.49.2
git -c gpg.ssh.allowedSignersFile=../allowed_signers tag -v v0.49.2
```

Expected, among the output: `Good "git" signature ... with ED25519 key SHA256:dTmsTQEuuSikPeM3TZzlB6/KQQQWJylRFwWPboID0nY`. The same fingerprint is recorded in the [S-GATE record](https://github.com/openric/spec/blob/main/docs/gates/S-GATE.md), and GitHub shows the tag as *Verified*, so you can check the key against more than one source.

## 2. Validate the fixture pack

The fixtures are example responses, one or more per profile, that the JSON Schemas and SHACL shapes must accept. Install the validator from the release and run its tests:

```bash
python3 -m venv ../venv
../venv/bin/pip install -q -e "./validator[dev]"
cd validator && ../../venv/bin/python -m pytest tests/ -q; cd ..
```

Expected: `38 passed, 37 skipped`. The skipped tests are fixtures whose response has no JSON Schema (raw RDF, SPARQL results, revision lists); they are validated by other means, and the test output says which.

## 3. Run a server that shares nothing with AHG

The release includes a minimal server: about 320 lines of Python, standard library only, with its own data and its own identifiers. It implements the Core Discovery profile.

```bash
PORT=8765 python3 examples/minimal-server/server.py &
curl -s http://localhost:8765/health
BASE=http://localhost:8765 ../venv/bin/python examples/minimal-server/check.py
```

Expected: `All responses valid.`

## 4. Probe it

The conformance probe is a bash script. It asks a server for every endpoint a profile requires and checks each response:

```bash
BASE=http://localhost:8765 KEY="" bash conformance/probe.sh --profile=core-discovery --json=probe.json
jq '{verdict, counts}' probe.json
kill %1
```

Expected: `11 pass, 0 fail, 0 skip` and `"verdict": "pass"`.

## 5. Point the same tools at any other server

Nothing in steps 2 to 4 is tied to the minimal server. Probe your own implementation, or any public one, with the same command:

```bash
BASE=https://your.server/api/ric/v1 bash conformance/probe.sh --profile=core-discovery
```

Run without a key, as here, the probe is read-only and skips every check that would write. To test writes, give it a key for a disposable server, never one holding real data; see the [probe's README](https://github.com/openric/spec/tree/main/conformance).

## What this shows, and what it does not

It shows that the published documents, schemas, fixtures and probe agree with each other, and that a server written without AHG's code can satisfy Core Discovery as the probe tests it.

It does not show that two independently written implementations interoperate: the minimal server is written by the same maintainer as the specification. That needs an implementation built by someone else from the documents alone. If you build one, [tell us](/review/): it is the [condition for v1.0](/governance.html) that matters most.
