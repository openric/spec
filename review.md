---
layout: default
title: Review OpenRiC
description: One place to review OpenRiC - its mappings, its interoperability or its fit with archival work - with a question, a five-minute example and a way to reply for each.
permalink: /review/
kind: current
usability_thread: https://github.com/openric/spec/discussions/new?category=general
---

# Review OpenRiC

OpenRiC gets better when people who did not write it try to break it. This page is the single way in. Pick the path that matches what you know best; each one asks one question, gives you something to look at in about five minutes, points to the parts of the specification that matter, and tells you where to send what you find.

You do not need to read the whole specification first, and you do not need a GitHub account: every path also takes email, at [johan@theahg.co.za](mailto:johan@theahg.co.za?subject=OpenRiC%20review). Criticism is the most useful kind of reply.

Before you start, two things about what you are reviewing. OpenRiC is an independent project, not an ICA standard (see [RiC and OpenRiC](/ric-baseline.html#ric-and-openric)). And the records you will see on the reference service are demonstration data, not a real archive's holdings.

## 1. Semantic mappings

**For** archivists and describers who know ISAD(G), ISAAR(CPF), ISDIAH or ISDF, and anyone who works with RiC-CM or RiC-O.

**The question.** Where does OpenRiC's mapping from the four ICA standards to RiC-O 1.1 misrepresent what a describer meant? A wrong class, a property that loses a distinction, a relation pointing the wrong way, or an `openricx:` extension term that RiC-O already covers.

**Five minutes.** Open one demonstration record as the API serves it:

```bash
curl -s https://ric.theahg.co.za/api/ric/v1/records/cat-in-arms
```

Then put it next to the [class mapping](/spec/mapping.html#6-class-mapping) and [property mapping](/spec/mapping.html#7-property-mapping) tables and ask whether each field ended up where you would have put it. If you would rather see a whole description followed end to end, [OpenRiC in five minutes](/five-minutes/) does that with one object.

**Read next:** [mapping specification](/spec/mapping.html), [standards baseline](/ric-baseline.html), [extension vocabulary](/ns/ext/v1.html), [RiC-O 1.1 audit](/audit/ric-o-1.1-audit.html).

**Reply:** [Discussion #3, "Where does the ISAD(G) to RiC-O mapping feel wrong to you?"](https://github.com/openric/spec/discussions/3), or by email.

## 2. Technical interoperability

**For** developers, integrators and anyone who maintains another archival system.

**The question.** Could you build a server or a client from the published documents alone, and where did you have to guess? Ambiguous wording, a schema that disagrees with the prose, a fixture that does not match its profile, or a probe check that passes something it should not.

**Five minutes.** Run the minimal server that ships with the specification and probe it, with no AHG service involved:

```bash
git clone --depth 1 https://github.com/openric/spec.git && cd spec
PORT=8080 python3 examples/minimal-server/server.py &
BASE=http://localhost:8080 KEY="" bash conformance/probe.sh --profile=core-discovery
```

You need Python 3, `curl` and `jq`, nothing else. The probe should report 11 checks passed. Then read the server (about 320 lines) against the [Core Discovery profile](/spec/profiles/core-discovery.html) and see whether the two agree.

**Read next:** [implement a server](/guides/implement-a-server.html), [API contract](/contract/openapi.json) (OpenAPI 3.1), [profiles](/spec/profiles/), [evaluate OpenRiC independently](/guides/evaluate-independently.html).

**Reply:** [Discussion #2, "If you were building a second OpenRiC implementation, what would you need from us?"](https://github.com/openric/spec/discussions/2), or by email. A defect with a clear reproduction can go straight to [the issue tracker](https://github.com/openric/spec/issues).

## 3. Archival usability

**For** reference archivists, researchers and anyone who explains records to the people who use them.

**The question.** Does the picture OpenRiC draws, records linked to the agents, activities, places and dates around them, help someone understand an archive, or does it get in the way? Where would a researcher get lost, and what would you expect to see that is missing?

**What is already known.** Little, and most of it from experienced users. The closest study is Merel Geerlings' 2021 thesis for the Stadsarchief Amsterdam (see [further reading](/learn.html#further-reading)). From the literature and a month of the city archive's search logs, she concluded that RiC could meet most of what users ask for. She also found that it does nothing to explain why a search returned what it did, and that labels such as "Record Resource" and "Instantiation" may mean little to the public. She advised keeping the classic fonds-to-item tree alongside any graph view for now. None of this was tested with users, which is where reviewers can help most.

So, as well as the question above: when you land on a single record, can you tell which records it belongs with, who made them, and why it was shown to you? Do the RiC labels mean anything to someone without archival training? Would you still want a conventional tree next to the graph, and for whom? Please say whether you count yourself an experienced or an inexperienced archive user.

**Five minutes.** [Browse the demonstration records](/demo/browse/), open one, and follow its links in the graph view. Then try [modelling something you hold](/wizard/) in the wizard, and notice where its questions stop making sense for your material.

**Read next:** [learn RiC](/learn.html), [for archivists](/for-archivists.html), [explore](/explore.html).

**Reply:** [start a discussion]({{ page.usability_thread }}), or by email.

## What happens to a review

Every review so far, its findings, our responses and what is still unresolved are in the [review register](/review/register/). A reviewer is named there only with their permission.


Replies go to the maintainer. A change one leads to goes through [change control](/spec/change-control.html): a correction to wording or a fixture is a patch release, and a change to what a server must send is a minor release with a migration note, recorded in the [change log](https://github.com/openric/spec/blob/main/CHANGELOG.md). Open problems that are already known are listed in [known issues](/spec/known-issues.html) and the [drift log](/drift-log.html), so check there first if something looks wrong.
