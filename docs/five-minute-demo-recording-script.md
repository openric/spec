# Recording script - "OpenRiC in five minutes"

Companion to [`/five-minutes/`](https://openric.org/five-minutes/). The page and
the video follow the same five beats, so one can be watched and the other
clicked, and neither has to be rewritten when the other changes.

Everything is live data. Nothing here needs staging, which also means a broken
backend breaks the recording - check the links the morning you record.

## Before you start

| Item | Value |
|---|---|
| Subject | Model funeral boat, ancient Egypt, British Museum `BM-125320` |
| Record | `https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat` |
| Graph | `https://viewer.openric.org/?start=/informationobject/egyptian-boat` |
| Turtle | `https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat/export?format=ttl` |
| Browser | 1280x720 minimum, zoom 125% so text is legible at small sizes |
| Audio | Voice-over recorded separately and laid over. Live narration while clicking always runs long. |

Use a browser profile with no extensions, no bookmarks bar and no logged-in
session. A visible password manager icon in a standards demo is a distraction
people remember better than the content.

## The five beats

### 0:00-0:35 - the problem, before any screen

No browser yet. Title card, or just the object.

> "This is a model funeral boat from ancient Egypt. About four and a half
> thousand years old, British Museum number BM-125320. A catalogue record can
> tell you it exists, who holds it, and what it looks like. It cannot easily
> tell you that it was made in Thebes, moved to London, is governed today by a
> specific Egyptian statute, and now also exists as a downloadable 3D file -
> and that those facts are connected to each other."

Do not say "in today's digital landscape". Do not explain what an ontology is.
The object is the hook; the model is the payoff.

### 0:35-1:20 - the record on its own

Open the record URL. Let the JSON-LD sit on screen for a beat before speaking.

Highlight two things only: the identifier `BM-125320`, and `rico:hasOrHadHolder`.

> "Ordinary description so far. One difference: the holder isn't the text 'The
> British Museum'. It's a link to the British Museum as a thing in its own
> right. Everything else follows from that."

Resist reading fields aloud. The viewer can read.

### 1:20-2:20 - follow the connections

Open the graph URL. **Say nothing for three seconds** while it draws.

> "Twenty-one things, twenty connections. Places, the repository, four
> activities, two pieces of legislation, two digital files. None of this is a
> search result - every line is a stated relationship a machine can follow."

Click one node to re-centre. Point out the trail along the top, then click back
along it. That single move is what makes people understand it is a graph and
not a picture.

### 2:20-3:20 - the custody chain

Stay in the graph. Hover the four activities in this order: Production of
funeral boat model, Creation, Transfer to current repository, 3D Photogrammetry
Digitisation.

> "Together these are a life story. Made in Egypt, accessioned, transferred,
> and - in our lifetime - digitised. In a traditional record that history is a
> paragraph of prose: readable by a person, invisible to everything else. Here
> each step is an entity with its own date and place. And the digitisation is
> exactly the same kind of thing as the original production. Neither is
> privileged."

That last sentence is the one archivists react to. Leave a pause after it.

### 3:20-4:10 - the law, and the file

Hover the two Rule nodes, then the glTF instantiation.

> "Egyptian Antiquities Protection Law 117 of 1983. The statute isn't a note on
> the record - it's a separate thing with its own identity, which happens to
> govern this material and could govern thousands of other items. Model it
> once, link it many times. 'Which of our holdings are affected by Law 117?'
> becomes a query instead of a research project."

Then the instantiation:

> "And the 3D file is distinct from the record. Which is how an archive holds
> six versions of a file without pretending it has six records."

### 4:10-5:00 - take the data with you

Open the Turtle export. Scroll slowly once, top to bottom.

> "One request, no key, no account. The whole thing as RDF, every relationship
> intact. The graph you just walked isn't locked inside that viewer - the viewer
> is an ordinary client reading an open contract. Point a different conformant
> client at the same server and you get the same graph. Move to a different
> implementation and the relationships survive, because they're in the data
> rather than in somebody's schema."

End on the Turtle, not on a logo. The last frame should be the thing they can
take away.

## What to leave out

Five minutes is short, and each of these has sunk a version of this demo:

- The conformance probe, profiles and SHACL. All genuinely good, none of it a
  reason a stranger cares in the first five minutes.
- The spec version number. Nobody adopts a standard because it reached v0.43.
- 3D mode in the viewer. It looks impressive and it slows the story down.
- Any sentence containing the word "leverage".

## Honesty, and why it belongs in the cut

Somebody will go poking around after watching, and they will find records
titled "Duck duck go", a repository still labelled "UPDATED" from a test edit,
and an entity typed as `Activity` that is plainly a family. The boat's own
description is machine-generated and reads like it.

Two rows that were worse than this - "Giza Pyramid" typed as an activity with
activity-type `mandate`, and "Giza Pyramid Organization" whose name, type and
description disagreed with each other - were deleted on 28 September, which is
why the graph is 21 nodes rather than the 23 an earlier draft of this script
quoted. If you are re-recording, check the count on the day.

Two Egypts remain and are worth a sentence rather than an apology: one is a
subject heading from the underlying catalogue, the other a Place entity with
its own description. Two things in two systems sharing a name is a
reconciliation problem the model is meant to surface, not a typo.

Better to say so than be caught:

> "This is a working archive, not a showcase, and it has the rough edges you'd
> expect. We leave them visible - a demo on hand-groomed data proves nothing
> about whether the model survives real holdings."

That line buys more credibility than a clean dataset would.

## If the recording is generated rather than screen-captured

Voice-over plus screen capture is the right format here, and an image-to-video
pipeline is the wrong tool for it: the whole point is that the graph is live
and responds to clicks. Generated motion over static frames would undercut the
one claim the demo exists to make.

Title and end cards are worth generating. The five beats are not.
