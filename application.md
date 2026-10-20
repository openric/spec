---
layout: default
title: OpenRiC Workspace - in development
description: OpenRiC Workspace is an archival management application in development, built on Records in Contexts. What it does today, what it will not be, and what still stands between it and its first release.
permalink: /application/
kind: current
---

# OpenRiC Workspace

<p class="callout"><strong>Status: in development, not yet released for use.</strong> Development releases run at workspace.openric.org (sign-in required) and the code is public. The first release meant for archivists, V0.1, has not been reached. The migration route from Heratio is planned, not operational.</p>

## Archival management, built around context

OpenRiC Workspace is an archival management application in development, built on the International Council on Archives' Records in Contexts (RiC) standard.

It is designed for archives setting up a new digital management environment. It will bring archival description, authority control, contextual relationships, digital objects and public discovery into one RiC-native workspace. For institutions using Heratio, a defined migration route will support moving compatible archival information into the standalone Workspace.

## Three things called OpenRiC, kept apart

| Name | What it is | Where it lives |
|---|---|---|
| **The OpenRiC specification** | An implementation-neutral contract for publishing and exchanging RiC data over HTTP. Anyone can implement it. | [Specification](/spec/), on this site |
| **OpenRiC Workspace** | One application that implements that contract: an archival system for archives starting fresh. | This page; code at [openric/workspace](https://github.com/openric/workspace) |
| **Developer tools** | The reference API, the browse demo, the viewer, the capture client and the conformance probe. Tools for implementers, not for day-to-day archival work. | [Developers](/for-developers.html) |

When this site says "OpenRiC" on its own, it means the specification. The Workspace's own choices of database, sign-in or workflow will never become requirements of the specification.

## Where it stands

Development started on 19 October 2026, when [ADR 0003](https://github.com/openric/workspace/blob/main/architecture/adr/0003-implementation-before-the-s-gate.md) moved the work ahead of the Standard Acceptance Gate. Since then the Workspace has gained:

- **The data model.** Units of description, authority records, repositories, places, activities and the institution's own vocabularies are RiC entities with persistent IRIs. Every relation is held through assertions that record who said it and on what evidence, and a hash-chained, signed audit log covers it all.
- **Description and publication.** The ISAD(G), ISAAR(CPF) and ISDIAH screens, each field labelled with the RiC-O term it is kept or exported as, and a review and publish workflow per value and language.
- **Exchange.** Import and export of EAD 2002, EAD3 and AtoM's CSV, with dry runs and reconciliation, and export to Dublin Core and MODS.
- **OpenRiC.** A public read API declaring the [Core Discovery](/spec/profiles/core-discovery.html) and [Export-Only](/spec/profiles/export-only.html) profiles, with RiC-O JSON-LD, OAI-PMH and persistent IRIs that resolve. On a copy of its live data with a published sample, the conformance probe passes both.

Still missing for V0.1 are digital objects, public discovery with a graph view, a tested restore, and the demonstration run end to end. The Workspace is from the same organisation as the specification, so it does not count as the independent implementation the specification still needs ([known issue K-6](/spec/known-issues.html)).

## What it will cover

Archival work: accessioning and appraisal, arrangement and description, authority control, contextual relationships between records, people, activities, places and rules, ingest of digital objects, rights and access, publication, public discovery, and export in standard formats.

Preservation will be an integration with a preservation system such as Archivematica. Uploading a file and recording its checksum will not be described as preservation.

It will not cover museum, library or gallery management, or general digital asset management. Heratio does that.

## How it relates to Heratio

Heratio is an integrated platform for galleries, libraries, archives and museums, with RiC already built into it. OpenRiC Workspace is a separate, focused application for archives that do not need the rest of that. They differ in scope and purpose, not in which one does more.

The Workspace will run without Heratio. It will not share Heratio's database or depend on its services. An archive moving from Heratio will export its data and import it into the Workspace, with a report that accounts for every record, relationship and access restriction, including anything that has no place in an archives-only system.

## What it will be judged by

The first release has one test. An archivist signs in, describes and arranges a collection, links the people and activities behind it, attaches a digital object, sends the description for review, publishes the approved version, finds it in both the catalogue and the relationship graph, exports it, and reads back who changed what and why. They do all of that without touching an API. The same test then runs again on data migrated from Heratio.

One more principle runs through all of it. The Workspace will show what it knows, what it infers and what it cannot establish. A statement made by a person, one transformed from another source, and one suggested by software will look different, and a machine suggestion will not become an archival fact until someone has reviewed it.

## Follow the work

The Workspace's [roadmap](https://github.com/openric/workspace/blob/main/ROADMAP.md) and [architecture decisions](https://github.com/openric/workspace/tree/main/architecture/adr) are in its repository. The [current status](/status/) page tracks the specification it implements, and the [known-issues log](/spec/known-issues.html) what still stands in the way. The project's code is in its [GitHub repositories](https://github.com/openric). Questions are welcome through [Ask a question](/ask/).
