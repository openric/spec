# Outreach draft — Sparna

**Recipient:** [Thomas Francart](https://www.sparna.fr/) / Sparna team. Find the most relevant team email at [`sparna.fr/contact`](https://www.sparna.fr/contact) or, for a lower-stakes first contact, open a [GitHub Discussion](https://github.com/sparna-git/garance/discussions) on the Garance repo.
**Outcome we want:** sanity-check on the OpenRiC SPARQL Access (Draft) profile + open the door to Garance being listed as a second implementation on that profile.
**Status:** draft, do not send until v0.38.0 (SPARQL Access fixtures + SHACL) is on `origin/main`.

---

## Suggested subject

> OpenRiC SPARQL Access (Draft) profile — sanity-check + Garance second-implementation question

---

## Body

Hi Thomas,

I work on [OpenRiC](https://openric.org) — an open, implementation-neutral HTTP/API contract for serving RiC-aligned archival data. We're a smaller project than Garance: a spec + reference Laravel API + browser viewer + capture client + conformance probe, all CC-BY/AGPL. The aim is a contract any RiC-O 1.1-compliant server can implement.

Three things prompted this email:

**1. Garance is the cleanest RiC-O 1.1 publication architecture I've seen.** The Eleventy + JSON-LD framing + PageFind + QLever stack is a topology we cite in our [Related Implementations page](https://openric.org/related-implementations.html) and our [SPARQL Access (Draft) profile](https://openric.org/spec/profiles/sparql-access.html) §9 Q4 (the QLever vs Fuseki/Jena discussion). It is the working reference for "what mature RiC-O publication looks like."

**2. We just shipped the SPARQL Access (Draft) profile.** It defines an optional 8th profile for OpenRiC servers that want to expose a SPARQL 1.1 query surface — minimum viable obligations, an access-policy taxonomy (`public-read` / `authenticated-read` / `tenant-restricted`), rate-limit / max-query-time disclosure, and a `/sparql/info` `void:Dataset` description endpoint. SHACL shapes and two fixtures (`sparql-info`, `sparql-construct`) are in v0.38.0.

I'd value your sanity-check on the draft as someone who has actually run a public SPARQL endpoint over RiC-O 1.1 at scale. Specifically:

- Is the access-policy taxonomy missing any kind of access posture you've seen at AnF or elsewhere?
- Is `/sparql/info` the right shape for a `void:Dataset` description, or have you seen a different convention emerge?
- Is the openricx-only `@context` requirement on JSON-LD CONSTRUCT/DESCRIBE results too strict / too loose?

**3. The bigger ask, posed gently.** OpenRiC's v1.0 freeze is gated on at least one non-reference implementation passing the conformance probe. Garance, by virtue of being an RDF-first publication of agents/places/concepts under RiC-O 1.1 with a SPARQL endpoint, is structurally close to a second implementation on the SPARQL Access profile — it would need to expose a `/sparql/info` endpoint matching our `void:Dataset` shape and respond to conformance-probe checks. **We are NOT asking for a commitment** — but if you'd be open to a future conversation about whether Garance v2 (the mid-June 2026 release per your roadmap) could opt into this profile, that would unblock something significant for us.

OpenRiC will not absorb Garance content, will preserve original AnF URIs and attribution per the [`Referentiels` repository](https://github.com/ArchivesNationalesFR/Referentiels) terms, and will list Garance on the [Related Implementations page](https://openric.org/related-implementations.html) as an external project — which we already do.

If sanity-checking the draft is too much without context, I'm happy to walk through the profile's design decisions (especially Q1-Q5 in §9) over a call. Equally happy with terse line-by-line feedback on the draft itself via GitHub Discussions on `openric/spec`.

Thanks for everything Sparna does for the EGAD ecosystem.

— Johan Pieterse
[`openric.org`](https://openric.org) · [`github.com/openric/spec`](https://github.com/openric/spec)

---

## Pre-send checklist

- [ ] v0.38.0 (SPARQL Access fixtures + SHACL) on `origin/main`
- [ ] [`spec/profiles/sparql-access.html`](https://openric.org/spec/profiles/sparql-access.html) renders correctly with v0.38 additions
- [ ] [`fixtures/sparql-info`](https://github.com/openric/spec/tree/main/fixtures/sparql-info) and [`fixtures/sparql-construct`](https://github.com/openric/spec/tree/main/fixtures/sparql-construct) accessible and pass the conformance probe
- [ ] [`shapes/profiles/sparql-access.shacl.ttl`](https://github.com/openric/spec/blob/main/shapes/profiles/sparql-access.shacl.ttl) accessible
- [ ] Garance v1 still live (sanity-check the URL stays valid through end of session)
