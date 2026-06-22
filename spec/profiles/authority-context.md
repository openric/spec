---
layout: default
title: OpenRiC - Authority & Context Profile
description: First-class Places, Rules, and Activities with reconciliation-friendly identifiers. The contextual entities that qualify records.
---

# Authority & Context Profile

**Profile id:** `authority-context`
**Profile version:** 0.4.0
**Spec version:** 0.31.0
**Status:** Normative
**Dependencies:** None - orthogonal to Core Discovery
**Last updated:** 2026-04-21

---

## 1. Purpose

Authority & Context is the OpenRiC profile for **the contextual entities that qualify a record** - the places records are about or from, the rules (legislation, mandates, policies) records were created under, and the activities (production, accumulation, custody) that brought records into being or kept them moving. Core Discovery lets a client find a record and its custodial agent; Authority & Context lets that client answer *where, under what rule, and during which event*.

A server implementing this profile commits to three things:

1. **Expose `rico:Place`, `rico:Rule`, `rico:Activity` entities** at stable URIs under `/api/ric/v1/{places,rules,activities}/{id}`. Activities carry `rico:hasActivityType` (production / accumulation / custody / etc.) per `spec/mapping.md` §6.5; there are no concrete `rico:Activity` subclasses in RiC-O 1.1.
2. **Carry reconciliation-friendly identifiers** on those entities - at minimum `owl:sameAs` links to an external authority (GeoNames, VIAF, Wikidata, a local thesaurus URI) whenever the backing data has one. This is what makes OpenRiC authorities *useful* to the wider linked-data ecosystem rather than yet another walled garden.
3. **Preserve hierarchy and qualification structure** - place parentage via `rico:isOrWasPartOf`, date ranges on activities via `rico:isAssociatedWithDate → openricx:DateRange`, jurisdictions on rules via `openric:jurisdiction`.

This profile is **orthogonal to Core Discovery**: a server MAY claim Authority & Context without Core Discovery (useful for servers that primarily expose thesauri / place authorities and do not hold records), and vice versa. A server that holds records *and* wants to expose their contextual authority should claim both.

## 2. Scope

### 2.1 Required endpoints

A conformant server MUST expose:

| Verb | Path | Returns |
|---|---|---|
| GET | `/api/ric/v1/places` | Place list, paginated |
| GET | `/api/ric/v1/places/{id}` | Single Place as JSON-LD |
| GET | `/api/ric/v1/rules` | Rule list, paginated |
| GET | `/api/ric/v1/rules/{id}` | Single Rule as JSON-LD |
| GET | `/api/ric/v1/activities` | Activity list, paginated |
| GET | `/api/ric/v1/activities/{id}` | Single Activity as JSON-LD |

Pagination rules match Core Discovery §3.3 (default page size 50, max 200, `openric:total`/`openric:page`/`openric:limit`/`openric:items`).

### 2.2 Optional endpoints

| Verb | Path | Purpose |
|---|---|---|
| GET | `/api/ric/v1/places/flat` | Flattened place hierarchy (one row per place, parent_id column) - convenience for clients that cannot walk `rico:isOrWasPartOf` recursively |

Servers MAY expose additional endpoints (e.g., a type-filtered `/places?type=country`). Any such endpoint outside this table is outside the profile's normative surface.

### 2.3 Forbidden without additional profile claims

- **Write verbs** (POST, PATCH, DELETE) on `/places|/rules|/activities`. Write conformance lives in Round-Trip Editing.
- **Cross-entity graph traversal** (`/graph?uri=…&depth=N`). Graph walking lives in Graph Traversal.
- **Agents exposed as Places** or similar cross-wiring. Each entity must keep its RiC-O class.

### 2.4 Content types

All responses MUST be `application/ld+json` (success) or `application/problem+json` (errors, per Core Discovery §4). The `@context` declared on list envelopes MUST bind `rico` to the ontology IRI and `openric` to `https://openric.org/ns/v1#`.

## 3. Response shapes

### 3.1 Place - `GET /places/{id}`

A Place is a location or geographic entity. At minimum: `@id`, `@type: "rico:Place"`, and a name (either `rico:name` shorthand OR a structured `rico:hasOrHadPlaceName`). Everything else is OPTIONAL but SHOULD be emitted when the backing data carries it.

```json
{
  "@context": { "rico": "https://www.ica.org/standards/RiC/ontology#",
                "owl":  "http://www.w3.org/2002/07/owl#",
                "xsd":  "http://www.w3.org/2001/XMLSchema#" },
  "@id":              "https://example.org/place/912150",
  "@type":            "rico:Place",
  "rico:name":        "Egypt",
  "openricx:description": "Ancient Egypt, Nile Valley region.",
  "openricx:streetAddress": "Egypt, North Africa",
  "openric:localType": "country",
  "rico:latitude":     30.0444196,
  "rico:longitude":    31.2357116,
  "owl:sameAs":        "https://www.geonames.org/357994/egypt.html"
}
```

**Required:**

| Field | Cardinality | Notes |
|---|---|---|
| `@id` | 1 | Stable, dereferenceable URI |
| `@type` | 1 | MUST be `rico:Place` |
| `rico:name` OR `rico:hasOrHadPlaceName` | 1 | At least one form of name |

**Optional but normative when present:**

| Field | Notes |
|---|---|
| `openricx:description` | Free-form description |
| `openricx:streetAddress` | Single-line address |
| `rico:latitude`, `rico:longitude` | Decimal degrees, WGS84 |
| `openric:localType` | Implementation-specific tag (`country`, `city`, `site`, `region`, …) |
| `owl:sameAs` | Authority URI - GeoNames, Wikidata, Getty TGN. **STRONGLY RECOMMENDED when the backing row has one.** |
| `rico:isOrWasPartOf` | Parent Place, embedded as a stub with `@id`, `@type: "rico:Place"`, `rico:name` |

### 3.2 Place hierarchy - `rico:isOrWasPartOf`

Places form a tree via `rico:isOrWasPartOf`. A nested place MUST embed its parent as a stub (not a full Place), so clients can walk one level up without a second fetch. Deeper ancestors require either a second call to the parent's `@id` or a walk of `/places/flat`.

```json
{
  "@id": "https://example.org/place/912151",
  "@type": "rico:Place",
  "rico:name": "Thebes (Luxor)",
  "rico:isOrWasPartOf": {
    "@id": "https://example.org/place/912150",
    "@type": "rico:Place",
    "rico:name": "Egypt"
  }
}
```

### 3.3 Rule - `GET /rules/{id}`

A Rule is a law, regulation, mandate, policy, or other governing instrument. At minimum: `@id`, `@type: "rico:Rule"`, and `rico:title`. The SHACL `:RuleShape` additionally requires that **at least one** of `openricx:descriptiveNote` or `rico:hasOrHadRuleType` is present - a Rule with only a title carries no actionable semantics.

```json
{
  "@id":                "https://example.org/rule/912155",
  "@type":              "rico:Rule",
  "rico:title":         "Egyptian Antiquities Protection Law (Law 117/1983)",
  "rico:name":          "Egyptian Antiquities Protection Law (Law 117/1983)",
  "openricx:description":   "Egyptian law governing the protection and export of antiquities.",
  "rico:hasOrHadRuleType":      "law",
  "openric:localType":  "law",
  "openric:jurisdiction": "Egypt",
  "openricx:descriptiveNote": "Law No. 117 of 1983, Arab Republic of Egypt. Amended 2010.",
  "dcterms:source":     "Supreme Council of Antiquities, Ministry of Tourism and Antiquities",
  "owl:sameAs":         "https://en.wikipedia.org/wiki/Law_No._117_of_1983",
  "openricx:hasDateRangeSet": {
    "@type":            "openricx:DateRange",
    "rico:beginningDate": { "@value": "1983-01-01", "@type": "xsd:date" }
  }
}
```

**Required:** `@id`, `@type: "rico:Rule"`, `rico:title`, AND either `openricx:descriptiveNote` or `rico:hasOrHadRuleType`.

**Optional but normative when present:** `openricx:description`, `rico:hasOrHadRuleType` (`law`, `regulation`, `mandate`, `policy`, `custom`), `openric:jurisdiction`, `dcterms:source`, `owl:sameAs`, `openricx:hasDateRangeSet`.

### 3.4 Activity - `GET /activities/{id}`

Activities are events - things that happened to or with records. RiC-O 1.1 has only the parent class `rico:Activity` (no concrete `rico:Production` / `rico:Accumulation` subclasses); OpenRiC distinguishes event kinds via `rico:hasActivityType` carrying an IRI from the activity-type vocabulary defined in `spec/mapping.md` §6.5:

- `<https://openric.org/vocab/activity-type/production>` - creation, contribution, any event that **produced** records
- `<https://openric.org/vocab/activity-type/accumulation>` - aggregation, collection-building, any event that **brought records together**
- `<https://openric.org/vocab/activity-type/custody>`, `<…/transfer>`, `<…/publication>`, `<…/reproduction>` - for events that don't fit the two above

Servers MUST emit the activity-type IRI that best matches the backing event-type taxonomy. Omitting `hasActivityType` on a backing event-type that *does* have a canonical mapping is a conformance failure at SHACL level (the per-type shapes have stricter recommendations).

```json
{
  "@id":        "https://example.org/activity/910378",
  "@type":      "rico:Activity",
  "rico:hasActivityType": { "@id": "https://openric.org/vocab/activity-type/production" },
  "rico:name":  "Creation",
  "openric:localType": "production",
  "rico:isAssociatedWithDate": {
    "@type":             "openricx:DateRange",
    "rico:beginningDate": { "@value": "1961-01-01", "@type": "xsd:date" },
    "rico:endDate":       { "@value": "1999-01-01", "@type": "xsd:date" },
    "rico:expressedDate": "1961"
  }
}
```

**Required:** `@id`, `@type: "rico:Activity"`, `rico:name`. `rico:hasActivityType` is required when the backing data has a canonical event-type (Warning if absent for unknown event types).

**Strongly recommended** (Warning at SHACL level - see §5):

- `rico:isAssociatedWithDate` → `openricx:DateRange` - activities without a date are hard to reason about.
- For production-typed Activities: `rico:resultsOrResultedIn` (at least one resulting Record) and `rico:hasOrHadParticipant` (the creator agent).
- For accumulation-typed Activities: `rico:resultsOrResultedIn`.

Cross-entity references (`rico:resultsOrResultedIn`, `rico:hasOrHadParticipant`) MAY be emitted as stubs (just `@id` + `@type`) or as full embedded objects - implementations SHOULD use stubs on single-entity responses and full objects only when the depth is requested via `/graph` (Graph Traversal profile).

### 3.5 List envelopes

List responses follow the Core Discovery §3.3 shape. Specifically:

- `/places` → `openricx:PlaceList`
- `/rules` → `openricx:RuleList`
- `/activities` → `openricx:ActivityList`

Each list envelope wraps `openric:items` as an array of **stubs** containing `@id`, `@type`, `rico:name`, and the implementation's `openric:localType` if it carries one. Full shapes are only returned on single-entity GET.

## 4. Error handling

Error responses MUST follow Core Discovery §4 and §4.1 - `application/problem+json` with the nine registered error-type URIs under `https://openric.org/errors/`. In particular:

- `404 not-found` on missing place/rule/activity IDs.
- `400 bad-request` if a list query carries a nonsense filter (e.g., `?type=unknown`).
- `422 validation-failed` is reserved for write endpoints (Round-Trip Editing), not Authority & Context reads.

No Authority & Context-specific error types are defined. Implementations MUST NOT mint error-type URIs under `https://openric.org/errors/` for this profile.

## 5. SHACL shapes

Authority & Context responses MUST validate against the profile-scoped shape file:

```
shapes/profiles/authority-context.shacl.ttl
```

This file contains:

| Shape | Target | Severity model |
|---|---|---|
| `:PlaceShape` | `rico:Place` | `sh:Violation` on missing name; `sh:Info` on malformed `rico:hasOrHadPlaceName` |
| `:PlaceNameShape` | inline on `rico:hasOrHadPlaceName` values | `sh:Violation` on missing `rico:textualValue` |
| `:ProductionShape` | `rico:Activity` where `hasActivityType = <…/production>` (sh:SPARQLTarget) | All three recommendations (`resultsOrResultedIn`, `hasOrHadParticipant`, `isAssociatedWithDate`) at `sh:Warning` |
| `:AccumulationShape` | `rico:Activity` where `hasActivityType = <…/accumulation>` (sh:SPARQLTarget) | `sh:Warning` on missing `resultsOrResultedIn` |
| `:ActivityShape` | `rico:Activity` (all) | `sh:Info` on missing `hasActivityType` |
| `:RuleShape` | `rico:Rule` | `sh:Violation` on missing title; `sh:Warning` on missing `ruleType`; OR-constraint between `descriptiveNote` and `ruleType` |

Shapes are **open** - unknown predicates do not cause failure. Implementations MAY emit private metadata under their own prefix without affecting validation.

The OR-constraint in `:RuleShape` is the only structural coupling worth flagging: a Rule that carries *neither* `openricx:descriptiveNote` *nor* `rico:hasOrHadRuleType` is a SHACL Violation, because it would be impossible for a client to know what kind of rule it is.

## 6. Conformance testing

A server claims `authority-context` if, for every entity exposed under `/places`, `/rules`, `/activities`:

1. The single-entity endpoint returns `application/ld+json` with HTTP 200.
2. The response validates against `shapes/profiles/authority-context.shacl.ttl` at `sh:Violation` severity.
3. For entities whose backing row has an authority identifier, `owl:sameAs` is emitted.
4. Place parentage is walkable via `rico:isOrWasPartOf` - every emitted parent stub resolves to a valid Place.
5. Activity `@type` matches the backing event-type taxonomy per `spec/mapping.md` §6.5.

Run the conformance probe with `--profile=authority-context` to exercise only this profile's checks against a live server.

## 7. Fixture pack

The manifest declares these seven fixtures as normative for `authority-context`:

| Fixture | What it pins |
|---|---|
| `place-country` | Minimal `rico:Place` with GeoNames `owl:sameAs`, lat/long, `openric:localType` |
| `place-with-parent` | Nested place with `rico:isOrWasPartOf` stub |
| `place-list` | List envelope with `openricx:PlaceList` @type + pagination metadata |
| `rule-law` | `rico:Rule` with type, jurisdiction, `owl:sameAs`, and `openricx:DateRange` |
| `activity-production` | `rico:Activity` with `hasActivityType <…/production>` and `rico:isAssociatedWithDate → openricx:DateRange` |
| `activity-accumulation` | `rico:Activity` with `hasActivityType <…/accumulation>` and minimal shape |
| `function-with-activities` | *(planned)* ISDF function with ≥2 activities - exercises cross-reference shape |

Fixtures outside this list are NOT required for profile conformance.

## 8. Implementation checklist

A server implementer works through:

- [ ] Expose the six required endpoints from §2.1
- [ ] Emit `@type: rico:Place | rico:Rule | rico:Activity` and add `rico:hasActivityType <…vocab IRI…>` for events with a canonical type
- [ ] Validate each response against `shapes/profiles/authority-context.shacl.ttl`
- [ ] Emit `owl:sameAs` for every entity whose backing row has an authority URI
- [ ] Preserve place hierarchy via `rico:isOrWasPartOf` stubs
- [ ] Emit date ranges on activities as `openricx:DateRange` structured objects (not loose `xsd:date` strings)
- [ ] Update `GET /` to include `authority-context` in `openric_conformance.profiles`
- [ ] Run the conformance probe with `--profile=authority-context` - all 6 shipped fixtures pass
- [ ] Emit badge URL `/conformance/badge?profile=authority-context` that returns shields.io-compatible JSON

## 9. Design decisions

Four questions were flagged during drafting; all four carry resolutions. Any resolution can be re-opened via a GitHub discussion citing the question ID.

### Q1 - Place hierarchy via `rico:isOrWasPartOf` stubs, or flat paths?

**Resolution**: **Stubs, with `/places/flat` as the convenience endpoint.**

**Rationale**: A nested-object shape preserves the RiC-native link semantics (the predicate itself carries meaning - "part of" not "child of") and lets SHACL validate that the parent `@type` is actually `rico:Place`. A flat path-string like `"Egypt > Luxor"` would be easier to render but harder to validate and brittle under renames. The `/places/flat` endpoint exists for clients that need the whole tree cheaply, as a single flat list with `parent_id` columns, but it is explicitly outside the normative per-entity shape.

### Q3 - `owl:sameAs` MUST or SHOULD?

**Resolution**: **SHOULD, gated on backing data.**

**Rationale**: Mandating `owl:sameAs` would force implementations to reject entities that simply don't have an external authority - which is most legacy archival catalogues. The STRONGLY RECOMMENDED wording in §3.1 captures the intent (OpenRiC is pro-reconciliation) without forcing implementations to fabricate authority URIs they don't have. An implementation with a populated-authority rate below ~30% is still conformant; one with 0% should look hard at its provenance story before claiming Authority & Context.

### Q4 - Activity subclass selection mandatory, or is `rico:Activity` always acceptable?

**Resolution**: **Mandatory subclass selection when the backing data supports it.**

**Rationale**: Emitting a generic `rico:Activity` with no `hasActivityType` for what is clearly a creation event erases the semantics that Authority & Context exists to expose. The mapping spec §6.5 defines the allowed event-type → activity-type-IRI rules; following them is part of conformance. If the backing data is genuinely ambiguous (the event-type column is empty or says "other"), omitting `hasActivityType` is fine - the `:ActivityShape` accepts that case at Info severity. Reviewers should push back when they see Activities with no `hasActivityType` dominating an implementation's /activities response; it's usually a sign the mapping layer is under-specified.

### Q5 - Rule `ruleType` vocabulary: open strings or fixed enumeration?

**Resolution**: **Open strings, with five conventional values RECOMMENDED.**

**Rationale**: `law`, `regulation`, `mandate`, `policy`, `custom` cover most archival usage and SHOULD be preferred when they fit. But rule types across jurisdictions are messier than any fixed list (e.g., "directive" vs "decree" vs "ordinance" vs "statute" vs "by-law"), and locking the vocabulary would bake anglosphere bias into the spec. Implementations that use a narrower local vocabulary MAY surface it via `openric:localType` alongside the broader `rico:hasOrHadRuleType`.
