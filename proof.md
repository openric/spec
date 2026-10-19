---
layout: default
title: OpenRiC - Proof of implementation
description: Live endpoints, concrete mappings and labelled example data - the evidence that the OpenRiC contract works in practice, and what kind of evidence each part is.
kind: current
---

<div class="hero">
  <div class="hero-inner">
    <div class="hero-eyebrow">Proof of implementation</div>
    <h1>Live endpoints. Concrete mappings. Labelled data.</h1>
    <p class="hero-lede">
      OpenRiC is a contract. This page is the evidence that the contract works - a live reference implementation, concrete ISAD(G)&nbsp;→&nbsp;RiC-O mappings, and end-to-end use cases you can follow with <code>curl</code>. Example data is labelled with what kind of evidence it is.
    </p>
    <div class="hero-cta">
      <a class="btn-primary" href="https://ric.theahg.co.za/api/ric/v1/">Live service root ↗</a>
      <a class="btn-ghost" href="{{ '/demo/browse/' | relative_url }}">Browse all records</a>
      <a class="btn-ghost" href="{{ '/api-explorer/' | relative_url }}">Open API Explorer</a>
    </div>
  </div>
</div>

## Reference implementation

The OpenRiC reference API at <code><a href="https://ric.theahg.co.za/api/ric/v1/">ric.theahg.co.za</a></code> runs on the database of Heratio, the archival platform of The Archive and Heritage Digital Commons Group. Much of what it holds is demonstration material rather than an institution's holdings; the examples on this page say which is which.

How many records, agents, places and other entities it holds right now is on the [current status]({{ '/status/' | relative_url }}) page, read live from the service each time you open it. This page does not repeat the figures, because typed-in counts go out of date.

The list endpoints - <code>/records</code>, <code>/agents</code>, <code>/repositories</code>, <code>/places</code>, <code>/activities</code>, <code>/rules</code>, <code>/instantiations</code>, <code>/relations</code> - are content-negotiated and open to every origin for reads, with no key needed.

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
</style>

## End-to-end use case

**Scenario:** a curator has a single archival record - *Egyptian Boat* (identifier BM-125320) - and wants it to appear in a third-party graph viewer, harvested by an OAI consumer, and validated against SHACL. Here is the path the OpenRiC contract defines for it.

{% include evidence.html kind="synthetic" note="The catalogue record was assembled on the reference service for demonstration. Its holder in the data is the fictional Meridian Museum of Antiquities and its description was machine-generated from an image of the 3D model. It is not a British Museum catalogue record, and the British Museum has not reviewed or endorsed this demonstration." %}

<div class="e2e-step">
  <div class="num">1</div>
  <div>
    <h4>Cataloguing</h4>
    <p>A curator describes the record in Heratio (or any OpenRiC-compliant producer) using standard ISAD(G) fields - title, identifier, dates, creator, scope, extent, repository.</p>
    <p><em>Inputs live in the producer. OpenRiC does not dictate the editing UI.</em></p>
  </div>
</div>

<div class="e2e-step">
  <div class="num">2</div>
  <div>
    <h4>Mapping - ISAD(G) → RiC-O</h4>
    <p>The producer maps ISAD(G) fields into RiC-O classes and predicates (see the mapping table below) and exposes each entity at a stable HTTP URL. The reference service does this automatically; other producers can follow the <a href="{{ '/spec/mapping.html#7-property-mapping' | relative_url }}">canonical mapping, §7</a>.</p>
  </div>
</div>

<div class="e2e-step">
  <div class="num">3</div>
  <div>
    <h4>Publishing - JSON-LD over HTTP</h4>
    <p>The record is live at <a href="https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat"><code>/api/ric/v1/records/egyptian-boat</code></a>, content-negotiated, with an embedded <code>rico:hasOrHadHolder</code> link to its holding repository and a stable <code>@id</code> anyone can follow.</p>
<pre><code>curl https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">4</div>
  <div>
    <h4>Graph traversal</h4>
    <p>A third-party viewer calls <code>/graph?uri=...&depth=2</code> and receives a normalized Subgraph envelope - nodes, edges, canonical <code>rico:*</code> predicates on every edge. Exactly the same shape from every conformant server.</p>
<pre><code>curl "https://ric.theahg.co.za/api/ric/v1/graph?uri=https://ric.theahg.co.za/informationobject/egyptian-boat&amp;depth=2"</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">5</div>
  <div>
    <h4>Validation - SHACL</h4>
    <p>A validator (for example <code>openric-validate</code>, shipped in the spec repo) runs the published JSON-LD against the spec's SHACL shapes. Shapes catch missing identifiers, dangling references, and wrong cardinalities before they reach downstream consumers.</p>
<pre><code>openric-validate --record https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">6</div>
  <div>
    <h4>Harvesting - OAI-PMH</h4>
    <p>An aggregator (think Europeana, DPLA, a national portal) harvests the record via OAI-PMH <code>/oai</code>, with metadata prefixes <code>oai_dc</code> and <code>rico_ld</code>. No bespoke integration - it is the same verb set every OpenRiC server speaks.</p>
<pre><code>curl "https://ric.theahg.co.za/api/ric/v1/oai?verb=ListRecords&amp;metadataPrefix=rico_ld"</code></pre>
  </div>
</div>

<div class="e2e-step">
  <div class="num">7</div>
  <div>
    <h4>Embedding</h4>
    <p>A research institution drops the viewer component into their own portal and points it at <code>ric.theahg.co.za</code> - or at their own conformant server. Same embed, different backend; that is the interoperability dividend.</p>
  </div>
</div>

That is the contract: one record, seven touchpoints, zero bespoke adapters. Steps 3, 4 and 6 run live against the reference service with the commands shown; step 5 runs the validator from the specification repository.

## Example entities - one of each type

Each card links to a real JSON-LD document served by the reference API. Open any of them in your browser (or <code>curl</code> them) - they are unauthenticated reads.

<div class="entity-grid">
  <div class="entity-card">
    <span class="type">rico:Record</span>
    <h4>Egyptian Boat</h4>
    <p>Identifier <code>BM-125320</code>. Synthetic demonstration record - see the label above.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/records/egyptian-boat"><code>/records/egyptian-boat</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Record</span>
    <h4>Gilded dining suite</h4>
    <p>Identifier <code>OPENRIC-DEMO-3D-1</code>. A glTF 3D model attached as an instantiation. The model and the image it was generated from are AI-generated; it depicts no real object.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/records/gilded-dining-suite-ai-generated-3d-model"><code>/records/gilded-dining-suite-ai-generated-3d-model</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Agent</span>
    <h4>Person agent</h4>
    <p>Minimal <code>rico:Person</code> - name, culture, stable @id. Canonical in <a href="{{ '/fixtures/agent-person-simple/' | relative_url }}">agent-person-simple</a>.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/agents/d6mh-ktzy-h6qz"><code>/agents/d6mh-ktzy-h6qz</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:CorporateBody</span>
    <h4>Meridian Museum of Antiquities</h4>
    <p>ISDIAH repository holding the demonstration record above. Holdings linked via <code>rico:isOrWasHolderOf</code>. A fictional institution.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/repositories/meridian-museum-of-antiquities"><code>/repositories/meridian-museum-of-antiquities</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Place</span>
    <h4>Egypt</h4>
    <p>A place entity; it appears in the Egyptian Boat record's graph.</p>
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
    <p>Law 117/1983 - a <code>rico:Rule</code> governing an activity. Demonstrates mandate + legal-context chaining.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/rules"><code>/rules</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">rico:Instantiation</span>
    <h4>TIFF digital object</h4>
    <p>Derivative instantiation of a physical record - MIME, byte count, checksum, IIIF manifest link where present.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/instantiations"><code>/instantiations</code></a></p>
  </div>
  <div class="entity-card">
    <span class="type">openricx:Function</span>
    <h4>ISDF function</h4>
    <p>Function / activity-context description - used to model why a record was created and by which business process.</p>
    <p><a href="https://ric.theahg.co.za/api/ric/v1/functions"><code>/functions</code></a></p>
  </div>
</div>

## Sample mapping - ISAD(G) → RiC-O

An excerpt of the ISAD(G) rows of the mapping. The authoritative table is <a href="{{ '/spec/mapping.html#71-information-object-isadg' | relative_url }}">mapping §7.1</a>, which also covers ISAAR(CPF), ISDIAH and ISDF; where this excerpt and the mapping differ, the mapping is right. The reference service emits a subset of these rows.

<table class="mapping-table">
  <thead>
    <tr><th>ISAD(G) element</th><th>RiC-O predicate</th><th>Notes</th></tr>
  </thead>
  <tbody>
    <tr><td>3.1.1 Reference code</td><td><code>rico:identifier</code></td><td></td></tr>
    <tr><td>3.1.2 Title</td><td><code>rico:title</code></td><td>Language-tagged.</td></tr>
    <tr><td>3.1.3 Dates</td><td><code>openricx:hasDateRangeSet</code></td><td>The API shape; in RDF it expands to <code>rico:hasCreationDate</code>, <code>rico:hasBeginningDate</code> and <code>rico:hasEndDate</code>.</td></tr>
    <tr><td>3.1.4 Level of description</td><td>the class, and <code>rico:hasRecordSetType</code></td><td>fonds, series, file and so on.</td></tr>
    <tr><td>3.1.5 Extent and medium</td><td><code>rico:hasExtent</code></td><td>A <code>rico:Extent</code> with <code>rico:hasExtentType</code>.</td></tr>
    <tr><td>3.2.1 Name of creator</td><td><code>rico:hasCreator</code></td><td>Link to a <code>rico:Agent</code>.</td></tr>
    <tr><td>3.2.2 Administrative/biographical history</td><td><code>rico:history</code> on the Agent</td><td>Not on the record itself.</td></tr>
    <tr><td>3.2.3 Archival history</td><td><code>rico:history</code> on the record</td><td></td></tr>
    <tr><td>3.2.4 Immediate source of acquisition</td><td><code>rico:isOrWasAffectedBy</code> a transfer <code>rico:Activity</code></td><td>With <code>rico:hasOrHadParticipant</code> pointing to the source Agent.</td></tr>
    <tr><td>3.3.1 Scope and content</td><td><code>rico:scopeAndContent</code></td><td>Servers that sent <code>openricx:description</code> send both until at least v0.48.0.</td></tr>
    <tr><td>3.3.4 System of arrangement</td><td><code>rico:structure</code></td><td></td></tr>
    <tr><td>3.4.1 Conditions governing access</td><td><code>rico:conditionsOfAccess</code></td><td></td></tr>
    <tr><td>3.4.3 Language</td><td><code>rico:hasOrHadLanguage</code> on a record; <code>rico:hasOrHadAllMembersWithLanguage</code> or <code>rico:hasOrHadSomeMembersWithLanguage</code> on a record set</td><td>ISO 639-3 code. RiC-O 1.1 does not allow <code>rico:hasOrHadLanguage</code> on a record set.</td></tr>
    <tr><td>3.4.4 Physical characteristics</td><td><code>rico:physicalCharacteristicsNote</code></td><td>On the record's <code>rico:Instantiation</code>.</td></tr>
    <tr><td>3.5.1 Existence and location of originals</td><td><code>rico:hasOrHadLocation</code></td><td></td></tr>
    <tr><td>3.5.2 Existence and location of copies</td><td><code>rico:hasOrHadInstantiation</code></td><td>Each copy or format is its own <code>rico:Instantiation</code>.</td></tr>
    <tr><td>3.5.3 Related units of description</td><td><code>rico:isRelatedTo</code></td><td></td></tr>
    <tr><td>3.7.2 Rules or conventions</td><td><code>rico:isOrWasRegulatedBy</code></td><td>Link to a <code>rico:Rule</code>.</td></tr>
    <tr><td>Repository</td><td><code>rico:hasOrHadHolder</code></td><td>Link to a <code>rico:CorporateBody</code> holding the material.</td></tr>
  </tbody>
</table>

The fixture pack at <a href="{{ '/fixtures/' | relative_url }}">fixtures/</a> pins {{ site.data.inventory.fixtures }} concrete input/output pairs.

## Example dataset - a demonstration mini-fonds you can rebuild

The Egyptian Boat above is not created by any command; it was assembled on the reference service by hand. To build a coherent example dataset on your own server, the reference implementation ships an <code>openric:seed-demo</code> Artisan command. It creates a small fonds about an imaginary Stellenbosch family, with every entity type the API serves:

- 1 repository - OpenRiC Demo Archive
- 1 place - Stellenbosch
- 1 agent - Johanna le Roux
- 1 rule - a family papers retention policy
- 1 function - family correspondence
- 1 fonds with 2 series - correspondence, and botanical field journals
- 1 activity - field journaling
- 1 item with 1 instantiation - a watercolour of *Protea neriifolia*, using a public-domain Wikimedia image
- the relations that join them

{% include evidence.html kind="synthetic" note="Everything this command creates is invented for demonstration, and every name carries the suffix (OpenRiC demo). The one exception is the watercolour image, which is a public-domain upload from Wikimedia Commons." %}

Run it on your own server:

```bash
php artisan openric:seed-demo
php artisan openric:rebuild-nested-set
```

## See it running

<a href="{{ '/demo/browse/' | relative_url }}">Browse view</a> · <a href="{{ '/demo/' | relative_url }}">Graph viewer</a> · <a href="{{ '/api-explorer/' | relative_url }}">API Explorer (Swagger UI)</a> · <a href="https://capture.openric.org">Capture client</a>

## Going further

- Read the <a href="{{ '/spec/' | relative_url }}">specification</a>; <code>v{{ site.data.version.version }}</code> is current.
- Run the <a href="{{ '/conformance/' | relative_url }}">conformance probe</a> against any server to check claims.
- Open the <a href="{{ '/fixtures/' | relative_url }}">fixture pack</a> - {{ site.data.inventory.fixtures }} input/output pairs across the mapped RiC-O entity types.
- Follow the <a href="{{ '/guides/getting-started.html' | relative_url }}">15-minute getting-started guide</a> to point your own server at the same contract.

*The strongest evidence that a spec is implementable is a spec that's implemented. Everything on this page is running now, against a demonstration database that is reset every night.*
