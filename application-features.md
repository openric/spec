---
layout: default
title: Workspace features
description: What OpenRiC Workspace does today, area by area, as released up to v0.0.99. In development; not yet released for use.
permalink: /application/features/
kind: current
---

# Workspace features

<p class="callout"><strong>In development, not yet released for use.</strong> This page lists what OpenRiC Workspace does in its development releases, up to v0.0.99 of 2 November 2026, which run at <a href="https://workspace.openric.org/discover">workspace.openric.org</a>. It lists only what is built and released; what is still to come is in the <a href="https://github.com/openric/workspace/blob/main/ROADMAP.md">roadmap</a>, and why each part works as it does is under <a href="{{ '/application/decisions/' | relative_url }}">decisions and assumptions</a>.</p>

Much of the Workspace copies what Heratio and AtoM-based systems already do, field for field, and rebuilds it on the RiC model. Where it departs from them, the decisions page says so.

## The data model

- Units of description, authority records (people, families and corporate bodies), repositories, places, activities, functions and rules are RiC entities, each with a persistent IRI that resolves.
- Every relation is held through assertions that record who said it, on what evidence, with what certainty, and whether it is accepted, proposed or disputed. Relation types are data, each with its RiC-O class, property and inverse.
- A unit has one parent, where it is arranged, and may also be in other record sets, each membership a `rico:Proxy` with its own order.
- Dates, names, identifiers and places are entities of their own, with their dates of use.
- Vocabularies are the institution's own SKOS schemes, never fixed lists in code, and every field shows the RiC-O term it is kept or exported as, or that RiC-O has none.
- A hash-chained, signed audit log covers every change, and its chain can be verified.
- Duplicate authority records and places can be merged; the merged IRI leads to the one kept, and a deleted entity answers that it is gone, with its successor.

## Description and publication

- RiC-native forms, with ISAD(G), ISAAR(CPF), ISDIAH, DACS, RAD, Dublin Core and MODS layouts kept as labelled compatibility views.
- A hierarchy tree beside every unit, inventories, finding aids and print views.
- Review and publication per value and per language, publish gates, and publish readiness.
- An interface in English and Afrikaans; an institution offers any language that has a translation file.

## Archival management

- Accessions after the CAAIS profile: intake, checklists, appraisal, valuation, containers, rights and deaccessions, each accession exported as an activity with its donor taking part.
- Donor agreements with their rights, restrictions, reminders and documents.
- Provenance and custody history, each step an activity affecting the record.
- Workflows and tasks: steps, claiming from the pool, assignment, teams by role, queues, service levels with warnings and escalation, and bulk operations.
- Rights: RightsStatements.org, Creative Commons, copyright status, PREMIS grants, and Local Contexts Traditional Knowledge and Biocultural Labels, shown in the catalogue and carried in every export.
- Embargoes on records and their files, with exceptions, warnings before they end and review dates.
- Retention schedules and disposal classes, reviews, a disposal workflow with separation of duties, and destruction that keeps the description as evidence and issues a certificate that verifies.
- POPIA governance: Information Officers, the processing register, impact assessments, consent, data subject and PAIA requests, complaints and security compromises; scanning records for personal information, redaction for the public, and screening before files are released.

## Digital objects

- Files attached as instantiations, with checksums, derived copies, fixity checks, extracted text, embedded metadata, alternative text and watermarks.
- Viewers for images, PDF, sound, video and 3D models.
- IIIF Presentation 3 manifests and collections, curated collections, Change Discovery, Content State, Content Search over transcripts, and the Authorization Flow for files available on request.

## Discovery and search

- A public catalogue that needs no sign-in, with full-text search and facets, pages for every kind of entity, and the relationship graph around each in 2D or 3D, also given as a list for screen readers and keyboards.
- Staff search with saved searches and statistics.
- Usage statistics that keep no visitor's address.
- Access requests for restricted material, and email delivery that stops writing to addresses that bounced.

## Exchange

- Import and export of EAD 2002, EAD3 and AtoM's CSV, with dry runs and reconciliation.
- EAC-CPF and EAC-F, one file or a ZIP of files.
- Export to Dublin Core and MODS.
- RiC-O import and export (JSON-LD, Turtle, RDF/XML) in which every relation leaves and comes back, with a report of what an export does not carry.

## OpenRiC

- A public read API that declares the Core Discovery, Export-Only, Portability, Governance, Authority & Context, Graph Traversal, Digital Object Linkage and Provenance & Event profiles, each tested against the specification's pinned schemas and SHACL shapes.
- OAI-PMH, a dataset descriptor, a change feed, and deprecated IRIs that say what replaced them.
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
