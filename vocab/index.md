---
layout: default
title: OpenRiC Vocabularies
permalink: /vocab/index.html
---

# OpenRiC Vocabularies

Controlled vocabularies published by the OpenRiC project as SKOS ConceptSchemes. These are referenced from properties in the OpenRiC mapping spec and serialized by conformant servers as IRI values (not free-text strings).

## Active vocabularies

| Vocabulary | Namespace | Concepts | Used by |
|---|---|---:|---|
| [Activity Type](activity-type.html) | `https://openric.org/vocab/activity-type/` | 6 | `rico:hasActivityType` (per [mapping.md §6.5](/spec/mapping.html)) |
| [Rule Type](rule-type.html) | `https://openric.org/vocab/rule-type/` | 8 | `rico:hasOrHadRuleType` (per [mapping.md §9](/spec/mapping.html)) |

Each vocabulary is dereferenceable as Turtle (e.g. [`activity-type.ttl`](activity-type.ttl)) and described inline as a SKOS ConceptScheme. Concept IRIs follow the pattern `{scheme-IRI}{slug}` (e.g. `https://openric.org/vocab/activity-type/production`).

## Versioning policy

OpenRiC vocabularies follow a **strict-additive** policy at this scheme path:

- Adding a new Concept is non-breaking and lands without a version bump.
- Renaming or removing a Concept requires a new versioned scheme (`/v2/activity-type/`).
- Concept slugs are stable IRIs - they never change once minted.

Implementations MAY pin a specific version where exact stability matters; the unversioned scheme path is the recommended default.

## Reference projects

- [Garance](https://rdf.archives-nationales.culture.gouv.fr/garance/pages/en/) - Archives nationales de France public RDF/SKOS reference-data publication, an architectural benchmark for OpenRiC vocabulary publication patterns.
- [ICA-EGAD RiC-O 1.1 vocabularies](https://github.com/ICA-EGAD/RiC-O/tree/master/vocabularies) - the official RiC-O auxiliary vocabularies (RecordSetType, AgentNameType, etc.) - OpenRiC vocabularies sit alongside, not in place of, these.

## Licence

[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) - fork, extend, propose new concepts via the [openric/spec discussions](https://github.com/openric/spec/discussions).
