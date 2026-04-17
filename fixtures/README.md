# OpenRiC conformance fixtures

Each fixture is a folder containing a paired input + expected output, used by the conformance validator to check that an implementation maps archival-description data to RiC-O correctly.

## Shape

```
fixtures/<case-name>/
├── input.json           # AtoM-shape input (see spec/mapping.md §3)
├── expected.jsonld      # Canonical RiC-O JSON-LD output
├── expected-graph.json  # Canonical Subgraph for /graph endpoint (optional)
└── notes.md             # What this case exercises, what it doesn't
```

## Running against a fixture

```bash
openric-validate --fixture fonds-minimal
```

## Current fixtures (v0.1.0-draft)

| # | Case | Purpose |
|---|---|---|
| 1 | `fonds-minimal` | Smallest valid record — title + creator |
| 2 | `fonds-with-series` | *(planned)* Hierarchy: fonds + series + item |
| 3 | `fonds-multilingual` | *(planned)* Multiple `@language` titles |
| 4 | `agent-person-simple` | *(planned)* Person with dates of existence |
| 5 | `agent-corporate-body` | *(planned)* CorporateBody with mandate + place |
| 6 | `agent-family` | *(planned)* Family with member relations |
| 7 | `agent-with-relations` | *(planned)* Successor / predecessor chains |
| 8 | `repository-with-holdings` | *(planned)* ISDIAH repo + 3 fonds |
| 9 | `function-with-activities` | *(planned)* ISDF function + 2 activities |
| 10 | `event-production` | *(planned)* Record + creation event → Production |
| 11 | `event-accumulation` | *(planned)* Record + accumulation event |
| 12 | `record-with-digital-object` | *(planned)* Record + Instantiation |
| 13 | `record-in-container` | *(planned)* Record held in rico:Thing box |
| 14 | `record-security-classified` | *(planned)* Classification level |
| 15 | `record-personal-data` | *(planned)* containsPersonalData = true |
| 16 | `record-with-access-restriction` | *(planned)* Restriction scope |
| 17 | `subgraph-depth-1` | *(planned)* Graph: root + direct neighbours |
| 18 | `subgraph-depth-2` | *(planned)* Graph: 2-hop BFS |
| 19 | `subgraph-filtered-by-type` | *(planned)* Graph: filtered node types |
| 20 | `validation-failure` | *(planned)* Deliberately broken input → expected SHACL failures |

## Principle

For v0.1.0 the `expected.jsonld` outputs are what Heratio (the reference implementation) produces. This is intentionally circular: v0.1.0 freezes Heratio's current output as the canonical target, reviewed and committed. Future implementations match this target or the target changes via a spec PR.

Starting from v0.2.0, fixtures are expected to drive implementations rather than follow them.
