# OpenRiC conformance suite

Black-box probe that tells you whether a given server implements the OpenRiC
reference API correctly. Runs from a shell; no Ruby/Node/Python build step.

## Requirements

- `curl`
- `jq`

That's it. The suite is pure bash.

## Usage

Probe the reference API (read-only, no write probes):

```bash
./probe.sh
```

Probe a different server:

```bash
BASE=https://your.server/api/ric/v1 ./probe.sh
```

Probe including write + delete (creates and cleans up throwaway entities —
**don't** point this at production data without reading the script first):

```bash
KEY=your-api-key-with-write-and-delete-scope ./probe.sh
```

Probe scope enforcement (optional): set `READ_KEY` to a *read-only-scoped*
key in addition to the regular write `KEY`. The probe asserts that `POST
/places` is rejected with HTTP 403 when called with the read-only key.

```bash
KEY=write-key READ_KEY=read-only-key ./probe.sh
```

Verbose (prints first 200 bytes of each failing response body):

```bash
VERBOSE=1 ./probe.sh
```

## What it checks

| Category | Endpoints |
|---|---|
| Discovery + health | `/`, `/health` |
| Core classes | `/agents`, `/records`, `/places`, `/rules`, `/activities`, `/instantiations`, `/repositories`, `/functions` |
| Utilities | `/vocabulary`, `/relation-types`, `/autocomplete`, `/places/flat` |
| Graph + SPARQL | `/graph`, `/sparql` |
| OAI-PMH | `Identify`, `ListMetadataFormats`, `ListSets`, `ListIdentifiers`, `ListRecords` |
| Write + delete (with key) | `/places` + `/agents` + `/records` round-trip |

Each probe checks **both** the HTTP status code **and** the JSON shape
(via a `jq` expression). A 200 with the wrong shape still fails.

## Exit codes

- `0` — conformant (all required checks passed)
- `1` — at least one required check failed
- `2` — misconfigured (missing `curl`/`jq`, unreachable base)

## Interpreting results

- **PASS** — endpoint works and returns the expected shape.
- **SKIP (404)** — endpoint is marked `optional` in the spec and the server
  returns 404 for it. Allowed.
- **SKIP (no key)** — the probe needs `X-API-Key` and you didn't set one.
  Not a conformance failure on its own.
- **FAIL (shape)** — endpoint returned 200 but the JSON doesn't match
  what the spec promises. This is a conformance bug.
- **FAIL (auth)** — you set a key and the server still rejected it. Check
  the key's scopes or the server's auth wiring.

## What this suite doesn't do

- **Data quality.** It doesn't check that your `Record` titles are accurate
  or your `Agent` history is filled in. It checks that the endpoints exist
  and speak the right protocol.
- **SHACL validation.** Use the SHACL shapes in `../shapes/` with the
  Python validator in `../validator/` for that.
- **Performance.** Not a load test.

## Using it in CI

Add to your Actions / GitLab CI / Woodpecker pipeline. The probe takes
under a minute against a healthy server. Example:

```yaml
# .github/workflows/openric-conformance.yml
name: OpenRiC conformance
on: [push, workflow_dispatch]
jobs:
  probe:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install jq
        run: sudo apt-get install -y jq
      - name: Probe
        env:
          BASE: https://your.server/api/ric/v1
          KEY: ${{ secrets.OPENRIC_API_KEY }}
        run: bash conformance/probe.sh
```

## License

AGPL-3.0-or-later. Same as the rest of the OpenRiC reference suite.
