---
layout: default
title: Workspace features
description: What OpenRiC Workspace does today, area by area, as released up to v0.0.109. In development; not yet released for use.
permalink: /application/features/
kind: current
---

# Workspace features

<p class="callout"><strong>In development, not yet released for use.</strong> This page lists what OpenRiC Workspace does in its development releases, up to v0.0.109 of 3 November 2026, which run at <a href="https://workspace.openric.org/discover">workspace.openric.org</a>. It lists only what is built and released; what is still to come is in the <a href="https://github.com/openric/workspace/blob/main/ROADMAP.md">roadmap</a>, and why each part works as it does is under <a href="{{ '/application/decisions/' | relative_url }}">decisions and assumptions</a>.</p>

Much of the Workspace copies what Heratio and AtoM-based systems already do, field for field, and rebuilds it on the RiC model. Where it departs from them, the decisions page says so.

## The data model

- Units of description, authority records (people, families and corporate bodies), repositories, places, activities, functions and rules are RiC entities, each with a persistent IRI that resolves.
- Every relation is held through assertions that record who said it, on what evidence, with what certainty, and whether it is accepted, proposed or disputed. Relation types are data, each with its RiC-O class, property and inverse.
- A unit has one parent, where it is arranged, and may also be in other record sets, each membership a `rico:Proxy` with its own order.
- Dates, names, identifiers and places are entities of their own, with their dates of use; a name may be an authorised, parallel, standardised, other, historical or abbreviated form, and every title is published as its own `rico:Title`.
- Vocabularies are the institution's own SKOS schemes, never fixed lists in code, and every field shows the RiC-O term it is kept or exported as, or that RiC-O has none.
- A hash-chained, signed audit log covers every change, and its chain can be verified; descriptions and authority records keep a version history that can be compared and restored.
- Duplicate authority records and places can be merged; the merged IRI leads to the one kept, and a deleted entity answers that it is gone, with its successor.

## Description and publication

- RiC-native forms, with ISAD(G), ISAAR(CPF), ISDIAH, DACS, RAD, Dublin Core and MODS layouts kept as labelled compatibility views.
- A hierarchy tree beside every unit, inventories, finding aids and print views.
- Review and publication per value and per language, publish gates, and publish readiness.
- The institution's own fields on its entities, and form templates that show only the fields a kind of work needs.
- Duplicate descriptions found by rules, compared and merged.
- An interface in English and Afrikaans; an institution offers any language that has a translation file.

## Archival management

- Accessions after the CAAIS profile: intake, checklists, appraisal, valuation, containers, rights and deaccessions, each accession exported as an activity with its donor taking part.
- Donor agreements with their rights, restrictions, reminders and documents.
- Provenance and custody history, each step an activity affecting the record.
- Workflows and tasks: steps, claiming from the pool, assignment, teams by role, queues, service levels with warnings and escalation, and bulk operations.
- Rights: RightsStatements.org, Creative Commons, copyright status, PREMIS grants, and Local Contexts Traditional Knowledge and Biocultural Labels, shown in the catalogue and carried in every export.
- Embargoes on records and their files, with exceptions, warnings before they end and review dates.
- Retention schedules and disposal classes, reviews, a disposal workflow with separation of duties, and destruction that keeps the description as evidence and issues a certificate that verifies.
- Records management: a file plan whose nodes may be the institution's functions and activities, each record placed in one; file plans imported from spreadsheets, folder listings and EAD; e-mail captured from .eml and Outlook .msg files and declared as records; classification rules; record declaration that keeps a declared record from deletion outside its disposal; vital records; compliance assessments against ISO 15489, ISO 16175, MoReq2010, DoD 5015.2, ISO 30300 and ISO 23081.
- POPIA governance: Information Officers, the processing register, impact assessments, consent, data subject and PAIA requests, complaints and security compromises; scanning records for personal information, redaction for the public, and screening before files are released.
- Security clearance: levels, compartments and clearances; records classified, the classification holding for what is inside them, reviewed and declassified on their dates; access above one's clearance asked for and granted for hours; checked wherever a record or its files are read.
- Jurisdiction packs, each switched on in the settings: transfers to the National Archives and Records Service of South Africa packaged with EAD3, master files and METS; export permits under the National Heritage Resources Act s.32; the National Archives of Zimbabwe's closures, protected records, research permits, records schedules and transfers; Zimbabwe's Cyber and Data Protection Act in the privacy registers, with data controller licences.

## Digital objects

- Files attached as instantiations, with checksums, derived copies, fixity checks, extracted text, embedded metadata, alternative text and watermarks.
- Viewers for images, PDF, sound, video and 3D models; sound and video get viewing copies the public can play, and their length is read at upload; WebVTT caption tracks play with them and appear in the IIIF manifest.
- IIIF Presentation 3 manifests and collections, curated collections, Change Discovery, Content State, Content Search over transcripts, and the Authorization Flow for files available on request.

## Discovery and search

- A public catalogue that needs no sign-in, with full-text search and facets, pages for every kind of entity, and the relationship graph around each in 2D or 3D, also given as a list for screen readers and keyboards.
- Staff search with saved searches and statistics.
- Usage statistics that keep no visitor's address.
- Access requests for restricted material, and email delivery that stops writing to addresses that bounced.

## Exchange

- Vendors and the work sent to them: conservation, digitisation, binding and other services, with each record's condition before and after, insurance and valuation checked before records leave, and the documents filed.
- Import and export of EAD 2002, EAD3 and AtoM's CSV, with dry runs and reconciliation; spreadsheets with their columns mapped and mappings kept, ZIPs with the files their rows name, grid entry, undo, and every import as a BagIt bag.
- Watched folders, an FTP or SFTP drop among them, that take in tables, BagIt bags and scans with their sidecars, and a scan API for capture stations.
- Labels for records and containers, with Code 128 and QR codes drawn by the Workspace.
- EAC-CPF and EAC-F, one file or a ZIP of files.
- Export to Dublin Core, MODS and METS.
- RiC-O import and export (JSON-LD, Turtle, RDF/XML) in which every relation leaves and comes back, with a report of what an export does not carry.

## OpenRiC

- A public read API that declares the Core Discovery, Export-Only, Portability, Governance, Authority & Context, Graph Traversal, Digital Object Linkage and Provenance & Event profiles, each tested against the specification's pinned schemas and SHACL shapes.
- OAI-PMH, a dataset descriptor, a change feed, and deprecated IRIs that say what replaced them.
- An OpenAPI 3.1 description, read-only GraphQL, and places within a box or radius as GeoJSON.
- Webhooks that tell another system what changed, signed and retried; sitemaps and an Atom feed of what was published.
- API keys with scopes, limits and expiry; proposals made through the API wait for an archivist to review them.

## Reports

- Reports on holdings, publication, completeness and data quality, downloadable as CSV.
- A report builder with sections, templates, versions, schedules and share links, exporting to CSV, Excel, PDF and Word.

## Research services

- Researcher registration and the reading room: rooms, seats, equipment, bookings, retrieval queues, call slips and walk-ins.
- Reproductions, a shop with PayFast, favourites, feedback and share links.
- Citations in six styles, bibliographies with BibTeX and RIS, and saved searches with alerts.
- The researcher's own workspace: collections, annotations, notebooks, a research diary and shared research workspaces, and submissions to the institution.
- Research projects with teams, milestones and outputs; reasoning tools (claims and evidence, hypotheses, contradictions, decisions); timelines, maps and field alerts; writing, review and publication studios.
- Funding and grant applications, data management plans exported as RDA maDMP, ethics approvals, signs of impact from OpenAlex and Crossref, replication packs as RO-Crate, DOIs registered at DataCite with the institution's own account, and ORCID sign-in.
- Lectures and training courses with assessments and certificates anyone can check, quotas, notices by e-mail or in a digest, an inbox for quick capture, and rights policies that narrow who may use a record's files.

## Security and operations

- Roles and permissions per entity, where a denial wins, and accounts that never act on another institution's records.
- A test that tries every address naming an object as another institution's administrator and as an account with no role, run on every build.
- A deployment check of the configuration before every release.

## What it does not do yet

V0.1 has not been reached. Before it, the Workspace still needs an installation run by someone other than its developers, the acceptance walkthrough with archivists, a backup restore drill and an accessibility review. Preservation, federation, monitoring, publishing and AI assistance are later phases of the [roadmap](https://github.com/openric/workspace/blob/main/ROADMAP.md). Up to and including V1.0 it covers archives only.
