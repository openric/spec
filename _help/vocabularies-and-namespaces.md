---
title: Vocabularies & namespaces
category: Reference
order: 1
summary: The namespaces OpenRiC uses, the openricx extension ontology for terms RiC-O doesn't define, and how to read the vocabulary endpoints.
---

## Namespaces

| Prefix | IRI | Role |
|---|---|---|
| `rico:` | `https://www.ica.org/standards/RiC/ontology#` | RiC-O (the records ontology), pinned at **1.1** |
| `openricx:` | `https://openric.org/ns/ext/v1#` | OpenRiC **extension** terms RiC-O doesn't define |
| `skos:` | SKOS | thesauri / controlled vocabularies |
| `prov:` | PROV-O | provenance (incl. AI-asserted edges) |
| `crm:` | CIDOC-CRM 7.1.3 | optional museum bridge |

OpenRiC commits to **never minting new terms in the ICA `rico:` namespace** - anything RiC-O lacks lives in `openricx:`, documented in the [extension ontology](/ns/ext/v1.html) (machine-readable Turtle at [/ns/ext/v1.ttl](/ns/ext/v1.ttl)).

## The vocabulary endpoints

```bash
curl -s "https://ric.theahg.co.za/api/ric/v1/vocabulary"
curl -s "https://ric.theahg.co.za/api/ric/v1/vocabulary/ric_relation_type"
curl -s "https://ric.theahg.co.za/api/ric/v1/relation-types"
```

`relation-types` lists every relation code a server accepts (with domain/range metadata) - the source of truth for what you can put in a relation's `relation_type`.

## IRI policy

Public, dereferenceable entity IRIs follow `https://<host>/ric/<type>/<slug>`; internal node IRIs use `urn:ahg:ric:<type>:<id>`. See the [Governance profile](/spec/profiles/governance.html) for the two-layer model and the deprecate-not-delete rule.

## Next

- [Glossary](/help/glossary/)
- The [extension ontology](/ns/ext/v1.html)
