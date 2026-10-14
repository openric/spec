---
layout: default
title: OpenRiC - Specification versions
description: Where earlier versions of the OpenRiC specification are preserved, and which version is current.
permalink: /spec/versions/
kind: education
---

# Specification versions

The current specification is **v{{ site.data.version.version }}**, released {{ site.data.version.release_date }}. It is the only version this site presents as current. Every page under [/spec/](/spec/) describes it.

Earlier versions are not republished on this site, so they can never compete with the current one. Each release is preserved, unchanged, as a git tag in the specification repository:

- [All tagged versions](https://github.com/openric/spec/tags) - one tag per release, from v0.1.0 onward.
- [Release notes](https://github.com/openric/spec/releases) for each tag.
- [The changelog](https://github.com/openric/spec/blob/main/CHANGELOG.md), which says what changed in each version.

To read the specification exactly as it stood at an earlier release, open the `spec/` folder at that tag. For example, the RiC-O 1.1 remediation release is at [github.com/openric/spec/tree/v0.37.0/spec](https://github.com/openric/spec/tree/v0.37.0/spec).

## Version lines

The specification and the reference service carry separate version numbers on purpose. A server states which specification version it verifies against in its service description, under `openric_conformance.spec_version`. The [current status](/status/) page shows what the reference service declares today.

Each profile also carries its own version, independent of the specification's; see [the profile index](/spec/profiles/).
