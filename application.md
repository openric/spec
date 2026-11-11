---
layout: default
title: OpenRiC Workspace - in development
description: OpenRiC Workspace is an archival management application in development, built on Records in Contexts. What it does today, what it will not be, and what still stands between it and its first release.
permalink: /application/
kind: current
---

# OpenRiC Workspace

<p class="callout"><strong>Status: in development, not yet released for use.</strong> Development releases run at <a href="https://workspace.openric.org/discover">workspace.openric.org</a>, whose public catalogue anyone can browse without signing in, and the code is public. The first release meant for archivists, V0.1, has not been reached. The migration route from Heratio is planned, not operational.</p>

<p><a href="{{ '/application/features/' | relative_url }}">Features</a>: what it does today, area by area. <a href="{{ '/application/decisions/' | relative_url }}">Decisions and assumptions</a>: what was decided, when and by whom, what is assumed until someone decides, and what the Workspace keeps that RiC-O has no term for.</p>

## Archival management, built around context

OpenRiC Workspace is an archival management application in development, built on the International Council on Archives' Records in Contexts (RiC) standard.

It is designed for archives setting up a new digital management environment. It will bring archival description, authority control, contextual relationships, digital objects and public discovery into one RiC-native workspace. For institutions using Heratio, a defined migration route will support moving compatible archival information into the standalone Workspace.

## Three things called OpenRiC, kept apart

| Name | What it is | Where it lives |
|---|---|---|
| **The OpenRiC specification** | An implementation-neutral contract for publishing and exchanging RiC data over HTTP. Anyone can implement it. | [Specification](/spec/), on this site |
| **OpenRiC Workspace** | One application that implements that contract: an archival system for archives starting fresh. | This page; running at [workspace.openric.org](https://workspace.openric.org/); code at [openric/workspace](https://github.com/openric/workspace) |
| **Developer tools** | The reference API, the browse demo, the viewer, the capture client and the conformance probe. Tools for implementers, not for day-to-day archival work. | [Developers](/for-developers.html) |

When this site says "OpenRiC" on its own, it means the specification. The Workspace's own choices of database, sign-in or workflow will never become requirements of the specification.

## Where it stands

Planning and development started on 17 March 2026, when the RiC work began in Heratio (its `ahg-ric` package, Heratio v0.20.0); the OpenRiC specification and reference service followed on 17 and 18 April 2026. The Workspace's own code began on 19 October 2026, when [ADR 0003](https://github.com/openric/workspace/blob/main/architecture/adr/0003-implementation-before-the-s-gate.md) moved it ahead of the Standard Acceptance Gate. By 11 November 2026, release v0.0.151, the Workspace had:

- **The data model.** Units of description, authority records, repositories, places, activities, functions and rules are RiC entities with persistent IRIs. Every relation is held through assertions that record who said it and on what evidence, and a hash-chained, signed audit log covers it all. A unit keeps the one parent it is arranged under, and may also be in other record sets, each membership a `rico:Proxy` with its own IRI and place in that set's order ([ADR 0019](https://github.com/openric/workspace/blob/main/architecture/adr/0019-several-parents-functions-and-provenance.md)).
- **Description and publication.** RiC-native forms, each field showing the RiC-O term it is kept or exported as. The ISAD(G), ISAAR(CPF), ISDIAH, DACS, RAD, Dublin Core and MODS layouts remain, labelled as compatibility views. A review and publish workflow per value and language; an activity is not published without a date, nor a production without a result and a participant. An agent's ISAAR(CPF) control area is published as its authority record, a record in its own right, of the documentary form Authority record and resulting from the activity of describing the agent.
- **Archival and records management.** Accessions, donor agreements, appraisal and provenance; workflows with service levels; rights, embargoes, retention schedules and disposal; a file plan tied to the institution's functions, e-mail captured as records, record declaration, vital records and compliance assessments; POPIA governance and security clearance; jurisdiction packs for South Africa's National Archives and heritage export permits, and for the National Archives of Zimbabwe and its Cyber and Data Protection Act.
- **Digital objects and preservation.** Files attached as instantiations, with checksums and derived copies, IIIF Presentation 3 manifests, Content Search and Authorization Flow. Files are kept in an OCFL 1.1 storage root that any OCFL tool can read, every action on them is a PREMIS event, formats are identified against PRONOM, and fixity is checked on a schedule. Information packages go out as BagIt bags, and transfers to Archivematica are followed to their AIP. 3D models are kept as files, with a viewing copy.
- **Operations.** Single sign-on through the institution's own identity provider, two-factor sign-in, the installation's health as a page and as Prometheus metrics, and notices to staff by mail and, where switched on, WhatsApp.
- **Public discovery.** A catalogue that needs no sign-in, full-text search with close matches and regular expressions, and the relationship graph around each entity, also given as a list for screen readers and keyboards. What the public may read is decided in the database, so the catalogue holds at 100,000 units of description; offline catalogues open with no server.
- **Exchange.** EAD 2002, EAD3, AtoM CSV, EAC-CPF and EAC-F, and RiC-O import and export in which every relation leaves and comes back, with a report of what an export does not carry.
- **Federation and publishing.** Workspaces search each other's published catalogues under trust levels, with signed answers, and never see each other's drafts. The published RiC-O is open to SPARQL and can be explored in Sparnatural without writing a query. Each institution runs its own public site of pages, articles and landing pages, with a Help Center of 73 guides.
- **AI, as proposals only.** Everything goes through the AHG AI gateway and stays off until an institution switches it on. OCR, names found in text and matched to authority records, summaries, condition read from pictures, translation into 21 languages, search by meaning and subject suggestions from Annif all arrive as proposals for review. Every call leaves a signed receipt in a chained log, so a machine-made statement can be traced to the call that made it and the person who accepted it; the catalogue's assistant answers from published records only, and an institution keeps a register of the AI it uses ([ADR 0025](https://github.com/openric/workspace/blob/main/architecture/adr/0025-ai-assistance.md)).
- **Hardening.** Every outside program under limits, accessibility checked against WCAG 2.2 AA on every release, a deploy that refuses a release unless all its checks passed on its exact commit and its tag is signed, experimental modules off until named, a capacity test at 100,000 units, an install from the git clone in one command or in Docker, and a backup whose restore proves itself by the audit chain, the object store and every file's digest, its drill passed on 9 November 2026. Two outside assessments in November 2026 found it ready for demonstrations and pilot preparation, not yet for an institution's authoritative records.
- **Research services.** Researcher registration and the reading room, reproductions, projects, funding and data management plans, DOIs at DataCite and ORCID sign-in, lectures and training.
- **OpenRiC.** A public read API declaring the Core Discovery, Export-Only, Portability, Governance, Authority & Context, Graph Traversal, Digital Object Linkage and Provenance & Event profiles, each tested against the pinned schemas and SHACL shapes. Where the Workspace departs from a profile, it says so in its [conformance notes](https://github.com/openric/workspace/blob/main/conformance/README.md), with the issues it has raised on openric/spec.

The [demonstration](https://workspace.openric.org/sign-in) shows its account on its sign-in page, with full administrator rights, and is put back each night to the afternoon's baseline. Its catalogue is tested on real archival data. It holds 550 authority records, more than 1,200 places and three finding aids (937 units of description) from the Archives nationales de France's open data, [Les référentiels des Archives nationales de France, version 2.0](https://github.com/ArchivesNationalesFR/Referentiels), loaded through the Workspace's own importers and credited on the catalogue's home page.

Still missing for V0.1 are an installation run by someone other than its developers, the acceptance walkthrough with archivists, and an accessibility review. The Workspace is from the same organisation as the specification, so it does not count as the independent implementation the specification still needs ([known issue K-6](/spec/known-issues.html)).

## What it covers

Archival work: accessioning and appraisal, arrangement and description, authority control, contextual relationships between records, people, activities, places and rules, ingest of digital objects, rights and access, publication, public discovery, and export in standard formats.

Preservation is an integration with a preservation system such as Archivematica, beside the Workspace's own OCFL storage and PREMIS events. Uploading a file and recording its checksum is not described as preservation.

Up to and including V1.0 it covers archives only. It is not a museum, library or gallery management system, nor a general digital asset manager, and Heratio serves those needs today. From V2.0 other collecting domains may be added on the same RiC model, one at a time and only where there is demand. Each needs its own published decision on how that domain maps to RiC-O, CIDOC CRM, Linked Art or BIBFRAME. None of that work changes what V0.1 to V1.0 deliver for archives.

## How it relates to Heratio

Heratio is an integrated platform for galleries, libraries, archives and museums, with RiC already built into it. OpenRiC Workspace is a separate, focused application for archives that do not need the rest of that. They differ in scope and purpose, not in which one does more. Where the Workspace reuses Heratio's code, it is the same author's work under the same licence, and the two never depend on each other at run time.

The Workspace will run without Heratio. It will not share Heratio's database or depend on its services. An archive moving from Heratio will export its data and import it into the Workspace, with a report that accounts for every record, relationship and access restriction, including anything that has no place in an archives-only system.

## What it will be judged by

The first release has one test. An archivist signs in, describes and arranges a collection, links the people and activities behind it, attaches a digital object, sends the description for review, publishes the approved version, finds it in both the catalogue and the relationship graph, exports it, and reads back who changed what and why. They do all of that without touching an API. The same test then runs again on data migrated from Heratio.

One more principle runs through all of it. The Workspace shows what it knows, what it infers and what it cannot establish. Every statement is kept as an assertion with its origin, so one made by a person, one transformed from another source and one suggested by software stay distinct, and a machine suggestion does not become an archival fact until someone has reviewed it.

## Follow the work

The [decisions and assumptions]({{ '/application/decisions/' | relative_url }}) behind the Workspace, and what it keeps that RiC-O has no term for, are listed on their own page; its [roadmap](https://github.com/openric/workspace/blob/main/ROADMAP.md) and [architecture decisions](https://github.com/openric/workspace/tree/main/architecture/adr) are in its repository. The [current status](/status/) page tracks the specification it implements, and the [known-issues log](/spec/known-issues.html) what still stands in the way. The project's code is in its [GitHub repositories](https://github.com/openric). Questions are welcome through [Ask a question](/ask/).
