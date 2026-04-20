---
layout: default
title: OpenRiC — Frequently asked questions
description: Short, concrete answers to the questions that come up most often. Covers orientation, adoption, data management, conformance, licensing, and contributing.
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">FAQ</div>
    <h1>Frequently asked questions</h1>
    <p class="hero-lede">Short answers. Links to the full material where it exists. If a question you have isn't here, <a href="https://github.com/openric/spec/discussions">open a discussion</a> — we add answers back when they come up more than once.</p>
  </div>
</div>

<nav class="faq-toc" aria-label="On this page">
  <strong>Jump to:</strong>
  <a href="#orientation">Orientation</a> ·
  <a href="#adoption">Adoption</a> ·
  <a href="#data">Data &amp; architecture</a> ·
  <a href="#conformance">Conformance &amp; profiles</a> ·
  <a href="#licensing">Licensing &amp; ownership</a> ·
  <a href="#contributing">Contributing</a>
</nav>

<style>
  .faq-toc { background: var(--surface); padding: 0.75rem 1rem; border-radius: var(--radius); border: 1px solid var(--border); margin: 1rem 0 2rem; font-size: 0.92rem; }
  .faq-toc a { color: var(--accent-2); }
  .faq-q { font-size: 1.05rem; font-weight: 600; color: var(--fg); margin-top: 1.5rem; }
  .faq-q::before { content: "Q. "; color: var(--accent-2); font-weight: 700; }
  .faq-a::before { content: "A. "; color: var(--muted); font-weight: 600; margin-right: 0.15rem; }
  .table-wrap { overflow-x: auto; margin: 1rem 0; }
  .table-wrap table { width: 100%; border-collapse: collapse; font-size: 0.92rem; }
  .table-wrap th { text-align: left; padding: 0.5rem 0.75rem; background: var(--surface-2); border-bottom: 1px solid var(--border); font-weight: 600; }
  .table-wrap td { padding: 0.5rem 0.75rem; border-bottom: 1px solid var(--border); vertical-align: top; }
  .table-wrap tr:last-child td { border-bottom: none; }
</style>

## Orientation {#orientation}

<p class="faq-q" id="what-is-openric">What is OpenRiC?</p>
<p class="faq-a">An open specification for how archival descriptions map to <a href="https://github.com/ICA-EGAD/RiC-O">RiC-CM / RiC-O</a>, how that data is served over HTTP, and how graph-based interfaces can render it consistently across any conformant server. It's a <strong>contract</strong>, not a product — roughly "IIIF, but for archival description". See <a href="/">the home page</a> for the full picture.</p>

<p class="faq-q" id="openric-vs-rico">How is OpenRiC different from RiC-O?</p>
<p class="faq-a">RiC-O is the <em>ontology</em> — the OWL vocabulary of classes and properties published by <a href="https://www.ica.org/ica-network/expert-groups/egad/">ICA EGAD</a>. OpenRiC is a <em>service contract</em> that says how a server should expose RiC-O data over HTTP: endpoint shapes, JSON-LD responses, SHACL validation, conformance declarations. You can implement RiC-O without OpenRiC (by publishing static Turtle files, say) and you can consume OpenRiC without knowing much RiC-O (the JSON-LD is client-friendly). Both layers are deliberately separable.</p>

<p class="faq-q" id="is-it-a-product">Is OpenRiC a product?</p>
<p class="faq-a">No. There's a reference <em>implementation</em> at <a href="https://ric.theahg.co.za">ric.theahg.co.za</a> that runs the Laravel service in <a href="https://github.com/openric/service"><code>openric/service</code></a> — anyone can clone and run it — but the spec itself is deliberately implementation-neutral. A second, independent implementation in a different language is one of the v1.0 freeze criteria.</p>

<p class="faq-q" id="state">What state is OpenRiC in today?</p>
<p class="faq-a">Specification at <strong>v0.2.0 frozen</strong> (April 2026); reference API at <strong>v0.8+</strong> with 46 endpoints and full 8-entity CRUD. Six conformance profiles are defined, each with probe coverage, SHACL shapes, and fixtures. A Core Discovery Profile <strong>v0.3-draft</strong> is open for review. See <a href="/proof.html">proof of implementation</a> for the evidence version.</p>

<p class="faq-q" id="navtool-equivalent">I've been using DLIB Ionian University's RiC-CM NavTool. Where's the equivalent in OpenRiC?</p>
<p class="faq-a"><a href="https://dlib-ionian-university.github.io/ric-cm-nav/">NavTool</a> by Matthew Damigos is an independent Vue SPA that browses a curated JSON export of RiC-CM 1.0 — it was a useful reference point during OpenRiC's reference-browser design. OpenRiC ships its own <strong>live</strong> RiC-CM reference browser at <a href="https://ric.theahg.co.za/reference/ric-cm/">ric.theahg.co.za/reference/ric-cm/</a>, backed by SPARQL queries against the authoritative RiC-O v1.1 ontology (CC BY 4.0, <a href="https://github.com/ICA-EGAD/RiC-O">ICA EGAD</a>) rather than a static export. URL-by-URL mapping:</p>

<div class="table-wrap">
  <table>
    <thead>
      <tr><th>NavTool (hash-routed SPA)</th><th>OpenRiC (versioned, live)</th></tr>
    </thead>
    <tbody>
      <tr>
        <td>Home — hierarchy + counts</td>
        <td><a href="https://ric.theahg.co.za/reference/ric-cm/">/reference/ric-cm/</a></td>
      </tr>
      <tr>
        <td><a href="https://dlib-ionian-university.github.io/ric-cm-nav/#/entities">#/entities</a></td>
        <td><a href="https://ric.theahg.co.za/reference/ric-cm/1.0/entities">/reference/ric-cm/1.0/entities</a> (19)</td>
      </tr>
      <tr>
        <td><a href="https://dlib-ionian-university.github.io/ric-cm-nav/#/entitycard">#/entitycard</a> for a given entity</td>
        <td><a href="https://ric.theahg.co.za/reference/ric-cm/1.0/entities/RiC-E04">/reference/ric-cm/1.0/entities/RiC-E04</a> <em>(or any <code>RiC-E##</code> id)</em></td>
      </tr>
      <tr>
        <td><a href="https://dlib-ionian-university.github.io/ric-cm-nav/#/attributes">#/attributes</a></td>
        <td><a href="https://ric.theahg.co.za/reference/ric-cm/1.0/attributes">/reference/ric-cm/1.0/attributes</a> (42)</td>
      </tr>
      <tr>
        <td><a href="https://dlib-ionian-university.github.io/ric-cm-nav/#/relations">#/relations</a></td>
        <td><a href="https://ric.theahg.co.za/reference/ric-cm/1.0/relations">/reference/ric-cm/1.0/relations</a> (151)</td>
      </tr>
      <tr>
        <td><a href="https://dlib-ionian-university.github.io/ric-cm-nav/#/relation-attributes">#/relation-attributes</a></td>
        <td><a href="https://ric.theahg.co.za/reference/ric-cm/1.0/relation-attributes">/reference/ric-cm/1.0/relation-attributes</a> (6)</td>
      </tr>
      <tr>
        <td><a href="https://dlib-ionian-university.github.io/ric-cm-nav/#/modeling-playground">#/modeling-playground</a> (interactive graph)</td>
        <td><em>Not yet</em> — graph visualisation is roadmapped for a later release, sharing the Cytoscape.js layer with the <a href="https://viewer.openric.org">holdings viewer</a>.</td>
      </tr>
    </tbody>
  </table>
</div>

<p class="faq-a">OpenRiC's differences worth knowing about:</p>
<ul>
  <li><strong>Live SPARQL</strong> against the loaded RiC-O OWL, not a static JSON export. When ICA EGAD releases a new RiC-O version, OpenRiC reflects the change after a single reload.</li>
  <li><strong>Declared vs. inherited separation</strong> on every entity, attribute, and relation page (CIDOC-CRM style). A relation with domain <em>Agent</em> is shown as <em>Agent</em> — never flattened into <em>Agent + Person + Group + Mechanism + Family</em>. Inherited members carry provenance tags back to the ancestor class where they were declared.</li>
  <li><strong>Versioned URLs</strong> — <code>/reference/ric-cm/1.0/…</code> is citation-stable. Unversioned URLs redirect to the current latest, so bookmarks don't rot when RiC-CM 2.x ships.</li>
  <li><strong>No modeling playground yet</strong> — NavTool's interactive graph is the one thing OpenRiC hasn't matched. Planned alongside the holdings graph viewer.</li>
</ul>

<p class="faq-a">Attribution: OpenRiC bundles and queries <strong>RiC-O v1.1</strong>, published by the <a href="https://www.ica.org/ica-network/expert-groups/egad/">International Council on Archives, Expert Group on Archival Description (ICA EGAD)</a> under CC BY 4.0. Every reference-browser page renders the credit per the licence.</p>

---

## Adoption {#adoption}

<p class="faq-q" id="replace-existing">Do I have to replace my existing system to adopt OpenRiC?</p>
<p class="faq-a">No. OpenRiC is designed to be adopted incrementally. The most common path — the <em>strangler pattern</em> — is documented in the <a href="/data-management.html">data-management guide</a>: you run OpenRiC as a read-only projection over your existing database first, add write endpoints for new material next, and migrate legacy data last. No flag-day cutover.</p>

<p class="faq-q" id="alongside-atom">How does OpenRiC work alongside AtoM?</p>
<p class="faq-a">See <a href="/data-management.html#topology-b-side-by-side-with-atom-retrofit">Topology B in the data-management guide</a>. Three phases: (1) OpenRiC reads AtoM's MySQL and serialises as RiC over HTTP — AtoM unchanged; (2) new catalogues land in OpenRiC, back-synced to AtoM for continuity; (3) AtoM retired once historical data is migrated. Timeline varies by institution — typically 6 to 18 months.</p>

<p class="faq-q" id="archivesspace">What about ArchivesSpace, ArchivesHub, Access, or a custom platform?</p>
<p class="faq-a">Same pattern as AtoM. OpenRiC doesn't care what the legacy system is — if its data can be queried via SQL, a file system, a REST API, or SPARQL, a thin adapter on the OpenRiC side reads it and emits RiC JSON-LD. The <a href="/data-management.html#topology-c-consumer-with-its-own-ui-heratio-style">consumer-with-own-UI topology</a> covers the case where you want to keep your admin UI and just route RiC data through OpenRiC.</p>

<p class="faq-q" id="read-only">Can I just use OpenRiC for read-only federated discovery?</p>
<p class="faq-a">Yes — claim only the <code>core-discovery</code> profile. You expose the minimum viable surface (<code>/records</code>, <code>/agents</code>, <code>/repositories</code>, <code>/vocabulary</code>, <code>/autocomplete</code>) and clients targeting that profile work against your server with nothing else required. Useful for aggregators, discovery portals, or pilots that don't want to take on the full edit surface yet.</p>

---

## Data & architecture {#data}

<p class="faq-q" id="where-data-lives">Where does RiC data live?</p>
<p class="faq-a">Wherever you want. The OpenRiC spec describes the HTTP contract only; the backing store is an engineering choice. The <a href="/data-management.html">data-management guide</a> covers the three common shapes — triplestore, normalised relational, hybrid — and which fits each deployment.</p>

<p class="faq-q" id="need-triplestore">Do I need to run a triplestore?</p>
<p class="faq-a">Not strictly, but it's the cleanest way to serve <code>/graph</code> and <code>/sparql</code>. The reference implementation uses <a href="https://jena.apache.org/documentation/fuseki2/">Apache Jena Fuseki</a> as a projection of its relational store — the triplestore isn't authoritative; it's a materialised view for graph queries. If you're not serving graph endpoints, a relational store alone is enough.</p>

<p class="faq-q" id="postgres-instead">Can I use PostgreSQL instead of MySQL / Fuseki?</p>
<p class="faq-a">Yes. The reference API's current MySQL backing is a historical inheritance from Heratio; nothing in the spec mandates it. PostgreSQL with a normalised RiC-shaped schema is a better fit for greenfield deployments (ACID writes, JSON-B support, mature migration tooling). See <a href="/data-management.html#topology-a-green-field-standalone">Topology A</a>.</p>

<p class="faq-q" id="fuseki-down">What happens if Fuseki (or my triplestore) goes down?</p>
<p class="faq-a">Graph endpoints (<code>/graph</code>, <code>/sparql</code>, hierarchy walks) return 503 with the <a href="/conformance/">not-configured</a> partial. All other endpoints — list, detail, autocomplete, writes — continue to work because they hit the relational store. Graph queries recover automatically once the triplestore is reachable again; no data is lost (the relational store is authoritative).</p>

---

## Conformance &amp; profiles {#conformance}

<p class="faq-q" id="what-is-profile">What's a conformance profile?</p>
<p class="faq-a">A named, bounded subset of OpenRiC's endpoint surface. A server claiming <code>core-discovery</code> promises to serve those ten read endpoints correctly; claiming <code>round-trip-editing</code> additionally promises full CRUD. Profiles let implementers commit to what they can actually deliver without pretending to cover the whole spec. See <a href="/profiles.html">profiles</a>.</p>

<p class="faq-q" id="all-profiles">Do I have to implement all six profiles?</p>
<p class="faq-a">No. Implement the subset that matches your server's actual capabilities. The minimum useful claim is <code>core-discovery</code>; you add profiles (Authority &amp; Context, Graph Traversal, Digital Object Linkage, Round-Trip Editing, Export-Only) as you implement their endpoint surfaces. A conformance probe run against your server with <code>--profile=&lt;id&gt;</code> verifies you deliver what you claim.</p>

<p class="faq-q" id="claim-profile">How do I claim a profile on my server?</p>
<p class="faq-a">Declare it in your service description. <code>GET /</code> must return <code>openric_conformance.profiles[]</code> with an entry per claimed profile — see <a href="/spec/profiles/core-discovery.html#31-service-description-get-">core-discovery.md §3.1</a> for the shape. The conformance probe reads this declaration and cross-checks it against your actual endpoint surface.</p>

<p class="faq-q" id="conformance-badge">What does the conformance badge mean?</p>
<p class="faq-a">A live, <a href="https://shields.io">shields.io</a>-compatible badge showing whether your server declares a given profile. Green means declared and claimed <code>full</code>; grey means not declared. See <a href="/conformance/badge.html">badge docs</a> for the embed pattern. Because it reads your server's live declaration, it updates automatically — no manual version bumps or stale badges.</p>

---

## Licensing &amp; ownership {#licensing}

<p class="faq-q" id="why-two-licences">Why CC BY 4.0 for the spec but AGPL for the implementations?</p>
<p class="faq-a">Different goals. The <strong>spec</strong> wants maximum reuse — attribute, remix, embed, build derivative standards — so CC BY 4.0. The <strong>reference implementation</strong> wants fixes and improvements to flow back into the commons — so AGPL-3.0. You can build any commercial product you want against the HTTP contract; you can't take the reference implementation's code, close it, and ship a proprietary fork.</p>

<p class="faq-q" id="commercial">Can I build a commercial product on OpenRiC?</p>
<p class="faq-a">Yes. The contract is open; any client or server that speaks <code>/api/ric/v1/*</code> is fine. If you fork the reference implementation, AGPL applies — your modifications must be available to your users. If you write your own implementation from scratch, you pick your own licence.</p>

<p class="faq-q" id="federation-ownership">Who owns the data in a federated deployment?</p>
<p class="faq-a">Whoever runs the server. OpenRiC doesn't aggregate or centralise anything — each institution runs its own conformant endpoint, and clients (viewers, aggregators, researchers) federate across them as they choose. Data ownership, privacy, and access control stay local. The spec defines <code>X-API-Key</code> for write auth; read auth is implementation-defined.</p>

---

## Contributing {#contributing}

<p class="faq-q" id="propose-spec-change">How do I propose a spec change?</p>
<p class="faq-a">Open a <a href="https://github.com/openric/spec/discussions">discussion</a> with the shape of the change first — what surface, what shape, what's driving it. Substantive changes then become PRs against <code>openric/spec</code> with a short rationale in the commit message. See <a href="/governance.html">governance</a> for the review process.</p>

<p class="faq-q" id="design-questions">Where do open design questions live?</p>
<p class="faq-a">Each profile document has an "Open design questions" section at the end — see <a href="/spec/profiles/core-discovery.html#10-open-design-questions">core-discovery.md §10</a> for the current list. Questions marked "draft resolution" have our take; questions marked <em>open</em> are actively seeking external input. Q6 (error-envelope migration) is the one currently open.</p>

<p class="faq-q" id="second-implementation">I want to write a second implementation. Where do I start?</p>
<p class="faq-a">Start with the <a href="/guides/getting-started.html">getting-started guide</a> as a client to understand the shapes, then the <a href="/spec/">four spec documents</a> for the contract, then run the <a href="/conformance/">conformance probe</a> against your server as you build. The <a href="/fixtures/manifest.json">fixture manifest</a> tells you which of the 27 fixtures exercise each profile — useful as unit tests. A second, independent implementation passing conformance on any profile is the <a href="/">v1.0 freeze criterion</a>.</p>

---

## Something missing?

This FAQ grows from questions that actually come up. If yours isn't here, [ask on Discussions](https://github.com/openric/spec/discussions) or [email Johan directly](mailto:johan@theahg.co.za). Answers that come up more than twice get added back here.
