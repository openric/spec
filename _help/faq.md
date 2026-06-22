---
title: Frequently asked questions
category: Reference
order: 3
summary: Common questions about OpenRiC - is it a product, what it costs, RiC-O alignment, SPARQL, writing, AI, and how to get involved.
---

**Is OpenRiC a product?**
No. It's an open *contract* (specification) plus a reference implementation. Any system can implement it; the clients work against any conformant server.

**What does it cost?**
Nothing. Spec is CC-BY 4.0; reference implementation, viewer and capture are AGPL-3.0.

**Which RiC version does it target?**
RiC-CM 1.0 and RiC-O 1.1. The reference serializer emits zero non-canonical `rico:` terms; anything RiC-O lacks lives in the [`openricx:` extension namespace](/help/vocabularies-and-namespaces/).

**Do I have to implement everything?**
No - pick a [profile](/help/profiles-tree/). Core Discovery (read-only) is the minimum useful claim.

**Is there a SPARQL endpoint?**
Yes, under the SPARQL Access profile - read-only `/sparql`. See [SPARQL queries](/help/sparql/).

**Can I write data, not just read it?**
Yes - the Round-Trip Editing profile covers POST/PATCH/DELETE with an audit trail. See [Creating entities](/help/creating-data/). On the reference server, creation is currently open (no key); edits/deletes need a key.

**How is AI-suggested data handled?**
The [modelling wizard](/help/the-modelling-wizard/) can propose models, validated against RiC-CM before display. The draft [Inferred-Provenance profile](/spec/profiles/inferred-provenance.html) requires any machine-asserted data to be visibly distinguishable from documented fact (`prov:wasGeneratedBy`; absence ⇒ asserted fact).

**How do I know a server is conformant?**
Run the [conformance probe](/help/conformance-and-profiles/) and check the profiles it declares at `GET /api/ric/v1/`.

**Is my data locked in?**
No - that's the point. Standard serialisations (JSON-LD/Turtle/RDF-XML, round-trip-guaranteed), a full export path, OAI-PMH, and SPARQL. See [Exporting & harvesting](/help/exporting-and-harvesting/) and the [Portability profile](/spec/profiles/portability.html).

**How do I get involved or report something?**
Open a thread in [GitHub Discussions](https://github.com/openric/spec/discussions) or email [johan@theahg.co.za](mailto:johan@theahg.co.za).

## Next

- [What is OpenRiC?](/help/what-is-openric/) · [Glossary](/help/glossary/)
