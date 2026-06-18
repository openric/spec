# Outreach draft — Valentin Mansilla (RiC users forum)

**Recipient:** Valentin Mansilla — PhD researcher cataloguing ethnographic magnetic tapes. Posted on the [Records_in_Contexts_users](https://groups.google.com/g/Records_in_Contexts_users) Google Group (his first post).
**Channel:** public reply on the Google Group thread (reply-all, keep it on-list so the answer helps others).
**Outcome we want:** (1) confirm his Record / Record Part modelling so he can proceed; (2) introduce the OpenRiC modelling wizard + RiC-CM navigator as a hands-on reference, without it reading as a pitch.
**Status:** ready to post **once `/wizard/` is live** (openric-spec v0.40.0 on GitHub Pages). If posting before the wizard ships, drop the wizard link and keep the navigator link only.

---

## Suggested subject

> Re: Modelling magnetic tapes — Record vs Record Part

---

## Body

Hi Valentin, and welcome to the forum.

Your instinct is sound — and it's exactly how RiC is meant to be used. Modelling **the tape as a Record** and **each track as a Record Part** is the right call when the tracks carry mixed provenance. A Record Part (RiC-E05) is defined as *"a component of a Record with independent information content that contributes to the intellectual completeness of the Record"* — which describes tracks-of-a-tape almost word for word.

Two things that make it work cleanly in practice:

1. **Per-track provenance lives on relations, not attributes.** A Record Part declares no attributes of its own — it inherits name / identifier / scope-and-content / extent from Record Resource. So you attach each track's *own* creator, place, date and subject as **relations on that Record Part** (e.g. `has creator` → an Agent). Because the relations sit on the part, each track can have a different creator, place and date — which is the whole reason to use Record Parts here.

2. **"The tape as a whole" is really two things.** The recorded *content* is the Record; the physical *reel* (¼-inch tape, speed, condition) is best modelled as an **Instantiation** (RiC-E06) linked to that Record. Keeping them separate lets you describe an original reel and a later digitisation as two Instantiations of the same Record.

The one genuine judgement call: **Record Part vs. a Record in a Record Set.** If a track is really a standalone work you want catalogued and discovered on its own, model the tracks as separate Records grouped in a Record Set. If they're components that only make sense as parts of the one recording — your case — Record Part is the better fit.

If it helps to see it built end-to-end, we put together a small interactive walkthrough of exactly this scenario, which shows the modelling decisions and lets you create the entities against a live RiC server: **https://openric.org/wizard/** — and you can browse the model itself (Record Part = RiC-E05, with its inherited vs declared attributes) here: **https://ric.theahg.co.za/reference/ric-cm/1.0/entities/RiC-E05**.

Hope that helps — happy to go deeper on any of it.

Kind regards,
Johan Pieterse

---

## Notes before sending

- Kept deliberately tool-light so it reads as peer advice, not a pitch — the OpenRiC links are at the end, framed as "if it helps".
- Verify the wizard is live (`https://openric.org/wizard/` returns 200) before posting, since the reply links to it.
- Optional: post as a reply to the existing thread rather than a new post, so the answer is threaded under his question for future searchers.
