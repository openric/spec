---
layout: default
title: OpenRiC Rule-Type Vocabulary
permalink: /vocab/rule-type.html
---

# OpenRiC Rule-Type Vocabulary

**Scheme IRI:** `https://openric.org/vocab/rule-type/`
**Status:** Active (spec v{{ site.data.version.version }}) · **Issued:** 2026-04-25 · **Licence:** [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
**Machine-readable:** [rule-type.ttl](rule-type.ttl) (Turtle)

A SKOS ConceptScheme of rule-type concepts referenced from `rico:hasOrHadRuleType` on `rico:Rule` instances. Used to classify rules by their function.

## Concepts

| IRI | prefLabel | Definition |
|---|---|---|
| [`law`](https://openric.org/vocab/rule-type/law) | Law | Statutory law — primary legislation enacted by a sovereign legislature. |
| [`regulation`](https://openric.org/vocab/rule-type/regulation) | Regulation | Regulatory instrument — secondary or delegated legislation, executive order, statutory instrument. |
| [`mandate`](https://openric.org/vocab/rule-type/mandate) | Mandate | Authority delegation or institutional mandate — what an Agent is authorised to do. |
| [`policy`](https://openric.org/vocab/rule-type/policy) | Policy | Internal policy or procedural rule. |
| [`custom`](https://openric.org/vocab/rule-type/custom) | Custom | Customary practice or convention with normative effect. |
| [`access-restriction`](https://openric.org/vocab/rule-type/access-restriction) | Access Restriction | A scoped restriction on access to records — by time period, role, purpose, or jurisdiction. |
| [`security-classification`](https://openric.org/vocab/rule-type/security-classification) | Security Classification | A formal security classification (e.g. 'Confidential', 'Restricted', 'Top Secret'). |
| [`access-rule`](https://openric.org/vocab/rule-type/access-rule) | Access Rule | A general access-governance rule. |

## Usage example

```turtle
<.../record/abc> rico:isOrWasRegulatedBy <.../rule/popia-2026> .
<.../rule/popia-2026> a rico:Rule ;
    rico:title "POPIA section 14 — personal data" ;
    rico:hasOrHadRuleType <https://openric.org/vocab/rule-type/access-restriction> .
```

See [mapping.md §9](/spec/mapping.html) for the full pattern.
