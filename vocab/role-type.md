---
layout: default
title: OpenRiC Role-Type Vocabulary
permalink: /vocab/role-type.html
---

# OpenRiC Role-Type Vocabulary

**Scheme IRI:** `https://openric.org/vocab/role-type/`
**Status:** Active (spec v{{ site.data.version.version }}) · **Issued:** 2026-10-19 · **Licence:** [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
**Machine-readable:** [role-type.ttl](role-type.ttl) (Turtle)

A SKOS ConceptScheme of the roles an agent plays in a relation: the bride at a wedding, the witness at a hearing, the donor of a deposit. Each concept is **also** a `rico:RoleType`. RiC-O 1.1 qualifies a role only on a creation relation, with `rico:creationWithRole`, and defines the `rico:RoleType` class without a vocabulary; OpenRiC's `openricx:relationHasAgentRole` carries a role on any relation. The values of both come from here.

## Concepts

| IRI | prefLabel | Broader | Definition |
|---|---|---|---|
| [`spouse`](https://openric.org/vocab/role-type/spouse) | Spouse | - | A party to a marriage or civil union, in the event that creates it. |
| [`bride`](https://openric.org/vocab/role-type/bride) | Bride | `spouse` | A woman party to a marriage, as the record names her. |
| [`groom`](https://openric.org/vocab/role-type/groom) | Groom | `spouse` | A man party to a marriage, as the record names him. |
| [`witness`](https://openric.org/vocab/role-type/witness) | Witness | - | An agent who attests to an event or to the making of a record, such as a marriage, a signature or a court hearing. |
| [`donor`](https://openric.org/vocab/role-type/donor) | Donor | - | An agent who gave records or other material to the holding institution. |
| [`editor`](https://openric.org/vocab/role-type/editor) | Editor | - | An agent who prepared a record or a publication for issue, compiling or revising the work of others. |
| [`translator`](https://openric.org/vocab/role-type/translator) | Translator | - | An agent who rendered a record, or a performance, into another language. |
| [`performer`](https://openric.org/vocab/role-type/performer) | Performer | - | An agent who took part in a performance, such as a recital, a play or a recorded broadcast. |
| [`conductor`](https://openric.org/vocab/role-type/conductor) | Conductor | `performer` | An agent who directed a musical performance. |
| [`resident`](https://openric.org/vocab/role-type/resident) | Resident | - | A person living in an institution or place of care during an episode of care. |
| [`carer`](https://openric.org/vocab/role-type/carer) | Carer | - | An agent who provided care to a person during an episode of care. |

Each concept page gives its scope note: which relation the role belongs on.

## Use

```json
{
  "@type": "rico:EventRelation",
  "rico:relationHasSource": { "@id": "https://archives.example.org/activity/wedding-1886" },
  "rico:relationHasTarget": { "@id": "https://archives.example.org/agent/smith-mary" },
  "openricx:relationHasAgentRole": { "@id": "https://openric.org/vocab/role-type/bride" }
}
```

A role is a property of the relation, not of the agent: the same person can be a witness at one event and a spouse at another. Labels are English only for now; labels in other languages are welcome through the [openric/spec discussions](https://github.com/openric/spec/discussions), as are new roles under the [vocabulary policy](/vocab/index.html#versioning-policy).
