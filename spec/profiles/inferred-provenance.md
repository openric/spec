---
layout: default
title: OpenRiC — Inferred-Provenance Profile
description: AI inference must never be passed off as documented fact. Machine-asserted entities and edges are visibly distinguishable in every export via PROV-O — model, confidence, receipt id — and absence of provenance means asserted fact.
---

# Inferred-Provenance Profile

**Profile id:** `inferred-provenance`
**Profile version:** 0.43.0
**Spec version:** 0.43.0
**Status:** Draft — open for comment
**Dependencies:** None. Composes with any read/export profile — it adds a provenance overlay to whatever entities a server emits.
**Last updated:** 2026-06-19
**Reference implementation:** Heratio ([ArchiveHeritageGroup/heratio#1319, #1321](https://github.com/ArchiveHeritageGroup/heratio)) — `RicProvenanceService`, table `ric_inferred_assertion`, `RicSerializationService::applyProvenance`, the `ahg-inference-receipts` Ed25519 receipt chain.

---

## 1. Purpose

As AI enters archival description — NER links, suggested relationships, OCR-derived fields, AI-proposed models (see the openric.org [modelling wizard](/wizard/)) — a hard line must hold: **machine inference must never be indistinguishable from documented fact.** This is a legal/evidentiary requirement under access-to-information and data-protection regimes (POPIA, PAIA, GDPR and equivalents), not a nicety.

The Inferred-Provenance Profile makes every **machine-asserted** entity or edge **visibly distinguishable** from asserted fact, in every serialisation, using PROV-O.

## 2. The distinguishability guarantee

The contract rests on an **asymmetry**:

- An entity/edge that **was** machine-generated carries a `prov:` provenance block.
- An entity/edge with **no** provenance block is, *by absence*, asserted (human-curated / documented) fact.

> **Absence of provenance ⇒ asserted fact.** A consumer therefore never has to trust a flag's *negative* — the mere presence of a `prov:wasGeneratedBy` block marks inference, and its absence marks fact. This is the whole guarantee; implementations MUST NOT emit provenance blocks on human-asserted data (which would invert the meaning).

## 3. Required export terms

A registered machine-asserted entity/edge MUST export:

| Term | Meaning |
|---|---|
| `openricx:assertionStatus` | `"inferred"` (the visible marker) |
| `prov:wasGeneratedBy` | a `prov:SoftwareAgent` node — the model that produced the assertion |
| `openricx:confidence` | the model's confidence (0–1) on the assertion |
| `openricx:inferenceReceipt` | the id of a tamper-evident inference receipt (§4) |
| `openricx:humanConfirmed` | `true` once a human has confirmed/overridden (optional) |

Example (JSON-LD):

```json
{
  "@id": "https://host/ric/place/912150",
  "@type": "rico:Place",
  "rico:name": "Thebes",
  "openricx:assertionStatus": "inferred",
  "openricx:confidence": 0.82,
  "prov:wasGeneratedBy": {
    "@type": "prov:SoftwareAgent",
    "rico:name": "qwen3:8b via ai.theahg.co.za",
    "openricx:inferenceReceipt": "rcpt_01H..."
  }
}
```

A server records inferred assertions in a register (informative shape: `entity_type, entity_id, predicate, model, confidence, receipt_id, human_confirmed`; reference impl: `RicProvenanceService`, table `ric_inferred_assertion`) so the serializer emits the markers deterministically.

## 4. Inference receipts (informative)

Behind each `prov:` marker sits a **signed, hash-linked inference receipt** — model, prompt/version, confidence, timestamp, and human-override state — forming a tamper-evident audit trail (reference impl: the `ahg-inference-receipts` Ed25519 receipt chain). The receipt id in the export resolves to this chain. The receipt format is informative; the *export markers* in §3 are normative.

## 5. Relationship to the OpenRiC AI surfaces

OpenRiC's own AI-assisted tools fall under this profile:

- The [modelling wizard](/wizard/) `POST /wizard/suggest` endpoint *proposes* a model (human-in-the-loop: the user reviews before any create) — proposals are not asserted into the graph, so they carry no provenance until created.
- **When an AI-proposed entity/edge is created** (e.g. via the wizard's live capture), it MUST be registered as inferred and carry the §3 markers — otherwise it would enter the graph as indistinguishable fact, which §2 forbids.

## 6. SHACL

[`shapes/profiles/inferred-provenance.shacl.ttl`](https://github.com/openric/spec/blob/main/shapes/profiles/inferred-provenance.shacl.ttl): any node carrying `openricx:assertionStatus "inferred"` MUST also carry `prov:wasGeneratedBy` and `openricx:confidence` — an inferred marker without its provenance block is a violation.

## 7. Conformance

A server claims Inferred-Provenance when:

- Every machine-asserted entity/edge exports `openricx:assertionStatus: "inferred"` + `prov:wasGeneratedBy` (a `prov:SoftwareAgent`) + confidence + a receipt id.
- Human-asserted data carries **no** provenance block (the absence ⇒ fact rule holds).
- AI-created entities (incl. from the wizard) are registered as inferred.

Declared as `{ "id": "inferred-provenance", "version": "0.43.0", "conformance": "full" }`.
