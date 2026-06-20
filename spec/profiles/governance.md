---
layout: default
title: OpenRiC — Governance Profile
description: The meaning-layer contract — pinned standards, the two-layer IRI policy, deprecate-not-delete stable IRIs, SHACL as a merge gate, and a versioned change process. What pins what a graph means and keeps it conformant over time.
---

# Governance Profile

**Profile id:** `governance`
**Profile version:** 0.43.0
**Spec version:** 0.43.0
**Status:** Draft — open for comment
**Dependencies:** None. Orthogonal to every read/write profile — it governs *meaning and change*, not the endpoint surface.
**Last updated:** 2026-06-19
**Reference implementation:** Heratio ([ArchiveHeritageGroup/heratio#1319](https://github.com/ArchiveHeritageGroup/heratio)) — `RicGraphManifest`, `ShaclValidationService`, `RicConformanceCommand`, `docs/reference/ontology-governance-pin.md`.

---

## 1. Purpose

A model is only trustworthy if its *meaning* is pinned and its *changes* are governed. The Governance Profile is the single, citable contract that declares **which ontologies a server commits to, at which versions, under what change process, and with what conformance gate**. If a version, namespace, or export format is not pinned here, it is not sanctioned.

This profile governs the meaning layer; it does not re-specify the model (that is the rest of the spec). Two consumers depend on it: anyone aligning their own RiC deployment to a shared, diffable standard, and any agent / RAG that must know exactly which semantics a graph asserts.

A server claiming the Governance Profile commits to five things:

1. Publish a **governance pin** — the one-page record of pinned standards + versions.
2. Mint identifiers under the **two-layer IRI policy** (§3).
3. Treat **stable IRIs as permanent** — deprecate, never delete or recycle (§4).
4. Make **SHACL the merge gate**, not a guideline (§5).
5. Operate a **versioned change process** with a public change log (§6).

## 2. Pinned standards

A conformant server publishes a governance-pin document declaring the sanctioned standards and versions. The baseline pin is:

| Layer | Standard | Pinned version | Role |
|---|---|---|---|
| Records model | RiC-O | **1.0.2** | Canonical entity/relationship target. |
| Thesauri / controlled vocab | SKOS | W3C Rec (2009) | Terms, subjects, places, authorities. |
| Provenance | PROV-O | W3C Rec (2013) | Who asserted this, when, how, on what basis (see [Inferred-Provenance](inferred-provenance.html)). |
| Museum bridge | CIDOC-CRM | **7.1.3** | Optional cross-walk for museum/object data. |
| OpenRiC extensions | `openricx:` = `https://openric.org/ns/ext/v1#` | v1 | Terms RiC-O does not define ([extension ontology](/ns/ext/v1.html)). |

**Rule:** RiC-O is version-pinned. RiC-O is still maturing; a version bump is a *governed change* (§6), never an automatic upgrade. A server MUST declare its pinned RiC-O version in the governance pin and in `dcterms:conformsTo` of its dataset descriptor (see [Portability](portability.html)).

## 3. The two-layer IRI policy

OpenRiC distinguishes **internal** identifiers (how a live graph is partitioned and maintained) from **public** identifiers (the export identity a consumer dereferences). Both are normative.

| Layer | Form | Used for | Dereferenceable? |
|---|---|---|---|
| **Internal** node IRI | `urn:ahg:ric:<type>:<id>` (id-based) | Live-graph node / named-graph identifiers; loaders, integrity checks, orphan cleanup; the vector-layer join key (`object_id → urn:…`) | No — internal only |
| **Public** export IRI | `https://<host>/ric/<type>/<slug>` | The export identity emitted in JSON-LD / Turtle / SPARQL | Yes — the host equals the published REST/SPARQL host |

Normative rules:

- Public IRIs are minted from **stable identifiers** (authority ids), **never from mutable labels**. Sourced from a single configured base (e.g. `config('ric.base_uri')`), so the same entity gets the same IRI in dev, CI and prod — IRIs MUST NOT be environment-dependent.
- The extension namespace MUST resolve to `https://openric.org/ns/ext/v1#` (prefix `openricx`) in **every** serialisation — JSON-LD and Turtle alike. A namespace that differs by format is a round-trip hazard and a conformance failure.
- **Operational hosts are not vocabulary namespaces.** A REST/SPARQL host (e.g. `https://ric.theahg.co.za`) is a service base URL, not an ontology IRI.

### 3.1 Projection manifest

The relational store is the **source of truth**; the RDF graph is a **derived, regenerable projection** — no dual-write, and the graph can be dropped and rebuilt from the relational source at any time. A single **projection manifest** maps `type → {source, id}` and is shared by the loader, the integrity check, and orphan cleanup (reference impl: `RicGraphManifest`). One manifest, three consumers — so the partition, the public IRI, and the internal IRI never drift.

## 4. Stable IRIs — deprecate, don't delete (issue #3)

**An IRI, once published, is permanent. A superseded, withdrawn, or destroyed entity is marked deprecated, never deleted, and its IRI is never recycled.**

- A superseded entity exports **`owl:deprecated: true`**, optionally **`dcterms:isReplacedBy <successor IRI>`**, and **`rdfs:comment`** carrying the reason.
- A **deprecation register** (informative shape: `entity_type, entity_id, reason, superseded_by_iri, deprecated_at`) records supersession so the serializer emits the markers deterministically (reference impl: `RicDeprecationService`, table `ric_deprecated_entity`).
- Consumers can therefore distinguish a **deprecated-but-addressable** node from a live one — and a vanished real-world thing (a demolished building, a flooded valley) keeps a resolvable node rather than becoming a dangling reference.

## 5. SHACL is the gate, not a guideline

Every published graph MUST pass **SHACL validation** against the pinned RiC-O shapes **before merge**, and the check MUST be wired into CI so a non-conformant graph fails the build. The shapes graph lives at a stable IRI distinct from the data (e.g. `https://<host>/ric/shapes#`). See [Conformance](../conformance.html) and the [`shapes/`](https://github.com/openric/spec/tree/main/shapes) set. SHACL is the enforcement mechanism for this entire profile — "it validates" is the merge condition, not an aspiration.

## 6. Versioned change process

Any ontology-affecting change (version bump, new predicate, namespace change, mapping change) follows:

1. **Proposal** — a public issue with the before/after mapping.
2. **Review** — an editorial owner signs off; RiC-O / CRM version bumps require an explicit migration note.
3. **Conformance gate** — the change MUST pass SHACL (§5) before merge.
4. **Versioned release** — semver on the artifacts: **major** = breaking IRI/semantics, **minor** = additive, **patch** = labels/docs. Regenerate shapes and fixtures.
5. **Change log** — every released change is appended to a public, diffable change log (consumers diff against it; see [Portability](portability.html) `/changelog`).

## 7. SHACL

Governance shapes are enforced by the always-on and pinned RiC-O shapes in [`shapes/`](https://github.com/openric/spec/tree/main/shapes); this profile adds no entity shapes of its own — it constrains *process and identity*, which SHACL enforces by gating every other profile's output.

## 8. Conformance

A server claims the Governance Profile when:

- It publishes a governance-pin document with the pinned standards + versions.
- Its public export IRIs follow `https://<host>/ric/<type>/<slug>`, minted from stable ids, environment-independent.
- Superseded entities export `owl:deprecated` (+ `dcterms:isReplacedBy` where a successor exists) and are never deleted.
- SHACL validation gates merges in CI.
- A public, versioned change log exists.

Declared in the service description as `{ "id": "governance", "version": "0.43.0", "conformance": "full" }`.
