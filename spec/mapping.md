---
layout: default
title: OpenRiC Mapping Specification
---

# OpenRiC Mapping Specification

**Version:** 0.1.0-draft
**Status:** Draft — open for comment

---

## Purpose

This document specifies how archival descriptions expressed in the traditional ICA standards — **ISAD(G)**, **ISAAR(CPF)**, **ISDIAH** — are mapped to **Records in Contexts** (RiC-CM v1.0 / RiC-O v1.0).

The mapping is deterministic: given a conforming input description, exactly one conforming RiC graph results.

## Scope

- Archival descriptions (fonds, series, file, item) → `rico:Record`, `rico:RecordSet`, `rico:RecordPart`
- Authority records (persons, corporate bodies, families) → `rico:Agent` and subclasses
- Repositories / institutions → `rico:CorporateBody` + `rico:Place`
- Relationships between the above → `rico:Relation` subclasses with typed predicates

## Out of scope (for v0.1)

- Digital object technical metadata
- Preservation events (RiC-CM covers these; mapping deferred to v0.2)
- Rights statements (likely a separate OpenRiC-Rights spec)

## Mapping tables

*TBD — one section per source entity type, with field-by-field mapping and canonical examples.*

## Canonical examples

*TBD — input JSON / XML → output RiC-O Turtle, for each entity type.*

---

[Back to OpenRiC](../)
