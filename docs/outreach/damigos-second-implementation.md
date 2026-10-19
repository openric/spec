# Outreach - Matthew Damigos / Ionian University

**Recipient:** Matthew Damigos, Laboratory of Digital Libraries and Electronic Publishing, Department of Archives, Library Science and Museology, Ionian University (mgdamigos@ionio.gr, the contact on his RiC Resource List entry for the RiC-CM NavTool).
**Outcome we want:** a reply on any one of three threads: probing the Corfu Criminal Court description against Core Discovery, the overlap between his RiC-CM NavTool and the OpenRiC RiC-CM navigator, and a second reader for the OpenRiC mapping.
**Status:** sent by Dr Johan Pieterse on 19 October 2026. The April 2026 draft that stood here was replaced before sending: it claimed that no non-canonical `rico:*` emissions remained, which the v0.50.0 review showed was not true.

---

## Subject

> Corfu, the RiC-CM navigators, and a second reader for a mapping

## Body, as sent

Dear Matthew,

I have been reading your work through the ICA/EGAD RiC Resource List: the RiC-CM NavTool, the Corfu Criminal Court paper in Moderna arhivistika, and the 2023 mapping of RiC-CM to CIDOC-CRM with Lina Bountouri and colleagues. Describing 2,698 homicide case files from the Ionian State period in RiC-CM is the kind of applied work the model needs, and court records are a domain I have no examples of at all.

I maintain OpenRiC (https://openric.org), an open specification for serving RiC data over the web: a JSON-LD API following RiC-O 1.1, a mapping from the four ICA standards, named conformance profiles, and a probe that tests a server against them. It is an independent project, not an ICA one, and so far it has only one implementation, ours. That is the gap I most want to close.

There are three things I would value your view on. Any one of them is enough.

The Corfu description. If it is published as data, in any form, I would like to see how far it is from OpenRiC's simplest profile, Core Discovery. Our probe is read-only and runs from a shell script, so it costs you nothing, and I would send you the result before showing it to anyone else. If the gap is small, it would be the first evidence that OpenRiC works on description someone else made.

The two navigators. Your NavTool and our RiC-CM navigator (https://ric.theahg.co.za/reference/ric-cm/) cover similar ground. I would rather link to yours than compete with it, and I would like to know what you think each does better before I change anything.

The mapping. Our ISAD(G) and ISAAR(CPF) to RiC-O mapping (https://openric.org/spec/mapping.html) needs a careful second reader. Checking it against RiC-O 1.1 this week, we found a few places where it gives literal values to object properties such as rico:hasBeginningDate, and I would rather hear of the rest from someone who knows the model than find them one by one. Your CIDOC-CRM mapping also marks exactly where our scope stops and the museum side begins, and I would like to cite it as the reference for that boundary, if you are content with that.

None of this needs more than a short reply. A call at a time that suits Corfu works for me too.

With best wishes,

Dr Johan Pieterse
The Archive and Heritage Digital Commons Group (Pty) Ltd
South Africa
johan@theahg.co.za
https://openric.org

---

## After sending

- The literal-date problem the email mentions was fixed the same day in spec v0.50.0 and service v0.17.18.
- If he agrees to the citation, link the RiC-CM to CIDOC-CRM mapping (https://doi.org/10.1007/978-981-99-8088-8_8) from `ric-baseline.md`, where OpenRiC says what it is not a replacement for.
