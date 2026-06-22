---
layout: default
title: OpenRiC - Provenance & Event Profile
description: The full event model - Production, Accumulation, and generic Activities with required results, participants, and dates. Where Authority & Context makes events browseable, Provenance & Event makes them accountable.
---

# Provenance & Event Profile

**Profile id:** `provenance-event`
**Profile version:** 0.8.0
**Spec version:** 0.35.0
**Status:** Normative
**Dependencies:** **Authority & Context** (a server cannot claim Provenance & Event without also exposing Places, Rules, and Activities as first-class entities - this profile *tightens* authority-context's Activity shapes rather than redefining them).
**Last updated:** 2026-04-21

---

## 1. Purpose

Provenance & Event is the profile for **accountable archival events**. Authority & Context lets a client fetch a `rico:Activity` as a first-class entity with a name and a date; Provenance & Event requires that same activity to declare *what record it produced* and *who produced it*. Without those two cross-entity links, an event is a ghost - a timestamp with no accountability.

In RiC-O 1.1 every event is the single class `rico:Activity` (the concrete subclasses `rico:Production` / `rico:Accumulation` that earlier OpenRiC drafts assumed do not exist in the canonical ontology). OpenRiC distinguishes event kinds via `rico:hasActivityType` carrying an IRI from the activity-type vocabulary defined in `spec/mapping.md` §6.5 (`<https://openric.org/vocab/activity-type/{production,accumulation,custody,transfer,publication,reproduction}>`).

A server implementing this profile commits to three things, above and beyond what Authority & Context already requires:

1. **Production-typed Activities** (`rico:hasActivityType <…/production>`) MUST carry `rico:resultsOrResultedIn` + `rico:hasOrHadParticipant` + `rico:isAssociatedWithDate` - the three invariants of a production event. Each cross-entity link MUST point at a resolvable entity of the correct RiC-O class (a Record for results, an Agent for participants).
2. **Accumulation-typed Activities** (`rico:hasActivityType <…/accumulation>`) MUST carry `rico:resultsOrResultedIn` + `rico:isAssociatedWithDate` - the accumulating agent is Warning-level, since many historical accumulations have no named actor.
3. **Every generic `rico:Activity`** (custody, publication, reproduction, etc.) MUST carry a date - an event without a date is unplottable in a provenance timeline. Results and participants stay Warning-level for the generic fallback class.

Provenance & Event **depends on Authority & Context**. A server that has not first declared Authority & Context cannot claim this profile - its Activity shapes are the foundation this profile sharpens.

## 2. Scope

### 2.1 What this profile tightens

Provenance & Event does **not** add new endpoints. The endpoints `GET /api/ric/v1/activities` and `GET /api/ric/v1/activities/{id}` are defined by Authority & Context §2.1; Provenance & Event tightens what the *response body* from those endpoints MUST contain.

In SHACL terms, both profile shape files apply; the stricter constraint wins. A server that claims both profiles has its Activity responses validated against:

```
shapes/profiles/authority-context.shacl.ttl   (Warnings on results/participants/date)
shapes/profiles/provenance-event.shacl.ttl    (Violations on results/participants/date)
```

The Violations dominate - a response emitting a Production without `rico:resultsOrResultedIn` fails `provenance-event` conformance even though it still passes `authority-context`.

### 2.2 Forbidden without additional profile claims

- **Everything Authority & Context forbids** (writes, cross-entity graph traversal, etc.) - those remain forbidden here.
- **Inventing concrete `rico:Activity` subclasses.** Implementations MUST NOT emit `@type` values like `rico:Production`, `rico:Accumulation`, `rico:CustodyEvent`, or `openric:Transfer` - they are not defined in RiC-O 1.1. The `@type` is always `rico:Activity`; event-kind dispatch belongs in `rico:hasActivityType`. Local taxonomy hints (legacy event-type strings) go in `openric:localType`.

### 2.3 Content types

Same as Authority & Context: `application/ld+json` (success) or `application/problem+json` (errors).

## 3. Response shapes

### 3.1 Production-typed Activity - full shape

A production-typed Activity response under Provenance & Event MUST include all three invariants plus any Authority & Context fields:

```json
{
  "@context": { "rico":     "https://www.ica.org/standards/RiC/ontology#",
                "openric":  "https://openric.org/ns/v1#",
                "openricx": "https://openric.org/ns/ext/v1#",
                "xsd":      "http://www.w3.org/2001/XMLSchema#" },
  "@id":               "https://example.org/activity/910378",
  "@type":             "rico:Activity",
  "rico:hasActivityType": { "@id": "https://openric.org/vocab/activity-type/production" },
  "rico:name":         "Production of funeral boat model",
  "openric:localType": "production",

  "rico:isAssociatedWithDate": {
    "@type":              "openricx:DateRange",
    "rico:beginningDate": { "@value": "1961-01-01", "@type": "xsd:date" },
    "rico:endDate":       { "@value": "1999-01-01", "@type": "xsd:date" },
    "rico:expressedDate": "1961–1999"
  },

  "rico:resultsOrResultedIn": {
    "@id":        "https://example.org/recordset/905228",
    "@type":      "rico:RecordSet",
    "rico:name":  "Egyptian Boat"
  },

  "rico:hasOrHadParticipant": {
    "@id":        "https://example.org/corporatebody/905206",
    "@type":      "rico:CorporateBody",
    "rico:name":  "The British Museum"
  },

  "rico:hasOrHadLocation": {
    "@id":        "https://example.org/place/912151",
    "@type":      "rico:Place",
    "rico:name":  "Thebes (Luxor)"
  }
}
```

**Required** (Violation at SHACL level if missing):

| Field | Cardinality | Notes |
|---|---|---|
| `rico:resultsOrResultedIn` | 1..* | Embedded stub `{@id, @type, rico:name}` of the produced Record(s). `@type` MUST resolve to `rico:RecordSet`, `rico:Record`, or `rico:RecordPart`. (RiC-O 1.1 also defines `rico:affectsOrAffected` as a more general Activity→RecordResource link; either is canonical, per Florence Clavaud / KM Q&A #27.) |
| `rico:hasOrHadParticipant` | 1..* | Embedded stub of the creator Agent. `@type` MUST resolve to `rico:Person`, `rico:CorporateBody`, `rico:Family`, `rico:Mechanism`, or `rico:Agent`. (The inverse `rico:isOrWasPerformedBy` is also canonical and used interchangeably by ICA-EGAD examples; implementations MAY emit either.) |
| `rico:isAssociatedWithDate` | 1 | A structured `openricx:DateRange` (not a bare `xsd:date` string). |

**Required when the source data has them**: all Authority & Context §3.4 fields (`@id`, `@type`, `rico:name`).

**Optional**: `rico:hasOrHadLocation` (Place stub), `rico:authorizingMandate` → `rico:Mandate` (the legal/policy basis for the event, replaces the non-canonical `rico:hasReasonForExecution`), `rico:followsInTime` / `isOrWasPrecededBy` (event chaining).

### 3.2 Accumulation-typed Activity - full shape

Same `@type: rico:Activity` and same `hasActivityType` mechanism, with `<…/accumulation>` as the IRI. `hasOrHadParticipant` relaxes to SHOULD (Warning):

**Required** (Violation):

| Field | Cardinality | Notes |
|---|---|---|
| `rico:resultsOrResultedIn` | 1..* | Same typing rule as §3.1 |
| `rico:isAssociatedWithDate` | 1 | Structured `openricx:DateRange` |

**Strongly recommended** (Warning): `rico:hasOrHadParticipant` - the accumulating agent. Present when the source data knows it; often absent for historical accumulations (inherited collections, unidentified donors).

### 3.3 Generic `rico:Activity` - fallback shape

Activities whose `hasActivityType` is `<…/custody>`, `<…/publication>`, `<…/reproduction>`, `<…/transfer>`, or absent entirely (per `spec/mapping.md` §6.5) satisfy weaker shape rules:

**Required** (Violation):

| Field | Cardinality | Notes |
|---|---|---|
| `rico:isAssociatedWithDate` | 1 | Still required - an undatable event has no place on a timeline |

**Strongly recommended** (Warning): `rico:hasActivityType` - lets consumers dispatch on `custody` / `publication` / `reproduction` without parsing `openric:localType` strings.

**Optional** (no SHACL constraint): `rico:resultsOrResultedIn`, `rico:hasOrHadParticipant`, `rico:hasOrHadLocation`.

See the `activity-custody` fixture for the canonical generic-Activity example.

### 3.4 Cross-entity link typing

Whenever `rico:hasOrHadParticipant` appears (on any Activity), its target MUST be an Agent subclass (`:ParticipantTypeShape`). Whenever `rico:resultsOrResultedIn` appears, its target MUST be a Record type (`:ResultTypeShape`). These shapes run on **any** subject carrying the predicate - including Activity subclasses that don't require the predicate. The rule: if you emit it, you emit it correctly.

## 4. Error handling

Error responses MUST follow Core Discovery §4 / §4.1 verbatim - `application/problem+json` with the nine registered error-type URIs. Provenance & Event uses:

- `404 not-found` - missing activity ID
- `400 bad-request` - nonsense filter on `/activities` list

No Provenance & Event-specific error types are defined.

## 5. SHACL shapes

Responses validate against `shapes/profiles/provenance-event.shacl.ttl`:

| Shape | Target | Severity model |
|---|---|---|
| `:StrictProductionShape` | `rico:Activity` where `hasActivityType = <…/production>` (sh:SPARQLTarget) | `sh:Violation` on missing `resultsOrResultedIn`, `hasOrHadParticipant`, or `isAssociatedWithDate` |
| `:StrictAccumulationShape` | `rico:Activity` where `hasActivityType = <…/accumulation>` (sh:SPARQLTarget) | `sh:Violation` on missing `resultsOrResultedIn` or date; `sh:Warning` on missing participant |
| `:StrictActivityShape` | `rico:Activity` (all) | `sh:Violation` on missing date; `sh:Warning` on missing `hasActivityType` |
| `:ParticipantTypeShape` | subjects of `rico:hasOrHadParticipant` | `sh:Violation` if target is not a Person / CorporateBody / Family / Agent |
| `:ResultTypeShape` | subjects of `rico:resultsOrResultedIn` | `sh:Violation` if target is not a RecordSet / Record / RecordPart |

Shapes are **open** - unknown predicates do not cause failure. A server claiming both `authority-context` and `provenance-event` has both shape files applied; the stricter constraints dominate (SHACL shape accumulation).

## 6. Conformance testing

A server claims `provenance-event` when, for every activity exposed under `/activities`:

1. `@type` is `rico:Activity` (never a Production / Accumulation / Custody subclass - those are not in RiC-O 1.1).
2. Production-typed Activities (`hasActivityType <…/production>`) validate against `:StrictProductionShape` at Violation severity - all three required fields present and correctly typed.
3. Accumulation-typed Activities validate against `:StrictAccumulationShape` at Violation severity.
4. All Activities validate against `:StrictActivityShape` at Violation severity - date required.
5. Every `rico:hasOrHadParticipant` target is an Agent subclass per `:ParticipantTypeShape`.
6. Every `rico:resultsOrResultedIn` target is a Record type per `:ResultTypeShape`.
7. The activity can be linked to and walked from a Record's `rico:isOrWasSubjectOf` (verifiable when combined with Graph Traversal).

Run the conformance probe with `--profile=provenance-event` to exercise these checks against a live server.

## 7. Fixture pack

The manifest declares these two fixtures as normative for `provenance-event`:

| Fixture | Status | What it pins |
|---|---|---|
| `activity-production-full` | done | Full-context Production - results + participant + dates + location + `openricx:DateRange` structure |
| `activity-custody` | done | Generic Activity fallback - custody transfer with date + location + participant (optional in this class) |

Fixtures `activity-production` and `activity-accumulation` remain tagged for **`authority-context` only** - they do not carry the cross-entity links this profile requires and would fail `:StrictProductionShape` / `:StrictAccumulationShape`. This is intentional: a server claiming both profiles must emit the tighter shape.

## 8. Implementation checklist

- [ ] Type every event as `rico:Activity` (never a custom subclass) and emit `rico:hasActivityType` with an IRI from `https://openric.org/vocab/activity-type/`
- [ ] Production-typed Activities: include `rico:resultsOrResultedIn` (Record stub) AND `rico:hasOrHadParticipant` (Agent stub) AND `rico:isAssociatedWithDate` (`openricx:DateRange`)
- [ ] Accumulation-typed Activities: include `rico:resultsOrResultedIn` AND `rico:isAssociatedWithDate` (participant optional)
- [ ] Generic Activities (custody, publication, etc.): include `rico:isAssociatedWithDate` - results + participants + location all optional
- [ ] Embed cross-entity links as `{@id, @type, rico:name}` stubs - not bare URI strings
- [ ] `@type` on participants always resolves to Person / CorporateBody / Family / Agent
- [ ] `@type` on results always resolves to RecordSet / Record / RecordPart
- [ ] `rico:hasActivityType` emitted on generic Activities so consumers can dispatch on `custody` / `publication` / `reproduction`
- [ ] Add `provenance-event` to `openric_conformance.profiles` in `GET /` - only after `authority-context` is already declared
- [ ] Run the conformance probe with `--profile=provenance-event` - both shipped fixtures pass
- [ ] `/conformance/badge?profile=provenance-event` returns shields.io JSON

## 9. Design decisions

Five questions were flagged during drafting; all five carry resolutions.

### Q1 - Is `hasOrHadParticipant` Required on Accumulation, or only on Production?

**Resolution**: **Required on Production (Violation); Recommended on Accumulation (Warning).**

**Rationale**: Production is always a deliberate act with an identifiable actor - even "anonymous 19th-century photographer" is a named placeholder. Accumulation is often passive - records arrive through inheritance, transfer from a defunct organisation, a chain of custody whose middle is lost. Requiring a participant on every Accumulation would push implementations to invent placeholders, which corrupts the data. Warning severity matches the archival reality: participant is STRONGLY preferred but not mandated.

### Q2 - Should custody / publication / reproduction get their own `@type` subclasses?

**Resolution**: **No. RiC-O 1.1 has only the parent class `rico:Activity` - there are no concrete event subclasses (Production, Accumulation, CustodyEvent, Transfer all do *not* exist in 1.1). Every event is `@type: rico:Activity`, distinguished by `rico:hasActivityType`.**

**Rationale**: Earlier OpenRiC drafts (≤ v0.36) assumed `rico:Production` / `rico:Accumulation` were concrete classes; the [RiC-O 1.1 audit](../../audit/ric-o-1.1-audit.html) showed they are not. Inventing local subclasses would either (a) fork RiC-O, or (b) bake an anglosphere / archival-theory-of-the-moment taxonomy into the spec. The accepted pattern is `@type: rico:Activity` + `rico:hasActivityType: <https://openric.org/vocab/activity-type/{kind}>` + `openric:localType: "{kind}"`, which preserves the RiC-O class hierarchy, gives consumers a queryable dispatch key, and keeps the profile honest against the canonical ontology. If RiC-O v2 ever adds concrete subclasses, Provenance & Event will track them.

### Q3 - Must cross-entity links resolve to existing entities (404 check), or only validate by type?

**Resolution**: **Type-check only in this profile. Existence check is Graph Traversal's `:OrphanedRecordShape` / `:UnlinkedAgentShape`.**

**Rationale**: Validating that every `@id` on a Production's `rico:resultsOrResultedIn` actually resolves to a live Record requires fetching every cross-linked entity - that's a full-graph check and belongs in Graph Traversal (§5.2). Provenance & Event runs on single-endpoint responses and can only validate what's in front of it: the type of the stub, the presence of the link. A server that emits a link to a Record that was later deleted gets a SHACL Warning at Graph Traversal level, not a Violation here.

### Q4 - `openricx:DateRange` as a structured sub-object, or allow bare `xsd:date` strings?

**Resolution**: **Structured `openricx:DateRange` object, always.**

**Rationale**: Bare date strings discard two things that archival dates need: date qualifiers (`circa 1961`, `between 1961 and 1999`) and range endpoints. The OpenRiC extension class `openricx:DateRange` accommodates both via `rico:beginningDate`, `rico:endDate`, and `rico:expressedDate` (free text for "early 1960s", "Ming dynasty", "before the French Revolution"). RiC-O 1.1 dropped the `DateRange` class itself - OpenRiC keeps it under the extension namespace as an API convenience while the canonical RDF can use native RiC-O 1.1 date patterns where the source data has clean ISO-8601 endpoints. Mandating the structured shape from v0.8 prevents the bare-string pattern from becoming entrenched and requires retrofits later.

### Q5 - Reference implementation does not currently emit `resultsOrResultedIn` or `hasOrHadParticipant`. Freeze the profile anyway?

**Resolution**: **Yes. Freeze the spec; the reference implementation will catch up.**

**Rationale**: `RicSerializationService::serializeActivity()` (service v0.8.12) emits Production events with `@type`, name, date, and location - but no cross-entity links. This means the reference server at `ric.theahg.co.za` currently conforms to `authority-context` for its activities but **not** to `provenance-event`. Two options were weighed: (a) soften the profile to match current implementation behaviour, (b) freeze the stricter spec and file the impl gap as a known next-release task. Option (a) defeats the purpose of having Provenance & Event as a distinct profile - it would collapse into Authority & Context. Option (b) matches the pattern IIIF has followed since day one: spec first, impl chases. The gap is a dozen-line fix to the serializer's activity-composition logic (add a SELECT for linked records + participants, embed them as stubs) - planned for a future service release. Until then, no server currently claims `provenance-event` in its `openric_conformance.profiles`, and that is honest. A spec that reflects only what the reference already does is a description, not a specification.
