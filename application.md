---
layout: default
title: OpenRiC Workspace - planned
description: OpenRiC Workspace is a planned archival management application built on Records in Contexts. What it will be, what it will not be, and where it stands today.
permalink: /application/
kind: current
---

# OpenRiC Workspace

<p class="callout"><strong>Status: planned. Nothing on this page is available to install yet.</strong> The application is planned, and work on it starts only after the OpenRiC specification has passed its own acceptance review. The migration route from Heratio is planned, not operational.</p>

## Archival management, built around context

OpenRiC Workspace is a planned archival management application built on the International Council on Archives' Records in Contexts (RiC) standard.

It is designed for archives setting up a new digital management environment. It will bring archival description, authority control, contextual relationships, digital objects and public discovery into one RiC-native workspace. For institutions using Heratio, a defined migration route will support moving compatible archival information into the standalone Workspace.

## Three things called OpenRiC, kept apart

| Name | What it is | Where it lives |
|---|---|---|
| **The OpenRiC specification** | An implementation-neutral contract for publishing and exchanging RiC data over HTTP. Anyone can implement it. | [Specification](/spec/), on this site |
| **OpenRiC Workspace** | One application that will implement that contract: an archival system for archives starting fresh. | This page; not yet built |
| **Developer tools** | The reference API, the browse demo, the viewer, the capture client and the conformance probe. Tools for implementers, not for day-to-day archival work. | [Developers](/for-developers.html) |

When this site says "OpenRiC" on its own, it means the specification. The Workspace's own choices of database, sign-in or workflow will never become requirements of the specification.

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

Work on the Workspace starts after the Standard Acceptance Gate; until then the [current status](/status/) page tracks the specification it depends on, and the [known-issues log](/spec/known-issues.html) what still stands in the way. The project's code is in its [GitHub repositories](https://github.com/openric). Questions are welcome through [Ask a question](/ask/).
