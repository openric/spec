---
layout: default
title: OpenRiC Drift Log - Public known issues
permalink: /drift-log.html
kind: current
---

# OpenRiC Drift Log

A public log of known drift between the OpenRiC specification and its public surfaces (reference API, viewer, capture client, OpenAPI metadata, conformance probe). Updated as items land or are resolved.

This page exists because the spec moves faster than the supporting implementations, and external reviewers need a single place to see *which* gaps are known, *where* they are, and *what's planned*. It is not a defect tracker - it tracks **deliberate** lag between the spec and downstream systems.

**Last updated:** 2026-10-19. For the live figures behind this page, see [current status](/status/).

---

## Open drift items

### Reference API (`ric.theahg.co.za`) lag against the specification

Re-checked item by item on 2026-10-15 against the live service (tag v0.17.12, then v0.17.13). It verifies against **spec v0.46.0** and declares seven profiles: six normative ones in full and SPARQL Access as a draft. Every row of the April 2026 migration list that is resolved has moved to [Closed](#closed-recent) with what was checked. These rows remain open:

| Item | Currently emits | Target | Blocker |
|---|---|---|---|
| Provenance & Event profile claim | Not claimed. The daily probe (15 October) finds the production activities carry their results and participants but no date (`openricx:DateRange`, §6.2 and §6.4). The serializer emits a date whenever the activity row has one. A count on 16 October found 40 undated activities (38 production, 1 accumulation, 1 untyped), and for none of them does the record's creation or accumulation event, or the event the activity was seeded from, carry a date. There is no source to take a date from, and dates will not be invented for demonstration data. | Claimed by a server whose activities are dated | Dated demonstration data, for example a new demonstration dataset for the reference service ([known issue K-10](spec/known-issues.html)). |
| Python HTTP clients refused | The web server in front of the reference service refuses requests whose `User-Agent` is a Python library default (`Python-urllib`, `python-requests`) with `403 Forbidden`, before they reach the API. Found 19 October 2026. A client that sends its own `User-Agent` is served normally. | Reads open to any client that respects the rate limit | A host-wide bot-blocking rule shared with other sites; exempting the API needs the operator's decision. |
| The public SPARQL graph is a static load | The graph behind `/sparql` (7,149 triples on 16 October) is not re-synced from the database the service shares with Heratio. Records deleted or renamed there stay in the graph: on 16 October four image records that no longer exist (404 through the API) were still in it, and records Heratio has added since the load are missing. | The graph kept in step with the database, by a scheduled resync with the extractor or a projection written by the service | A resync design, proposed on 19 October: a nightly rebuild from the same serializer the API uses, checked before it replaces the old graph. It is to be built and tested on staging. Until then, deletions that matter for rights or privacy are removed from the graph by hand. |
| One record, three identifiers | The API, `/graph` and the SPARQL graph name the same entity differently. The Egyptian Boat is `https://ric.theahg.co.za/informationobject/egyptian-boat` in the API's `@id`, `https://ric.theahg.co.za/default/recordset/905228` as a `/graph` node, and `https://ric.theahg.co.za/entity/record/905228` in the SPARQL graph. Only the first dereferences; the other two return 404. Found 19 October 2026. | One identifier per entity, the one the API gives in `@id`, used by `/graph` and SPARQL alike | The graph resync above, and a service release that changes `/graph` node ids, which re-captures the `subgraph-depth-1` and `subgraph-depth-2` fixtures. |

### External-extension watch (RiC-O 1.1 ecosystem)

| Item | Issue | Plan |
|---|---|---|
| AnF RiC-O extension | Archives nationales de France publishes a RiC-O 1.1 ontology extension, `AnF-ontology_v1.rdf`, at [`github.com/ArchivesNationalesFR/ontology`](https://github.com/ArchivesNationalesFR/ontology); the file has been in the repository since August 2025 and was last changed on 12 October 2026, with no tagged release. It may overlap with `openricx:` for agent description, addresses and places. | Audit `openricx:` against `AnF-ontology_v1.rdf`. Where they overlap, propose alignment or a cross-reference rather than parallel definitions. Not yet done. |
| OpenRiC vocabularies (`/vocab/activity-type/`, `/vocab/rule-type/`) need SKOS-publishing maturity | Currently published as static Turtle + HTML. Per the v2 review, the broader SKOS-publication pattern (HTML / JSON-LD / Turtle / RDF/XML / CSV per vocabulary, with `/vocabularies` index endpoint exposing each as a `skos:ConceptScheme`) is a Garance-style maturity step. | When an implementation other than the reference service asks for it. |
| `openricx:` extension namespace remains under-publicised | The Turtle ontology stub at [`/ns/ext/v1.html`](/ns/ext/v1.html) and its declared terms should be communicated to the EGAD-adjacent community. | Outreach drafts in [`docs/outreach/`](https://github.com/openric/spec/tree/main/docs/outreach) - Sparna and Damigos targets identified. |

---

## Closed (recent)

- **2026-10-16, public SPARQL graph** - The six properties that were not RiC-O 1.1 terms are renamed in place, after a full backup: `rico:hasOrHadAgentName` (371), `rico:hasOrHadSubject` for place access points (289), `rico:physicalCharacteristicsNote` (94), `rico:hasCreator` (30), `openricx:descriptiveNote` (17), `rico:hasContentOfType` (15). The extractor now writes the same terms, so a rebuild keeps them. The public graph uses no `rico:` property outside RiC-O 1.1.
- **2026-10-16, public SPARQL graph** - At Heratio's request, the statements of a record whose copyrighted content Heratio replaced, and of its creator, were removed from the graph (43 triples), with four records that no longer existed; no statement in the graph names them.
- **2026-10-16, demonstration data** - The Egyptian Boat's subgraph no longer shows the two instantiations of its removed third-party 3D model: both were unlinked from the boat (relation 912163 deleted, their record and file links cleared) and Heratio deleted the non-commercial file. The boat's graph has 19 nodes; the fixtures `subgraph-depth-1` and `subgraph-depth-2` are re-captured.
- **2026-10-16, service v0.17.14** - Relation predicates: the relation-type table shared with Heratio carries 25 pre-1.1 predicate names (`rico:hasInstantiation`, `rico:heldBy` and others). The service now maps each to its RiC-O 1.1 property (for example `rico:hasOrHadHolder`, `rico:isOrWasPartOf`, `rico:hasChild`) in the relation list, single relations, relations-for and graph edges, and stores the 1.1 name on new relations, without changing the shared data. Checked live: the relation list shows only RiC-O 1.1 names, and a search for `hasOrHadInstantiation` finds the 22 relations stored under the old name.
- **2026-10-15, service v0.17.13** - Five rows closed and checked on the live service:
  - **Node `type` in `/graph`:** CURIEs such as `rico:RecordSet` and `rico:Place`, as [Viewing API §8.6](spec/viewing-api.html#86-node-type-curie-policy) requires.
  - **Refusals:** a missing, invalid or expired key, or a missing scope, on `/api/ric/v1` returns an RFC 7807 problem document (`.../errors/authentication-required`, `application/problem+json`).
  - **Response headers:** `X-Content-Type-Options` and `Referrer-Policy` are sent once; `Referrer-Policy` had been sent twice with conflicting values.
  - **`/health`:** reports the release version.
  - **Relation example in the service's OpenAPI:** `has_instantiation`, a code from `/relation-types`; the old `hasInstantiation` was not a code and would have created a generic association.
- **2026-10-15, service v0.17.12** - Re-checked against the live service, closing these rows of the April 2026 migration list:
  - **Service description:** reports its own release tag and `spec_version: "0.46.0"`, and declares six normative profiles plus the `sparql-access` draft.
  - **OpenAPI tags:** Repositories reads "ISDIAH repository surface - canonical: rico:CorporateBody with rico:hasOrHadHolder relations", Functions reads "interim canonical: openricx:Function", and Graph says SPARQL is offered only under the optional `sparql-access` draft.
  - **Activity `@type`:** single activities and the list are `rico:Activity` with `rico:hasActivityType`; `/activities/910375`, for example, carries `.../vocab/activity-type/production`.
  - **JSON-LD `@context`:** binds `openricx:` to `https://openric.org/ns/ext/v1#` and `openric:` to `https://openric.org/ns/v1#`.
  - **Pre-1.1 names in entity responses:** a scan of a record, agent, repository and activity, the lists of activities, records, instantiations, functions, rules and places, a subgraph and a record export found none of `rico:heldBy`, `rico:hasSubject`, `rico:hasLanguage`, `rico:hasMandate`, `rico:hasRecordPart`, `rico:isContainedIn`, `rico:Production` or `rico:Accumulation`. The relation list is still open, above.
- **2026-10-15, viewer** - Types are read by local name, so `rico:Person`, a full IRI and a bare `Person` resolve alike (`localName` in `src/colours.js`), and activities are coloured by `rico:hasActivityType` (`getEffectiveType`). The viewer reads the subgraph as plain JSON and does not process a JSON-LD context, so it needs no `openricx:` declaration.
- **2026-10-15, capture** - The Activity form has one type with an activity-type dropdown (taxonomy `ric_activity_type`) instead of choosing `@type`. The Repository tile calls it a convenience surface, canonically a `rico:CorporateBody` with holder relations, and the Function tile says `openricx:Function`. Capture posts native fields, not RiC-O keys.
- **2026-10-15, conformance probe** - `--profile=<id>` covers every profile, and the SPARQL checks are optional, so a server without `sparql-access` is not failed for a missing `/sparql`.
- **2026-10-15, phase numbering** - The site used two phase systems, an internal "Phases 1-7" by feature area and a public "Phases 1-12+" roadmap. Both are replaced by the programme plan: Part I, the Standard, ending at the Standard Acceptance Gate, and Part II, OpenRiC Workspace. The developer page's Phase 1 to 12 roadmap, with its historical version pills, is replaced by a short "Where things stand" summary.
- **2026-05-25, v0.38.1** - **RiC-CM navigator reconciliation: declared.** Resolved via option (c) - articulate the distinction rather than deprecate. OpenRiC's `/reference/ric-cm/` is a **versioned, SPARQL-backed, declared-vs-inherited specification browser** tied to spec releases; the Damigos / Ionian [RiC-CM Nav](https://dlib-ionian-university.github.io/ric-cm-nav/) is a **standalone single-page graph navigator** aimed at conceptual exploration. The two address different reader needs (spec-version reference vs. conceptual graph traversal) and the relationship is now declared as **complementary, not competing** on [related-implementations](related-implementations.html). No deprecation; no fork. Either tool can cite the other.
- **2026-05-25, v0.38.1** - **RiC-AG (Application Guidelines) promoted to first-class related-implementation.** EGAD published RiC-AG v0.1 in October 2025; this spec now cross-references RiC-AG's ISAD(G)/ISAAR(CPF)/ISDF/ISDIAH crosswalks as the authoritative reference in [mapping.md §1.2](spec/mapping.html), and RiC-AG has its own section on [related-implementations](related-implementations.html). The forthcoming EAC-CPF → RiC-O 1.1 mapping (also announced under RiC-AG) is tracked separately in this drift log.
- **2026-04-25, v0.37.0** - RiC-O 1.1 namespace remediation, all 5 phases (A → E). Audit: 110 → 0 genuine emit-context violations.
- **2026-04-25, v0.37.0** - Per-document version headers (mapping/viewing-api/graph-primitives/conformance) bumped from `0.1.0-draft` to `0.37.0`.
- **2026-04-25, v0.37.0** - Mapping spec stale "review in progress" callout replaced with "REMEDIATION COMPLETE" callout.
- **2026-04-25, v0.37.0** - Audit doc opened with prominent STATUS banner.
- **2026-04-25, v0.37.0** - README current-version banner updated to v0.37.0.
- **2026-04-25, v0.37.0** - `drift-log.md` (this page) created.

---

## How to file a new drift item

Open a [discussion on openric/spec](https://github.com/openric/spec/discussions) with the label `drift`, or open a PR adding a row to this page. Format:

```md
| Surface | Currently observed | Target spec § | ETA / blocker |
|---|---|---|---|
| <which surface> | <what it does today> | <which spec section it should match> | <when, or what blocks it> |
```

OpenRiC's commitment: every open drift item is named, located, and either has an ETA or has a blocker explanation.
