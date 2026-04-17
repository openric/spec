# openric-validate

Conformance validator for the [OpenRiC specification](https://openric.org).

**Status:** 0.1.0 alpha — thin slice. Supports single-record validation. Full endpoint-walk and graph-isomorphism checks arrive in v0.2.

## Install

```bash
pipx install ./validator
# or for development:
cd validator
pip install -e ".[dev]"
```

## Usage

### Validate one record response

```bash
openric-validate --record https://ric.theahg.co.za/api/ric/v1/records/my-fonds-slug
```

### Validate a full server (coming soon)

```bash
openric-validate https://ric.theahg.co.za/api/ric/v1 --level=L3
```

### Output formats

```bash
openric-validate --record <url> --output=human   # default
openric-validate --record <url> --output=json    # for scripts
openric-validate --record <url> --output=junit   # for CI
```

## Exit codes

| Code | Meaning |
|---|---|
| 0 | All checks passed |
| 1 | One or more violations |
| 2 | Warnings only |
| 3 | Server unreachable |
| 4 | Invalid invocation |

## Conformance levels

Per [OpenRiC Conformance spec](https://openric.org/spec/conformance.html):

- **L1** — Mapping conformance (input → expected RiC-O output)
- **L2** — Viewing API conformance (all required endpoints implemented)
- **L3** — Graph primitives conformance (six invariants hold)
- **L4** — Full conformance (L1 + L2 + L3 + round-trip preservation)

## Development

```bash
pip install -e ".[dev]"
pytest tests/ -v
```

## Licence

AGPL-3.0-or-later.

The [spec itself](https://github.com/ArchiveHeritageGroup/openric-spec) is under CC-BY 4.0 — distinct from this validator.
