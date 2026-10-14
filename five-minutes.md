---
layout: default
title: OpenRiC in five minutes
description: One object, followed end to end - from catalogue record, through the people, activities, places and laws around it, to a 3D file and a machine-readable export. Read live from the reference service's demonstration data, in six clicks.
permalink: /five-minutes/
---

# OpenRiC in five minutes

One object, followed all the way through. Everything below is read live from the reference service, and you can click every link.

The record describes a model funeral boat from ancient Egypt, identifier **BM-125320**. It is a good test case because almost nothing interesting about it fits in a catalogue record.

{% include evidence.html kind="synthetic" note="The catalogue record was assembled on the reference service for demonstration. Its holder in the data is the fictional Meridian Museum of Antiquities and its description was machine-generated from an image of the 3D model. It is not a British Museum catalogue record, and the British Museum has not reviewed or endorsed this demonstration." %}

{% include evidence.html kind="derived" note="The attached 3D model appears to be <a href='https://sketchfab.com/3d-models/egyptian-boat-from-ancient-lives-cd65f231f70c4f258fe2f8a07979f9c7'><em>Egyptian Boat from Ancient Lives</em></a> by Miguel Bandera, licensed <a href='https://creativecommons.org/licenses/by-nc/4.0/'>CC BY-NC 4.0</a>, which he built from photographs the British Museum released for its Ancient Lives project (<a href='https://github.com/BritishMuseumDH/egyptianBoat'>source data</a> by Daniel Pett, The British Museum, <a href='https://creativecommons.org/licenses/by-sa/4.0/'>CC BY-SA 4.0</a>). The model may be used only with this attribution and not commercially." %}

<div class="flow">
  <p class="flow-note"><strong>The question this demo answers.</strong> A traditional archival description can tell you the boat exists, who holds it, and what it looks like. It cannot easily tell you that the object was produced in Thebes, transferred into the collection that holds it now, governed today by a specific Egyptian antiquities statute, and now also exists as a downloadable 3D file - and that those four facts are connected to each other, not just to the record.</p>
</div>

## Minute 1 - the record on its own

<a class="btn-primary" href="https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat">Open the record →</a>

What you get is ordinary description: a title, the identifier `BM-125320`, a holder, a description. Useful, and roughly what any catalogue would give you.

Notice what is already different: the holder is not a string of text. It is a link to the holding museum as a thing in its own right. That single difference is what the rest of this demo is built on.

## Minute 2 - follow the connections

<a class="btn-primary" href="https://viewer.openric.org/?start=/informationobject/egyptian-boat">Open the graph →</a>

Twenty-one things, twenty connections. Two seconds to draw.

Walk outwards from the boat and you pass through places (Africa, Egypt, Thebes), the repository holding it, several activities, two pieces of legislation, and two digital files. None of that is a search result. Every one of those is a stated, typed relationship that a machine can follow without guessing.

The legend names the relationship types in plain language. Clicking any node re-centres the graph on it, and the trail along the top is your way back.

## Minute 3 - the custody chain

Four activities sit in this graph, and together they are a life story:

| Activity | What it records |
|---|---|
| Production of funeral boat model | The object being made, in Egypt |
| Creation | The archival creation event |
| Transfer to current repository | How it came to be held where it is |
| 3D Photogrammetry Digitisation | A modern act that produced a new instantiation |

This is the part traditional description handles worst. In an ISAD(G) record, custody history is a paragraph of prose - readable by a person, invisible to everything else. Here each step is an entity, with its own date, place and participants, and the digitisation event is treated as exactly the same kind of thing as the original production. Neither is privileged.

## Minute 4 - the law, and the file

Two `Rule` entities are attached to this material: the **Egyptian Antiquities Protection Law (Law 117/1983)** and a Giza protection ordinance.

That is a genuinely hard thing to express anywhere else. The statute is not a property of the record and not a note on it - it is a separate thing, with its own identity, which happens to govern this material and could govern thousands of other items too. Model it once, link it many times, and a question like *which of our holdings are affected by Law 117/1983* becomes a query rather than a research project.

Then follow `hasOrHadInstantiation` and you arrive at **egyptian_boat_from_ancient_lives.glb** - a glTF 3D model. The intellectual record and its digital manifestation are distinct entities, which is why the archive can hold six versions of a file without pretending they are six records.

## Minute 5 - take the data with you

<a class="btn-primary" href="https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat/export?format=ttl">Export as Turtle →</a>

One request returns the whole thing as RDF, with `rico:` terms throughout and every relationship intact. No key, no account, no negotiation.

This is the part that matters if you are deciding whether to adopt anything. The graph you just walked is not locked inside the viewer, and the viewer is not privileged - it is an ordinary client reading an open contract. Point [any conformant viewer](/explore.html) at the same server and you get the same graph. Move your data to a different implementation and the relationships survive, because they are in the data rather than in somebody's schema.

<div class="evidence">
  <h2>What you just used</h2>
  <ul class="evidence-items">
    <li>Specification <strong>v{{ site.data.version.version }}</strong></li>
    <li>RiC-O 1.1 terms</li>
    <li>JSON-LD and Turtle</li>
    <li>No authentication</li>
    <li><a href="/spec/">The contract</a></li>
    <li><a href="/ric-baseline.html">Standards baseline</a></li>
  </ul>
</div>

## Being honest about the data

The reference dataset is a working archive, not a showcase, and it shows. Go poking around and you will find records titled "Duck duck go", a repository whose label still ends in "UPDATED" from somebody's test edit, and an entity typed as an `Activity` that is plainly a family. The boat's own description is machine-generated and reads like it.

Two Egypts appear in the graph, and that one is more interesting than a mistake. One is a subject heading inherited from the underlying catalogue; the other is a Place entity with its own description. They are two different things in two different systems that happen to share a name - which is exactly the kind of reconciliation problem this model is supposed to make visible rather than hide.

That is left visible on purpose. A demo built on hand-groomed data proves nothing about whether the model survives contact with real holdings, and the [drift log](/drift-log.html) records the gaps we know about rather than hiding them.

## Where to go next

Start with [Explore](/explore.html) if you want to wander further into the data, [Learn and model](/learn.html) if you want to know which entity fits something you hold, or [Build](/for-developers.html) if you want to implement the contract yourself.
