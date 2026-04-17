---
layout: default
title: OpenRiC Conformance
---

# OpenRiC Conformance

**Version:** 0.1.0-draft
**Status:** Draft — open for comment

---

## Purpose

Defines what it means for a server to be "OpenRiC-conformant." Conformance is machine-checkable: a CLI validator runs against a live server and produces a pass/fail report.

## Conformance levels

| Level | Requirement |
|---|---|
| **L1 — Mapping** | The server can translate a reference AtoM/ISAD(G) input into a RiC output that matches the canonical fixture. |
| **L2 — Viewing API** | All endpoints in the [Viewing API](viewing-api.html) are implemented and return valid JSON-LD. |
| **L3 — Graph primitives** | Responses include `Node`, `Edge`, and at least one of `Cluster` / `Layout hint` per the [Graph Primitives](graph-primitives.html) spec. |
| **L4 — Full** | L1 + L2 + L3, plus round-trip (input → RiC → subgraph → viewer-ready) passes with no data loss. |

## Validator

A CLI tool, `openric-validate`, will be published alongside the spec.

```bash
openric-validate https://myserver.example/openric/v1 --level=L4
```

Output: pass/fail per endpoint, diff against canonical fixtures on failure.

## JSON Schemas

Machine-readable schemas for every endpoint response live in `schemas/` in this repository.

## Fixtures

The `fixtures/` directory contains paired input (AtoM-style description) and expected output (RiC JSON-LD) files for ~20 representative cases — fonds with descendants, multi-agent family, repository with holdings, etc.

---

[Back to OpenRiC](../)
