---
layout: default
title: OpenRiC Extension Proposals
permalink: /docs/extensions/
---

# OpenRiC Extension Proposals (post-v1.0 roadmap)

Proposed extensions to the core OpenRiC spec. Each is a separate normative profile-or-spec layered on top of the seven core profiles, with explicit scope, dependencies, and a stated reason it is **not** part of the core spec.

These are documents **about future work**. None is normative; none ships in v0.37.x or v0.38.x. They exist so the community can comment on direction before the work is committed.

| Extension | Scope | Status | Why not core |
|---|---|---|---|
| [OpenRiC-CIDOC-Bridge](openric-cidoc-bridge.md) | Express RiC-O graphs in CIDOC-CRM-equivalent form for museum (Spectrum) interoperability | Strawman draft | Cross-domain; depends on Damigos's 2023 ICADL mapping |
| OpenRiC-Rights | ODRL-based rights expression layered on `rico:Rule` | Roadmap-only — see [`spec/index.md`](../../spec/index.html) | RiC-O 1.1's rights vocabulary is thin; ODRL handles permissions/prohibitions/duties at scale |
| OpenRiC-Preservation | PREMIS-equivalent preservation events as `rico:Activity` chains | Roadmap-only | RiC-O 1.1's predicate set is incomplete for fine-grained PREMIS-equivalent events |
| OpenRiC-Storage | `Container` / `StorageLocation` modelling beyond `rico:Thing` | Open question | Comes up in collections-management but no clean canonical model |

## Why extensions, not core spec changes

Layering extensions keeps the core spec small, RiC-O-1.1-aligned, and stable. Each extension targets a distinct community (museums, rights-holders, preservation engineers, collections-management) and the scope decisions for each are different.

A server can claim `core-discovery` (or any other core profile) without claiming any extension. A server claiming an extension MUST also claim the core profile(s) the extension depends on. Extensions are **additive**.

## How to propose an extension

Open a [GitHub Discussion](https://github.com/openric/spec/discussions) on `openric/spec` with the label `extension`. The minimum bar:

1. A concrete external community with a stated need.
2. A scope statement that does NOT overlap any of the seven core profiles.
3. A first-draft mapping between the extension's domain and existing RiC-O 1.1 / openricx terms.
4. At least one institution that would adopt the extension in production.

Strawmen without point 4 still warrant a Discussion thread but are unlikely to ship.
