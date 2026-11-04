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
| 3 Nov 2026 | The public catalogue will offer Sparnatural, as FranceArchives does, over a read-only SPARQL store of published RiC-O, configured from the Workspace's own SHACL shapes (phase 16). | Roadmap |

: Assumptions made while building the Workspace, open to review

## What the Workspace keeps that RiC-O has no term for

RiC-O describes records and their contexts. An archive also runs an office: it takes in accessions, signs agreements with donors, keeps a reading room, routes work, registers how it processes personal information. The Workspace does that work as Heratio and AtoM do it, so it keeps values that RiC-O has no term for. It says so rather than hide it: each such value is a term of one of the Workspace's own vocabularies, and the term's scope note begins "Not a RiC-O term" and says where it is kept and why. Every data form shows, field by field, the RiC-O term a value is kept or exported as, or that there is none (ADR 0006, option C).

As of v0.0.121, 1,592 terms in 308 of the Workspace's 370 vocabularies are of this kind:

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
