---
layout: default
title: OpenRiC - Change control
description: How the OpenRiC specification, its profiles and its API contract are versioned, deprecated, approved and supported.
kind: spec
---

# Change control

This page is the policy for changing the OpenRiC contract: the specification, its profiles, the [API contract](/contract/openapi.json), the JSON Schemas, the SHACL shapes and the fixtures. It took effect on 2026-10-15 and applies to every release after v0.43.14. The process for proposing a change, and who may object, is in [Governance](/governance.html#how-changes-get-made).

## What carries a version

| Artefact | Version | Where it is recorded |
|---|---|---|
| The specification | `MAJOR.MINOR.PATCH`, currently v{{ site.data.version.version }} | `version.json`, a git tag, and the [release manifest](/release.json) |
| Each profile | Its own `MAJOR.MINOR.PATCH`, moving independently | The profile page header and `_data/profiles.json` |
| The API contract | The specification's version | `info.version` in `contract/openapi.json`; CI fails if it differs |
| JSON Schemas, SHACL shapes, fixtures | The specification's version | The git tag; a server claiming a spec version validates against that tag's files |
| The `openricx:` extension namespace | The major version in its IRI (`/ns/ext/v1#`) | Terms are never removed from `v1`, only deprecated |


## What each change bumps

Before 1.0, a breaking change bumps the minor version. From 1.0 it bumps the major version. A profile follows the same rule against its own version, and the specification's version moves too whenever any profile does.

| Change | Specification before 1.0 | Specification from 1.0 |
|---|---|---|
| Typo, clarification, example, or a fix that does not change any MUST | Patch | Patch |
| New optional endpoint, field or parameter; a relaxed constraint; a new draft profile | Minor | Minor |
| A draft profile becomes normative | Minor | Minor |
| New required endpoint or field; a removed or renamed field; a tightened constraint; a changed status code; a term moved to another namespace | Minor, with a migration note | Major, with a migration note |


When it is unclear whether a change breaks anything, it is treated as breaking.

## Deprecation

Nothing in the contract is deleted without first being deprecated.

- **Marking.** A deprecated endpoint or field says so in its profile, with the release that deprecated it and what replaces it. In the API contract the operation or property carries `deprecated: true`. A deprecated term carries `owl:deprecated true` and `dcterms:isReplacedBy` in its vocabulary.
- **Period.** Before 1.0, a deprecated item stays for at least one further minor release. From 1.0 it stays until the next major release.
- **Servers during the period.** Where a term moves (for example the `openric:` data terms in [mapping O-6](mapping.html#12-open-issues)), servers SHOULD emit both the old and the new term until the old one is removed, so that clients can move at their own pace.

## Migration notes

Every breaking change ships with a migration note in its changelog entry. The note says what changed, whether servers, clients or both are affected, what each must do, and which fixture shows the new behaviour. A breaking change without a note is not released.

## Approval and the signed change log

- **Who approves.** The maintainer, Dr Johan Pieterse, approves every release until the reviewer role in [Governance](/governance.html#roles) is filled.
- **The change log.** Every release has an entry in [`CHANGELOG.md`](https://github.com/openric/spec/blob/main/CHANGELOG.md), newest first, giving the version, the date, what changed, any migration note, and an `Approved by:` line with the approver's name and date. `bin/release` writes the entry, and CI fails when the newest entry does not match the current version or has no approval line.
- **Signed tags.** Each release is an annotated git tag, signed with the maintainer's key, so that `git tag -v v<version>` shows who released it. Release tags are protected on GitHub: they cannot be moved or deleted. Tags up to and including v0.46.0 are annotated but not signed ([known issue K-2](known-issues.html)); signing starts with the first release made after the maintainer's signing key is set up.

## Support

- **Only the current release is supported.** Corrections go into a new release; a published tag is never changed.
- **Earlier releases stay readable.** [Specification versions](/spec/versions/) links to every tag, each showing the repository as it stood at that tag.
- **Servers say what they implement.** A server declares each profile with its version at `GET /`, so a client can tell which profile version it is talking to, whatever the current release is.
- **Security reports** follow [SECURITY.md](https://github.com/openric/spec/blob/main/SECURITY.md), not this process.
