---
layout: default
title: OpenRiC — Proof of implementation
description: Real data, real endpoints, real mappings. The evidence that the OpenRiC contract works in practice, not just on paper.
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Proof of implementation</div>
    <h1>Real data. Real endpoints. Real mappings.</h1>
    <p class="hero-lede">
      OpenRiC is a contract. This page is the evidence that the contract works — a live reference implementation backed by real archival data, concrete ISAD(G)&nbsp;→&nbsp;RiC-O mappings, and end-to-end use cases you can follow with <code>curl</code>.
    </p>
    <div class="hero-cta">
      <a class="btn-primary" href="https://ric.theahg.co.za/api/ric/v1/">Live service root ↗</a>
      <a class="btn-ghost" href="{{ '/demo/browse/' | relative_url }}">Browse all records</a>
      <a class="btn-ghost" href="{{ '/api-explorer/' | relative_url }}">Open API Explorer</a>
    </div>
  </div>
</div>

## Reference implementation — live numbers

The OpenRiC reference API at <code><a href="https://ric.theahg.co.za/api/ric/v1/">ric.theahg.co.za</a></code> is backed by a real archival service (The Archive and Heritage Group) with multi-jurisdiction holdings and live digital objects.

<div class="proof-stats">
  <div class="proof-stat"><strong>713</strong><span>Records</span></div>
  <div class="proof-stat"><strong>402</strong><span>Agents</span></div>
  <div class="proof-stat"><strong>14</strong><span>Repositories</span></div>
  <div class="proof-stat"><strong>183</strong><span>Places</span></div>
  <div class="proof-stat"><strong>234</strong><span>Activities</span></div>
  <div class="proof-stat"><strong>3</strong><span>Rules</span></div>
  <div class="proof-stat"><strong>1,281</strong><span>Instantiations</span></div>
  <div class="proof-stat"><strong>698</strong><span>Relations</span></div>
  <div class="proof-stat"><strong>1,276</strong><span>Digital objects</span></div>
  <div class="proof-stat"><strong>6</strong><span>Languages</span></div>
</div>

Every counter maps to a real endpoint: <code>/records</code>, <code>/agents</code>, <code>/repositories</code>, <code>/places</code>, <code>/activities</code>, <code>/rules</code>, <code>/instantiations</code>, <code>/relations</code>. Everything you see is live, content-negotiated, CORS-open, and unauthenticated for reads.

<style>
.proof-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 0.75rem; margin: 1.25rem 0 2rem; }
.proof-stat { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 0.9rem 1rem; text-align: center; }
.proof-stat strong { display: block; font-size: 1.6rem; font-weight: 700; color: var(--accent); letter-spacing: -0.01em; }
.proof-stat span { font-size: 0.8rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.03em; }
.e2e-step { display: grid; grid-template-columns: 2.5rem 1fr; gap: 1rem; padding: 1rem 0; border-top: 1px solid var(--border); }
.e2e-step:first-child { border-top: 0; }
.e2e-step .num { font-weight: 700; color: var(--accent); font-size: 1.4rem; text-align: right; }
.e2e-step h4 { margin: 0 0 0.35rem; }
.e2e-step p { margin: 0.25rem 0 0.5rem; }
.entity-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1rem; margin: 1.25rem 0; }
.entity-card { border: 1px solid var(--border); border-radius: var(--radius); padding: 1rem; background: var(--surface); }
.entity-card h4 { margin: 0 0 0.25rem; }
.entity-card code { font-size: 0.82rem; word-break: break-all; }
.entity-card .type { display: inline-block; padding: 0.1rem 0.45rem; background: var(--accent); color: #fff; font-size: 0.72rem; border-radius: 3px; letter-spacing: 0.03em; margin-bottom: 0.35rem; font-weight: 600; }
.mapping-table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.9rem; }
.mapping-table th, .mapping-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid var(--border); vertical-align: top; text-align: left; }
.mapping-table th { background: var(--surface-2); font-weight: 600; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.04em; color: var(--muted-2); }
.mapping-table code { font-size: 0.85rem; }
.screenshot-placeholder { background: var(--surface-2); border: 2px dashed var(--border); border-radius: var(--radius); padding: 2rem; text-align: center; color: var(--muted); font-size: 0.9rem; margin: 0.75rem 0; }
</style>

## End-to-end use case

**Scenario:** a curator has a single archival record — *Egyptian Boat* (BM-125320, held by The British Museum) — and wants it to appear in a third-party graph viewer, harvested by an OAI consumer, and validated against SHACL. Here is the full trajectory the OpenRiC contract guarantees.

<div class="e2e-step">
  <div class="num">1</div>
  <div>
    <h4>Cataloguing</h4>
    <p>A curator describes the record in Heratio (or any OpenRiC-compliant producer) using standard ISAD(G) fields — title, identifier, dates, creator, scope, extent, repository.</p>
    <p><em>Inputs live in the producer. OpenRiC does not dictate the editing UI.</em></p>
  </div>
</div>

<div class="e2e-step">
  <div class="num">2</div>
  <div>
    <h4>Mapping — ISAD(G) → RiC-O</h4>
    <p>The producer maps ISAD(G) fields into RiC-O classes and predicates (see the mapping table below) and exposes each entity at a stable HTTP URL. Heratio does this automatically; other producers can follow <a href="{{ '/spec/mapping.html' | relative_url }}">spec §3 — Canonical mapping</a>.</p>
  </div>
</div>

<div class="e2e-step">
  <div class="num">3</div>
  <div>
    <h4>Publishing — JSON-LD over HTTP</h4>
    <p>The record is live at <a href="https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat"><code>/api/ric/v1/records/egyptian-boat</code></a>, content-negotiated, with an embedded <code>rico:heldBy</code> link to the British Museum repository and a stable <code>@id</code> anyone can follow.</p>
<pre><code>curl https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">4</div>
  <div>
    <h4>Graph traversal</h4>
    <p>A third-party viewer calls <code>/graph?uri=...&depth=2</code> and receives a normalized Subgraph envelope — nodes, edges, canonical <code>rico:*</code> predicates on every edge. Exactly the same shape from every conformant server.</p>
<pre><code>curl "https://ric.theahg.co.za/api/ric/v1/graph?uri=https://ric.theahg.co.za/informationobject/egyptian-boat&amp;depth=2"</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">5</div>
  <div>
    <h4>Validation — SHACL</h4>
    <p>A validator (for example <code>openric-validate</code>, shipped in the spec repo) runs the published JSON-LD against the spec's SHACL shapes. Shapes catch missing identifiers, dangling references, and wrong cardinalities before they reach downstream consumers.</p>
<pre><code>openric-validate --record https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">6</div>
  <div>
    <h4>Harvesting — OAI-PMH</h4>
    <p>An aggregator (think Europeana, DPLA, a national portal) harvests the record via OAI-PMH <code>/oai</code>, with metadata prefixes <code>oai_dc</code> and <code>rico_ld</code>. No bespoke integration — it is the same verb set every OpenRiC server speaks.</p>
<pre><code>curl "https://ric.theahg.co.za/api/ric/v1/oai?verb=ListRecords&amp;metadataPrefix=rico_ld"</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">7</div>
  <div>
    <h4>Embedding</h4>
    <p>A research institution drops the viewer component into their own portal and points it at <code>ric.theahg.co.za</code> — or at their own conformant server. Same embed, different backend; that is the interoperability dividend.</p>
  </div>
</div>

That is the contract: one record, seven touchpoints, zero bespoke adapters. Every step has a live endpoint on this site.

## Example entities — one of each type

Each card links to a real JSON-LD document served by the reference API. Open any of them in your browser (or <code>curl</code> them) — they are unauthenticated reads.

<div class="entity-grid">
  <div class="entity-card">
    <span class="type">rico:Record</span>
    <h4>Egyptian Boat</h4>
    <p>Identifier <code>BM-125320</code>, held by The British Museum. Digital object attached. Multi-language descriptions.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat"><code>/records/egyptian-boat</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Agent</span>
    <h4>Person agent</h4>
    <p>Minimal <code>rico:Person</code> — name, culture, stable @id. Canonical in <a href="{{ '/fixtures/agent-person-simple/' | relative_url }}">agent-person-simple</a>.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/agents/d6mh-ktzy-h6qz"><code>/agents/d6mh-ktzy-h6qz</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:CorporateBody</span>
    <h4>The British Museum</h4>
    <p>ISDIAH repository. Holdings linked via <code>rico:hasHolding</code>. Address and contact fields preserved.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/repositories/the-british-museum"><code>/repositories/the-british-museum</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Place</span>
    <h4>Egypt</h4>
    <p>Place with GeoNames authority URI and coordinates. Used as <code>rico:hasOrHadSubject</code> target for the Egyptian Boat record.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/places"><code>/places</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Activity</span>
    <h4>Production event</h4>
    <p>Creation event linking a record to its creator agent plus a date range. See <a href="{{ '/fixtures/activity-production/' | relative_url }}">activity-production</a>.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/activities"><code>/activities</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Rule</span>
    <h4>Egyptian Antiquities Law</h4>
    <p>Law 117/1983 — a <code>rico:Rule</code> governing an activity. Demonstrates mandate + legal-context chaining.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/rules"><code>/rules</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Instantiation</span>
    <h4>TIFF digital object</h4>
    <p>Derivative instantiation of a physical record — MIME, byte count, checksum, IIIF manifest link where present.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/instantiations"><code>/instantiations</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Function</span>
    <h4>ISDF function</h4>
    <p>Function / activity-context description — used to model why a record was created and by which business process.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/functions"><code>/functions</code></a></p>
  </div>
</div>

## Sample mapping — ISAD(G) → RiC-O

This is the 1:1 mapping the reference implementation applies at read time. No transformation pipeline — just predicate translation.

<table class="mapping-table">
  <thead>
    <tr><th>ISAD(G) element</th><th>RiC-O predicate</th><th>Notes</th></tr>
  </thead>
  <tbody>
    <tr><td>3.1.1 Reference code</td><td><code>rico:identifier</code></td><td>String, one per record; registrar-assigned.</td></tr>
    <tr><td>3.1.2 Title</td><td><code>rico:title</code></td><td>Multi-language via <code>@language</code> tags.</td></tr>
    <tr><td>3.1.3 Dates</td><td><code>rico:hasBeginningDate</code>, <code>rico:hasEndDate</code></td><td>xsd:gYear, xsd:date, or xsd:dateTime.</td></tr>
    <tr><td>3.1.4 Level of description</td><td><code>rico:hasRecordSetType</code></td><td>fonds / subfonds / series / file / item.</td></tr>
    <tr><td>3.1.5 Extent and medium</td><td><code>rico:hasExtent</code></td><td>Free-text on the record; structured extent on Instantiation.</td></tr>
    <tr><td>3.2.1 Name of creator</td><td><code>rico:hasCreator</code></td><td>Link to a <code>rico:Agent</code>; inverse <code>rico:isCreatorOf</code>.</td></tr>
    <tr><td>3.2.2 Administrative/biographical history</td><td><code>rico:history</code> on the linked Agent</td><td>Not a predicate on the Record itself.</td></tr>
    <tr><td>3.2.3 Archival history</td><td><code>rico:history</code></td><td>Custody + transfer chain.</td></tr>
    <tr><td>3.2.4 Immediate source of acquisition</td><td><code>rico:hasAcquisitionProvenance</code></td><td>Link to the donor/transferor Agent.</td></tr>
    <tr><td>3.3.1 Scope and content</td><td><code>rico:description</code></td><td>Long-form prose.</td></tr>
    <tr><td>3.4.1 Conditions governing access</td><td><code>rico:hasAccessRule</code></td><td>Link to a <code>rico:Rule</code> when the restriction is formal.</td></tr>
    <tr><td>3.4.3 Language</td><td><code>rico:hasLanguage</code></td><td>ISO 639 code.</td></tr>
    <tr><td>3.4.4 Physical characteristics</td><td><code>rico:hasPhysicalCharacteristics</code></td><td>Condition, binding, material.</td></tr>
    <tr><td>3.5.1 Existence of originals</td><td><code>rico:hasInstantiation</code></td><td>Each copy / format is its own <code>rico:Instantiation</code>.</td></tr>
    <tr><td>3.5.3 Related descriptions</td><td><code>rico:isRelatedTo</code> (symmetric)</td><td>Falls back to <code>rico:isOrWasSubjectOf</code> where typed.</td></tr>
    <tr><td>Repository</td><td><code>rico:heldBy</code></td><td>Link to a <code>rico:CorporateBody</code> playing the Repository role.</td></tr>
  </tbody>
</table>

The full canonical mapping (including ISAAR-CPF, ISDIAH, and ISDF) lives in <a href="{{ '/spec/mapping.html' | relative_url }}">spec §3</a>. The fixture pack at <a href="{{ '/fixtures/' | relative_url }}">fixtures/</a> pins 27 concrete input/output pairs against this mapping.

## Example dataset — the Egyptian Boat mini-fonds

The reference implementation ships an <code>openric:seed-demo</code> Artisan command that populates a coherent mini-fonds for exactly this "proof" purpose. Running it creates:

- 1 repository (The British Museum)
- 1 fonds + 3 series + items (Egyptian antiquities)
- 2 creator agents
- 1 place (Egypt, with GeoNames URI)
- 1 rule (Egyptian Antiquities Law 117/1983)
- 1 activity linking creator → fonds
- TIFF + PDF instantiations with SHA-256 checksums

All browseable at <a href="{{ '/demo/browse/' | relative_url }}">openric.org/demo/browse/</a>. You can rebuild the same dataset on your own server in under a minute:

```bash
php artisan openric:seed-demo
php artisan openric:rebuild-nested-set
```

## Screenshots

<div class="screenshot-placeholder">
  Live surfaces you can capture right now — no static images needed:
  <br><br>
  <a href="{{ '/demo/browse/' | relative_url }}">Browse view</a>
  &nbsp;·&nbsp;
  <a href="{{ '/demo/' | relative_url }}">Graph viewer</a>
  &nbsp;·&nbsp;
  <a href="{{ '/api-explorer/' | relative_url }}">API Explorer (Swagger UI)</a>
  &nbsp;·&nbsp;
  <a href="https://capture.openric.org">Capture client</a>
</div>

## Going further

- Read the <a href="{{ '/spec/' | relative_url }}">spec</a> — four documents, <code>v0.2.0</code> is current.
- Run the <a href="{{ '/conformance/' | relative_url }}">conformance probe</a> against any server to check claims.
- Open the <a href="{{ '/fixtures/' | relative_url }}">fixture pack</a> — 27 input/output pairs covering every RiC-O type.
- Follow the <a href="{{ '/guides/getting-started.html' | relative_url }}">15-minute getting-started guide</a> to point your own server at the same contract.

*The strongest evidence that a spec is implementable is a spec that's implemented. Everything on this page is running right now. Change a record in the reference impl, and the responses above change in real time.*
