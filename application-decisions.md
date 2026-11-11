---
layout: default
title: Workspace decisions and assumptions
description: The development decisions behind OpenRiC Workspace, who took them and when, and the assumptions made while building it that are still open to review.
permalink: /application/decisions/
kind: current
---

# Workspace decisions and assumptions

OpenRiC Workspace is built in the open, and so are the choices behind it. This page lists them in two kinds. A **decision** was taken by Dr Johan Pieterse, who leads the project, and is recorded with its date. An **assumption** is a choice made while building, recorded where it was made, and still open to review: it holds until someone decides otherwise.

Each decision of design is written up in full as an architecture decision record (ADR) in the Workspace's repository; the [roadmap](https://github.com/openric/workspace/blob/main/ROADMAP.md) records the order of work. This page is the summary. Where the two differ, the repository is right and this page is out of date.

None of this binds the specification. The Workspace's choices of database, sign-in or workflow never become requirements of OpenRiC; where building the Workspace showed a gap in the specification, it was raised as an issue on [openric/spec](https://github.com/openric/spec/issues) instead.

## Architecture decisions

| ADR | Date | Decision |
|---|---|---|
| [0001](https://github.com/openric/workspace/blob/main/architecture/adr/0001-independent-canonical-store.md) | 19 Oct 2026 | An independent canonical store; RDF and search are projections of it |
| [0002](https://github.com/openric/workspace/blob/main/architecture/adr/0002-laravel-and-postgresql.md) | 19 Oct 2026 | Laravel on PHP 8.3, with PostgreSQL 16 as the canonical store |
| [0003](https://github.com/openric/workspace/blob/main/architecture/adr/0003-implementation-before-the-s-gate.md) | 19 Oct 2026 | Implementation starts before the Standard Acceptance Gate |
| [0004](https://github.com/openric/workspace/blob/main/architecture/adr/0004-tamper-evident-audit-log.md) | 19 Oct 2026 | A tamper-evident audit log, reusing Heratio's hash chain |
| [0005](https://github.com/openric/workspace/blob/main/architecture/adr/0005-roles-and-permissions.md) | 20 Oct 2026 | Roles and permissions after Heratio's access control; a denial wins |
| [0006](https://github.com/openric/workspace/blob/main/architecture/adr/0006-ric-native-entity-model.md) | 20 Oct 2026 | A RiC-native entity model: Heratio is the floor, RiC the measure |
| [0007](https://github.com/openric/workspace/blob/main/architecture/adr/0007-api-keys-and-proposals.md) | 26 Oct 2026 | API keys, and proposals that an archivist reviews |
| [0008](https://github.com/openric/workspace/blob/main/architecture/adr/0008-rights-and-community-labels.md) | 27 Oct 2026 | Rights and Local Contexts Labels as rules |
| [0009](https://github.com/openric/workspace/blob/main/architecture/adr/0009-full-text-search-on-postgresql.md) | 27 Oct 2026 | Full-text search on PostgreSQL |
| [0010](https://github.com/openric/workspace/blob/main/architecture/adr/0010-accessions-as-activities.md) | 29 Oct 2026 | Accessions as their own kind, exported as activities |
| [0011](https://github.com/openric/workspace/blob/main/architecture/adr/0011-workflows-and-tasks.md) | 30 Oct 2026 | Workflows and tasks as Heratio's, with teams as roles |
| [0012](https://github.com/openric/workspace/blob/main/architecture/adr/0012-eac-cpf-and-eac-f-exchange.md) | 30 Oct 2026 | EAC-CPF and EAC-F exchange, round trips by IRI |
| [0013](https://github.com/openric/workspace/blob/main/architecture/adr/0013-portability-and-governance-profiles.md) | 30 Oct 2026 | The Portability and Governance profiles: RiC-O import, deprecated IRIs, the dataset and the SHACL gate |
| [0014](https://github.com/openric/workspace/blob/main/architecture/adr/0014-iiif-presentation.md) | 30 Oct 2026 | IIIF Presentation 3 from the record |
| [0015](https://github.com/openric/workspace/blob/main/architecture/adr/0015-embargoes-retention-and-disposal.md) | 31 Oct 2026 | Embargoes on records and their files; retention and disposal |
| [0016](https://github.com/openric/workspace/blob/main/architecture/adr/0016-privacy-and-jurisdiction-packs.md) | 31 Oct 2026 | Privacy and jurisdiction packs, POPIA governance first |
| [0017](https://github.com/openric/workspace/blob/main/architecture/adr/0017-research-services.md) | 31 Oct 2026 | Research services: all of Heratio's `ahg-research` |
| [0018](https://github.com/openric/workspace/blob/main/architecture/adr/0018-ric-o-relations-rules-and-exchange.md) | 2 Nov 2026 | Every relation in RiC-O, rules and mandates, and exchange without silent loss |
| [0019](https://github.com/openric/workspace/blob/main/architecture/adr/0019-several-parents-functions-and-provenance.md) | 2 Nov 2026 | Several parents, functions, and the last V0.1 profiles |
| [0020](https://github.com/openric/workspace/blob/main/architecture/adr/0020-remaining-heratio-services.md) | 3 Nov 2026 | The remaining Heratio services, intake first |
| [0021](https://github.com/openric/workspace/blob/main/architecture/adr/0021-monitoring-and-operations.md) | 3 Nov 2026 | Monitoring and operations, single sign-on to follow |
| [0022](https://github.com/openric/workspace/blob/main/architecture/adr/0022-preservation.md) | 4 Nov 2026 | Preservation, PREMIS events first, OCFL as the one store |
| [0023](https://github.com/openric/workspace/blob/main/architecture/adr/0023-federation.md) | 4 Nov 2026 | Federation, signed search between catalogues, all of ahg-federation |
| [0024](https://github.com/openric/workspace/blob/main/architecture/adr/0024-public-site.md) | 4 Nov 2026 | Publishing and outreach, the institution's public site and its help |
| [0025](https://github.com/openric/workspace/blob/main/architecture/adr/0025-ai-assistance.md) | 5 Nov 2026 | AI assistance, through the gateway and only as proposals |

: Architecture decision records of OpenRiC Workspace

## Decisions on scope and order

| Date | Decision |
|---|---|
| 19 Oct 2026 | Build the Workspace before the Standard Acceptance Gate, against a pinned, released specification version; it never counts as the independent implementation OpenRiC v1.0 needs ([K-6](/spec/known-issues.html)). |
| 26 Oct 2026 | Bring parts of integration protocols and AI assistance with human review forward from V2.0, so the AHG Archives MCP can serve the Workspace. |
| 27 Oct 2026 | Park the Heratio migration check (phase 4) until a Heratio export carries a full sample. |
| 31 Oct 2026 | Take all of Heratio's research services, not the reading room alone (ADR 0017). |
| 31 Oct 2026 | Every data field shows the RiC term it is kept or exported as, or says that RiC-O has none (ADR 0006, option C). |
| 1 Nov 2026 | Release the research services as far as they were built, and spend the next phase on hardening and acceptance after two external reviews. |
| 1 Nov 2026 | The backup restore drill comes last, but V0.1 is not signed off without it. |
| 1 Nov 2026 | Authority records not yet published stay readable to any signed-in account of the institution (ADR 0005). |
| 1 Nov 2026 | Up to and including V1.0 the Workspace covers archives only; other collecting domains may follow from V2.0, one at a time and on demand. |
| 2 Nov 2026 | Implement the Authority & Context, Graph Traversal, Digital Object Linkage and Provenance & Event profiles (ADR 0018, ADR 0019). |
| 2 Nov 2026 | A unit of description may be in several record sets at once (ADR 0019). |
| 2 Nov 2026 | The ISAD(G), ISAAR(CPF) and ISDIAH screens stay, labelled as compatibility views beside the RiC-native ones. |
| 2 Nov 2026 | Raise seven gaps found while implementing as issues on the specification ([openric/spec #67 to #73](https://github.com/openric/spec/issues)). |
| 2 Nov 2026 | The V0.1 acceptance walkthrough is run with archivists by Dr Johan Pieterse himself. |
| 2 Nov 2026 | Records management (13c): file plan nodes are kept as Heratio keeps them, each optionally one of the institution's functions or activities, and a record is placed in one node explicitly (option 1A); business e-mail comes in as uploaded .eml and Outlook .msg files, with no mailbox password kept (option 2A) (ADR 0015). |
| 2 Nov 2026 | Security clearance (18c) is checked in the one read check beside embargoes and file screening, so every surface answers alike (option 1A, ADR 0016). |
| 2 Nov 2026 | The jurisdiction packs (18d, 18e): NARSSA transfers, the National Archives of Zimbabwe and Zimbabwe's Cyber and Data Protection Act now; of SAHRA's permits only the export permits of the National Heritage Resources Act s.32; NMMZ moves to phase 21 with the heritage objects it registers (option 2A, ADR 0016). |
| 2 Nov 2026 | Each jurisdiction pack is switched on or off in the institution's settings. |
| 2 Nov 2026 | The order of work after V0.1's profiles: the parked research services, records management, the jurisdiction packs, the remaining Heratio services; then monitoring, preservation connectors, federation and publishing; AI and the restore drill last. The offline catalogue and other GLAM domains stay parked. |
| 3 Nov 2026 | IIIF (14a revisited): the length of sound and video is read by ffprobe at upload, and IIIF is asked to license its presentation-validator schema ([IIIF/presentation-validator#222](https://github.com/IIIF/presentation-validator/issues/222)) before the tests use it (options 1A and 2A, ADR 0014). |
| 3 Nov 2026 | Sound and video get viewing copies as images do (an MP3 and its waveform, an H.264 MP4 and a frame), so the public, who receives no masters, can hear and see them (ADR 0014). |
| 3 Nov 2026 | Each title of a record, instantiation or rule is also published as its own `rico:Title`, as Richard Williamson of EGAD advised on the RiC users list; the missing "translation of" term is asked of the specification ([openric/spec#74](https://github.com/openric/spec/issues/74), ADR 0019). |
| 3 Nov 2026 | Historical and abbreviated forms of name, after Croatia's eArhiv, are kinds of other form of name (ADR 0006). |
| 3 Nov 2026 | Phase 22 (the remaining Heratio services): intake, description quality, interfaces and vendors, built 22a to 22d; C2PA and research data management move to phase 17; the marketplace is not carried; FTP drops and watched folders now, SharePoint intake with a pilot (options 1B and 2B, ADR 0020). |
| 3 Nov 2026 | Description quality (22b): version history of descriptions and authority records, written once per change and restored as a new version; duplicate descriptions merged with the merged IRI pointing to the one kept; the institution's own fields as rows, a dropdown drawing from one of its vocabularies; form templates of elements and own fields (ADR 0020). |
| 3 Nov 2026 | Interfaces (22c), on Dr Johan Pieterse's choices 1A and 2A: the API still never writes directly (ADR 0007); webhooks, OpenAPI 3.1, sitemaps, an Atom feed, METS export, read-only GraphQL and places within a box or radius as GeoJSON are added; caption tracks are WebVTT, with no HLS (ADR 0020). |
| 3 Nov 2026 | Vendors (22d): a vendor is an authority record with a vendor profile, as donors are; its services, and the work sent to it for a service with the records, their condition before and after, the history of every change and the documents filed (ADR 0020). |
| 3 Nov 2026 | Monitoring and operations (12a), on Dr Johan Pieterse's choices: fixity on a schedule with a ledger of every check and failures kept open; the installation's figures as a page and as Prometheus text; runbooks for updating and rotating keys. Single sign-on follows in 12b, an unknown sign-in waiting for approval (ADR 0021). |
| 3 Nov 2026 | Single sign-on and two-factor sign-in (12b): OpenID Connect providers per institution, an unknown sign-in becoming a request for an account an administrator approves (Dr Johan Pieterse's choice); TOTP two-factor sign-in under the institution's policy, a sign-in through the provider using its own second factor (ADR 0021). |
| 3 Nov 2026 | RiC-O 1.1's specific relations (12c): rico:directlyIncludes and rico:isDirectlyIncludedIn, rico:hasOrHadDigitalInstantiation and rico:hasOrHadAnalogueInstantiation with their inverses, and rico:directlyPrecedesInSequence between units, beside the broad ones; checked against the Archives nationales de France's RiC-O converter 3.0.0, every difference fixed or recorded as a choice; the extension ontology's close matches to BoDi (ontology 1.6.1). |
| 4 Nov 2026 | Rules and mandates in full (12d): a rule's status, history, the agent that issued it and the agent that enforces it, the record that carries its text, and the rules it amends or supersedes; retention schedules naming the rule they are issued under; extension ontology 1.7.0 with openricx:hasRuleStatus, amends and supersedes, as RiC-O 1.1 has none of them. |
| 4 Nov 2026 | Preservation (phase 15), on Dr Johan Pieterse's choices: OCFL to be the one object store, Archivematica built last against its API. 15a: every action on a file a PREMIS 3 event with the Library of Congress event type it matches, formats identified against PRONOM by Siegfried with their risk and action, and a unit's PREMIS 3.0 export (ADR 0022). |
| 4 Nov 2026 | OCFL as the one object store (15b): "this is not live data. so one store". Every file is kept in an OCFL 1.1 storage root laid out by the published extension 0004, each instantiation one object named by its IRI, each change a new version holding the whole object; a destruction purges the object, since OCFL otherwise keeps every version; the files kept before were moved in at release (ADR 0022). |
| 4 Nov 2026 | Preservation planning (15c): Heratio's normalisation rules make a preservation master and an access copy beside the master, never in its place, normalising on ingest only where an institution chooses; migration plans are approved by someone other than who drew them up; the object store is replicated to a folder or another server by rsync over SSH, and a target folder that is neither empty nor a storage root is refused; rights go into PREMIS as rights statements (ADR 0022). |
| 4 Nov 2026 | OAIS packages, SWORD and Archivematica (15d), ending phase 15: a unit as a SIP, AIP or DIP in a BagIt 1.0 bag with its METS and PREMIS, kept in OCFL and carried on from SIP to AIP to DIP; SWORD 1.3 deposit as AtoM answers it, so Archivematica can upload a DIP, signed in with an API key rather than a password so two-factor sign-in is not passed by; Archivematica built against its API, a unit sent as a transfer and followed to its AIP, its DIP fetched back. Archivematica's own processing configuration is not shipped, as it is not Heratio's to give (ADR 0022). |
| 4 Nov 2026 | Federation (phase 16), on Dr Johan Pieterse's choices: all of Heratio's ahg-federation in five parts, and Fuseki as the triple store for Sparnatural. 16a: each institution's peers searched at once, an institution on the same installation read as the public sees it, so none sees another's drafts; an institution shares only what it publishes and only when it chooses; every answer signed with Ed25519 in Heratio's scheme, so a Workspace and a Heratio verify each other, and a peer's key pinned on first use (ADR 0023). |
| 4 Nov 2026 | Harvest and the union catalogue (16b): records harvested from an OAI-PMH peer come in as drafts, in a repository of their own, and reach the public only when someone publishes them; the harvest changes only the units it made. Each member of a union gives only its own records, so two unions that list each other do not copy each other's copies. DSpace and Alma are searched by their own protocols, their answers marked unsigned (ADR 0023). |
| 4 Nov 2026 | Federation governance (16c): a peer's trust decides whether it is asked and whether its unsigned answers are kept; peers' protocols are probed each night; a peer's vocabulary is taken into the institution's own with the peer's IRI kept as an exact match, which is all a term mapping needs to be; peers pull a shared vocabulary's changes rather than being sent them; an archive asks to join and an administrator approves it into a peer (ADR 0023). |
| 4 Nov 2026 | Europeana and loans (16d): published records go to Europeana in EDM as the public reads them, their rights the IRI of the right in force; loans between union members move only along Heratio's transitions, with who moved them and why (ADR 0023). |
| 4 Nov 2026 | The graph and ResourceSync (16e): the published RiC-O is kept in a Fuseki dataset, one named graph for each published entity, and nothing else goes in, so no query finds a draft; the public SPARQL endpoint forwards queries and refuses updates; Sparnatural is configured from the OpenRiC shapes and the relation types, not by hand; ResourceSync follows Heratio's addresses and paging, with withdrawn entities announced as deleted. Phase 16 is done (ADR 0023). |
| 4 Nov 2026 | Publishing and outreach (phase 20), on Dr Johan Pieterse's choices: Heratio's user guides copied and adapted for the Help Center, DOIs against DataCite's test service and off until an institution gives its own account, and four releases, 20a to 20d. 20a: the institution's public site, its static pages, articles and landing pages. Only what is published reaches it: an article's files are served only while the article is published, and a landing page's figures count only what the public may read. Nothing typed into a page runs in a visitor's browser. Heratio's marketing pages, AHG's own sales pages, are not carried (ADR 0024). |
| 4 Nov 2026 | The Help Center (20b): once the size of Heratio's help library was known (494 articles), Dr Johan Pieterse chose to adapt the core guides now and to add each later phase's guides with it. 73 guides, each rewritten for the Workspace's screens and RiC terms and checked against its code, are kept as Markdown with the code and read in again whenever they change; help for the screen in hand comes from the routes each guide names (ADR 0024). |
| 4 Nov 2026 | DOIs (20c): a published unit of description is given a DOI at DataCite with the institution's own account, test first, resolving to its persistent IRI, its metadata made from what the public reads; a unit must be published to be minted, since a DOI publishes it; the DOI becomes one of its identifiers, so it is in its RiC-O and its citations; usage is reported to DataCite only where the institution switches it on (ADR 0024). |
| 4 Nov 2026 | Lists, display and the code reference (20d): the last lists kept as text, the publish gate outcomes and print page sizes and orientations, became vocabularies, and validation reads each vocabulary rather than a copy of its codes; an institution words, orders and defaults any bundled list for itself in the Dropdown manager, and adds and hides terms in the open ones, while every term keeps its IRI and RiC-O mapping; a list is open only where no code relies on its terms, which a test checks; display profiles by level of description choose what the public page shows; staff browse as the institution or the account sets; the code reference is read from the code (ADR 0024). |
| 5 Nov 2026 | AI assistance begins (17a): every model is reached through the AHG AI gateway only, and AI stays off until the installation has a key and the institution switches it on; what a model says is only ever a proposal for review; every call is a receipt in a chained, signed, append-only log of inferences, so each machine output can be traced to its proposal and its reviewer; printed pages are read by a vision model checked against Tesseract; a relation a model asserted is exported as generated by it, and one no model asserted is, by that absence, documented fact (ADR 0025). |
| 5 Nov 2026 | Names, summaries and condition from AI (17b1): names found by spaCy through the gateway in a description and the transcripts of its pages are proposed as access points and dates with the passage they came from, and a confidence only where the model gives one; a summary of the pages is proposed as scope and content; a vision model's reading of an object's condition is proposed as its physical characteristics, graded from the condition-grade vocabulary, and says it is not a trained condition model, which the gateway is asked for (ADR 0025). |
| 5 Nov 2026 | Resolving names (17b2): every proposed person, organisation or place, found by a model or sent through the API, is resolved to the institution's own authority records and places with candidates ranked by name and by evidence read from the RiC description (dates, places, relations, words of role, broader places, the fonds' places), and every decision is kept as the archivist saw it; a name a model found keeps the model's assertion on the relation, reviewed by the person who accepted it; new records may be filled from VIAF, Wikidata and GeoNames, each field with its source and licence; outside authorities are off until an institution switches them on (ADR 0025). |
| 5 Nov 2026 | Translation (17c): a description's elements are translated by machine through the gateway into one of 21 languages, each translation a proposal reviewed beside the original and never overwriting one; each institution may word the interface its own way, proposed by translators and accepted by administrators, for its staff and its public catalogue alone (ADR 0025). |
| 5 Nov 2026 | Search by meaning (17d1): every entry of the search index is also a vector, kept with pgvector in the same database so it obeys the same access rules, and a search runs by the words, by meaning or both; a search is widened by the institution's own vocabularies; reranking by an account's recent searches keeps only its last 25, and only while the institution has it on, so the search statistics still name no one (ADR 0025). |
| 5 Nov 2026 | Repatriation (17d2): a repatriation claim is a documented request on one of the institution's descriptions and never a legal determination; its claimant may read and write in the dialogue through a link whose token is kept only as a hash; the public register, each claim's virtual return and lodging a claim are off until the institution chooses them, and lodging is open for any published description, not only those a register traces (ADR 0025). |
| 5 Nov 2026 | Heritage at risk and displaced heritage (17d3): a description is flagged for capture by whoever may change it; the register answers federation peers signed, at the Workspace's address and at Heratio's, and a peer's pushed flag waits for a curator; the displaced-heritage register reads origin from the provenance chain and holding from the repository until museum fields arrive, and flags nothing it cannot place on both sides (ADR 0025). |
| 5 Nov 2026 | Staff notices on WhatsApp: a staff member may have the notices the Workspace mails them on WhatsApp too, as one Meta-approved template naming the institution, the subject and a link; the Workspace holds no WhatsApp credential and hands each notice to the estate's sender; researchers and the public are never sent anything there. |
| 6 Nov 2026 | Languages, discoveries and research leads (17d4): the languages of a collection are read from its own language-tagged names, labels and page transcripts, and what people contribute appears once reviewed; a model looking for connections is shown only the public relationship graph around a published record, and its discoveries stay with staff until a curator publishes one as a research lead (ADR 0025). |
| 6 Nov 2026 | Subjects suggested by Annif (17e): Annif runs behind the AI gateway only; each subject it suggests is a proposal of a concept of the institution's chosen vocabulary, accepted as the record's subject with the model's assertion, and its precision is tried on published records before it is relied on (ADR 0025). |
| 6 Nov 2026 | An authority record is a record too: after Richard Williamson's answer on the Records in Contexts users list, an agent's ISAAR(CPF) control area is published as a `rico:Record` of the documentary form Authority record, resulting from the activity of describing the agent, beside the network of entities the agent already is; and the dataset description and federation protocol say which extension the data uses, so a consumer reading only RiC-O 1.1 knows what it misses (ADR 0019). |
| 7 Nov 2026 | After an outside assessment of production readiness (ready for demonstrations, not for an institution's records; the gap is verification, not modules), the remaining modules and the hardening it asks for are interleaved: outside programs under limits, accessibility checked on every release, a capacity test, then the packs for an outside installer, archivist and security tester. |
| 7 Nov 2026 | Offline catalogues (11c) are built after all, and of the other collecting domains (phase 21) only 3D objects, as a kind of file. |
| 8 Nov 2026 | After a second outside audit: a release is deployed only when every one of its CI jobs passed on its exact commit and its tag's signature verifies, with the evidence kept; experimental modules are off until an installation names them (`MODULES.md`); RiC-CM 1.0.1 and RiC-O 1.1 are the normative model, and ISAD(G), ISAAR(CPF), ISDIAH, ISDF, EAD and EAC-CPF adapters and compatibility views only. |
| 9 Nov 2026 | The other collecting domains of phase 21 (library, museum, gallery, digital assets, exhibitions, loans, heritage assets) are parked, kept for later and out of scope until then. |
| 9 Nov 2026 | The working surface (phase 25), after docuteam context's: close-match and regular-expression search first, measured at 100,000 units; then drag and drop in the tree, with a keyboard Move beside it; then a grid over descriptions with Heratio's bulk edits, each row saved through the same checks as a form. |
| 9 Nov 2026 | Capacity is tested on 100,000 units of description, 10,000 authority records and 2,000 places, made through the application's own services and kept for each later run. When the test found the public catalogue deciding what the public may read record by record, that moved into SQL, held by a test to the same answer for every rule. |
| 9 Nov 2026 | The interface's translations come from PSIS and Heratio, Heratio's being the source, refreshed by a tool the release runs; a string translated by machine is listed as unreviewed until a person has read it. |
| 9 Nov 2026 | Backup and restore, deferred until a pilot held real records, is brought forward with the installs: the Workspace from its git clone in one command, and in Docker, with a backup and a restore that proves itself by the audit chain, the object store and every file's digest. |
| 9 Nov 2026 | A public demonstration shows its account on the sign-in page, with full administrator rights, as Heratio's demo does, and uses Heratio's demonstration sign-in. |
| 10 Nov 2026 | The demonstration takes its baseline every afternoon at 16:00, so what is made during the working day, video recordings among it, is kept; at 02:00 the baseline is put back, undoing whatever visitors changed since. |
| 11 Nov 2026 | AI is on for the public demonstration, under a limit of 500 calls a month, with the catalogue's assistant offered to visitors; every model is still reached through the AHG AI gateway, and what a model says is still only a proposal. |
| 11 Nov 2026 | The text of a page goes where its reference copy goes: an embargo that withholds a record's files withholds its transcript too, from the API, the language pages and the catalogue's assistant. |

: Decisions on the Workspace's scope and the order of its work

## Assumptions open to review

These were chosen while building, because a choice had to be made and nobody had yet made it. Each is recorded where it was made, and each can be changed.

| Made | Assumption | Recorded in |
|---|---|---|
| 1 Nov 2026 | A RiC bridge from a research project to the catalogue is a deliberate act, for public projects only, by someone who may create authority records; Heratio does it for every project automatically. | ADR 0017 |
| 1 Nov 2026 | The contradiction engine's shared-source rule is fixed; Heratio's mismatch between "opposes" and "refutes" had disabled it. | ADR 0017 |
| 1 Nov 2026 | IIIF canvases for sound or video without a known duration are left out of a manifest, and the tests check manifests without the IIIF schema, which carries no licence. | ADR 0014 |
| 2 Nov 2026 | A reference to another entity carries that entity's names, language-tagged as in its own description, so a merged graph holds one title per entity. | ADR 0019 |
| 2 Nov 2026 | Activities published before v0.0.98 without a date stay published; the date is asked for the next time one is published. | ADR 0019 |
| 2 Nov 2026 | A DOI is registered only for a public project, since registering publishes it; it resolves to a landing page in the Workspace, not to a share link. | ADR 0017 |
| 2 Nov 2026 | A replication pack states no licence: that is the researcher's to choose. | ADR 0017 |
| 2 Nov 2026 | Published lectures and training courses are open to every signed-in account of the institution, including one with no role. | ADR 0017 |
| 2 Nov 2026 | Rights policies for researchers guard a record's files in the public catalogue, not its page, and never bind who may change the record. | ADR 0017 |
| 2 Nov 2026 | Heratio's offline sync waits for the offline catalogue, which is parked. | ADR 0017 |
| 2 Nov 2026 | A record placed in a file plan node that is a function or activity is exported as documenting it (`rico:documents`), not as resulting from it, since the Workspace keeps "results from" for what a production activity makes. | ADR 0015 |
| 2 Nov 2026 | Outlook .msg files are read by the Workspace's own reader of the compound file format, since the library for them needs a PHP extension the host lacks; the library is the upgrade path. | ADR 0015 |
| 2 Nov 2026 | A declared record, and its instantiations, cannot be deleted except by its disposal once cleared; Heratio's declaration was a status only. | ADR 0015 |
| 2 Nov 2026 | The Workspace keeps no legal holds; the DoD 5015.2 check for them says so rather than passing. | ADR 0015 |
| 2 Nov 2026 | The public never reads a classified record, whatever its publication status; a level that forbids downloads keeps master files back from a cleared reader too. | ADR 0016 |
| 2 Nov 2026 | A National Archives of Zimbabwe closure or protection is kept as an embargo on the record, so the existing read check enforces it. | ADR 0016 |
| 2 Nov 2026 | The Cyber and Data Protection Act is a jurisdiction of the one set of privacy registers, not a second set as in Heratio. | ADR 0016 |
| 2 Nov 2026 | A jurisdiction pack switched off keeps what it holds; its pages answer as if absent. | ADR 0016 |
| 2 Nov 2026 | An export permit is approved within the institution by someone other than the applicant who may change every record it covers, as PSIS's supervisor endorsement. | ADR 0016 |
| 3 Nov 2026 | A sound or video canvas takes the master file's length where it is known, since an MP3 copy's own length is padded. | ADR 0014 |
| 3 Nov 2026 | Until a "translation of" term exists, the order of a record's titles (the original first) is the only sign of which is the original. | ADR 0019 |
| 3 Nov 2026 | A file in AtoM's columns goes straight to its dry run; only a file with none of the columns its reader needs is mapped first. | ADR 0020 |
| 3 Nov 2026 | Undoing an import deletes what it created and nothing anyone changed since; what it only updated is not put back. | ADR 0020 |
| 3 Nov 2026 | Every watched folder lies under one intake root the server's administrator sets; an FTP or SFTP account kept to a watched folder replaces Heratio's FTP upload. | ADR 0020 |
| 3 Nov 2026 | Restoring a version puts back values, names and own fields; dates, identifiers and relations are shown but not restored, as in Heratio. | ADR 0020 |
| 3 Nov 2026 | Merging duplicate descriptions gives the unit kept its own instantiation of each of the other's, from the same file, since an instantiation stays with the unit it instantiates. | ADR 0020 |
| 3 Nov 2026 | An institution's own fields have no RiC-O term: they are exported in the CSV and listed as not carried by an RDF export. | ADR 0020 |
| 3 Nov 2026 | A webhook says what happened to which entity, by its IRI and API address, never what the entity says; the receiver reads that through the API with its own key, so clearance and embargoes hold. It posts only to public addresses. | ADR 0020 |
| 3 Nov 2026 | GraphQL and the GeoJSON place search read the same public catalogue as the rest of the API; GraphQL refuses mutations. | ADR 0020 |
| 3 Nov 2026 | A caption track reaches only who may receive the recording it goes with, and the player plays the viewing copy, so the public hear and see recordings too. | ADR 0020 |
| 3 Nov 2026 | Records leave for a vendor only once the work is approved, insured and valued where its service asks it, and never while out with another vendor. A vendor's bank details are encrypted and kept out of the audit log. | ADR 0020 |
| 3 Nov 2026 | Subjects will be suggested by Annif (National Library of Finland, Apache 2.0), trained on the institution's own indexed descriptions against its SKOS vocabularies, behind the AI gateway, each suggestion a proposed access point for review (phase 17). | Roadmap |
| 3 Nov 2026 | The RiC-O export will give RiC-O 1.1's specific relations (rico:directlyIncludes, rico:hasOrHadDigitalInstantiation, rico:hasOrHadAnalogueInstantiation) beside the broad ones, and be checked against the Archives nationales de France's RiC-O converter on the same EAD and EAC-CPF files (step 12c). | Roadmap |
| 9 Nov 2026 | The demonstration's public account cannot be changed, disabled or deleted, nor set up for two-factor sign-in, by anyone, so no visitor can take it from the next; a change a visitor makes before 16:00 becomes part of the next baseline. | `deploy/runbooks/restoring.md` |
| 9 Nov 2026 | A backup holds `.env` and the audit signing key beside the database and files, so a restore needs nothing else; it is kept where those may be kept. A restore refuses a backup of a newer release, and migrates one of an older release up. | `deploy/runbooks/restoring.md` |
| 9 Nov 2026 | The Docker install carries no virus scanner: uploads are kept as not scanned until ClamAV is run beside it; `bin/install` on a server installs it. | `docker/README.md` |
| 3 Nov 2026 | The public catalogue will offer Sparnatural, as FranceArchives does, over a read-only SPARQL store of published RiC-O, configured from the Workspace's own SHACL shapes (phase 16). | Roadmap |

: Assumptions made while building the Workspace, open to review

## What the Workspace keeps that RiC-O has no term for

RiC-O describes records and their contexts. An archive also runs an office: it takes in accessions, signs agreements with donors, keeps a reading room, routes work, registers how it processes personal information. The Workspace does that work as Heratio and AtoM do it, so it keeps values that RiC-O has no term for. It says so rather than hide it: each such value is a term of one of the Workspace's own vocabularies, and the term's scope note begins "Not a RiC-O term" and says where it is kept and why. Every data form shows, field by field, the RiC-O term a value is kept or exported as, or that there is none (ADR 0006, option C).

As of v0.0.152, 1,833 terms in 355 of the Workspace's 417 vocabularies are of this kind:

| Area | Vocabularies | Terms | Why it is there |
|---|---|---|---|
| Research services | 114 | 579 | A researcher's own working data (projects, funding, plans, studios), not catalogue description; kept as Heratio's `ahg-research` keeps it (ADR 0017) |
| Accessions | 24 | 134 | The intake, appraisal, valuation, containers and rights of an accession, as AtoM, PSIS and Heratio keep them; some are given in the CAAIS export (ADR 0010) |
| Privacy (POPIA) | 19 | 93 | Information Officers, the processing register and screening, as Heratio's `ahg-privacy` keeps them (ADR 0016) |
| Reading room | 18 | 92 | Registration, rooms, seats, bookings and retrieval, as Heratio keeps them (ADR 0017) |
| Donor agreements | 10 | 89 | The agreement's rights, restrictions and documents, as Heratio keeps them; the agreement itself is a `rico:Record` (ADR 0010) |
| Provenance and custody | 9 | 73 | The overview and steps of a record's provenance; each step is exported as a `rico:Activity`, its working values are not |
| Workflow | 11 | 71 | Workflows, tasks and service levels, as Heratio and PSIS keep them (ADR 0011) |
| Retention and disposal | 5 | 23 | Schedules, classes and disposal actions, as Heratio's `ahg-records-manage` keeps them (ADR 0015) |
| Records management | 11 | 38 | The file plan, its imports, captured e-mail, classification rules, declaration and compliance frameworks, as Heratio's `ahg-records-manage` keeps them (ADR 0015) |
| Jurisdiction packs | 14 | 69 | NARSSA transfers, export permits, the National Archives of Zimbabwe and the CDPA's licences, as Heratio's `ahg-narssa`, `ahg-naz` and `ahg-cdpa` and PSIS's SAHRA plugin keep them; which packs an institution uses (ADR 0016) |
| Description quality | 3 | 17 | Duplicate rules and their statuses, and the kinds of value of an institution's own fields, as Heratio's `ahg-dedupe` and `ahg-custom-fields` keep them (ADR 0020) |
| Preservation | 20 | 80 | PREMIS event types, outcomes and agent types matched to the Library of Congress preservation vocabulary; file formats' risk and action; normalisation purposes, conversion tools and statuses; migration plan statuses and quality impacts; replication target types, operations and statuses; OAIS package types, statuses, formats and file roles; Archivematica job statuses, directions and link statuses, as Heratio's ahg-preservation and ahg-archivematica keep them (ADR 0022) |
| Federation | 12 | 49 | Federation peer types, how a peer answered, and whether its answer was verified; how a harvest ended and what it did with each record; trust levels, discovery statuses, vocabulary sync directions, conflict rules and change types, join request statuses, and loan statuses, as Heratio's ahg-federation keeps them (ADR 0023) |
| Rules | 1 | 4 | Whether a rule is in force: draft, in force, in force and amended, repealed (openricx:hasRuleStatus; ADR 0018) |
| Sign-in | 2 | 6 | How a single sign-on finds its account, and who must sign in with a second factor, as AtoM's arOidcPlugin and Heratio's ahg-security-clearance keep them (ADR 0021) |
| Fixity | 6 | 21 | How often a schedule runs and what it covers, how a run ended and what started it, what a check found and where a failure stands, as Heratio's `ahg-integrity` keeps them (ADR 0021) |
| Vendors | 7 | 51 | Vendor types and statuses, service types, transaction and payment statuses, condition grades and kinds of document, as Heratio's `ahg-vendor` keeps them (ADR 0020) |
| Interfaces | 2 | 9 | Webhook events and delivery statuses, as Heratio's `ahg-api` keeps them (ADR 0020) |
| Public site | 4 | 35 | Whether an article is published, the kinds of file attached to it, whether a comment is shown, and the kinds of block a landing page is built of, as Heratio's `ahg-articles` and `ahg-landing-page` keep them (ADR 0024) |
| DOIs | 6 | 52 | What is asked of DataCite and where it stands, DataCite's resource types, funder identifier schemes, and usage events, as Heratio's `ahg-doi-manage` keeps them (ADR 0024) |
| Lists and display | 8 | 29 | What a publish gate found, print page sizes and orientations, the actions and picture sizes of a display profile, and how the browse list is shown and sorted, as Heratio's `ahg-workflow`, `ahg-research` and `ahg-display` keep them (ADR 0024) |
| AI | 8 | 31 | What a model was asked to do through the AI gateway, kept with each call in the log of inferences; the register of the AI an institution uses, its risk classes, uses and life cycle; and the review of the catalogue assistant's answers, as Heratio's `ahg-provenance-ai`, `ahg-ai-compliance` and `ahg-ai-chatbot` keep them (ADR 0025) |
| Heritage at risk | 6 | 27 | Risks, urgency, the kinds of hotspot and where a capture or a flag from a peer stands, as Heratio's heritage at risk keeps them (ADR 0025) |
| Repatriation | 5 | 20 | A claim's status, its parties, the kinds and standing of community knowledge, and who sees a message, as Heratio keeps them; a claim is a documented request, never a legal determination (ADR 0025) |
| Languages and research leads | 3 | 10 | What a community contributed about a language and where it stands, and where a research lead stands (ADR 0025) |
| Offline catalogues | 1 | 3 | What an offline catalogue holds: everything, a repository, a unit with what is inside it, or the clipboard |
| 3D objects | 1 | 2 | How a 3D model is placed in augmented reality |
| Resolving names | 4 | 22 | Where the review of a mentioned name stands, what was decided, the outside authorities a new record is filled from with their licences, and the kinds of words of role, as Heratio's `ahg-authority-resolution` keeps them (ADR 0025) |
| Intake and labels | 4 | 12 | What became of a file a watched folder or the scan API took in, and how labels are printed, as Heratio's `ahg-scan` and `ahg-label` keep them (ADR 0020) |
| Security clearance | 4 | 14 | Clearance history and requests for access above one's clearance, as Heratio's `ahg-security-clearance` keeps them (ADR 0016) |
| IIIF | 4 | 19 | IIIF Presentation 3 behaviours and resource types, and the checks of a manifest (ADR 0014) |
| Embargoes | 2 | 13 | The types and reasons of an embargo, as Heratio's `ahg-extended-rights` keeps them (ADR 0015) |
| Community protocols | 1 | 10 | A community's protocol on a description, kept and not exported (ADR 0008) |
| Research rights policies | 2 | 9 | ODRL 2.2 rule types and actions (ADR 0017) |
| Agent handling conditions | 1 | 7 | How an agent's description is to be handled, as Heratio keeps it; not exported |
| Display layouts | 1 | 5 | Which compatibility view shows a description; not exported (ADR 0019) |
| Reports | 1 | 5 | The institution's reports, as Heratio's `ahg-reports` keeps them |

: Terms the Workspace keeps that RiC-O has no term for, by area

Every vocabulary, with its scope notes, is in the Workspace's repository under [resources/vocabularies](https://github.com/openric/workspace/tree/main/resources/vocabularies), and each resolves at its own address, such as [workspace.openric.org/vocab/permission](https://workspace.openric.org/vocab/permission). Where a gap seemed to belong in RiC-O or OpenRiC rather than in the Workspace, it was raised as an issue instead of kept quietly: on [openric/spec](https://github.com/openric/spec/issues) for the specification, and, through it, for RiC-O itself.

To question a decision or an assumption, open an issue on [openric/workspace](https://github.com/openric/workspace/issues), or use [Ask a question](/ask/).
