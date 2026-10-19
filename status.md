---
layout: default
title: OpenRiC - Current status
description: What the OpenRiC specification defines and what the reference service declares, read live from the service and from the specification's own release data.
permalink: /status/
---

# Current status

This page is generated, not written. The specification figures come from the release data in the repository. The reference-service figures are built into the page from the last published probe run, dated below, and your browser then replaces them with the latest run and a live read of the service. Without JavaScript you see the dated snapshot. Nothing below is typed by hand.

## Specification

| | |
|---|---|
| Current version | **v{{ site.data.version.version }}**, released {{ site.data.version.release_date }} |
| Profiles | {{ site.data.profiles | size }} defined: {{ site.data.profiles | where: "status", "normative" | size }} normative, {{ site.data.profiles | where: "status", "draft" | size }} draft |
| JSON Schemas | {{ site.data.inventory.schemas }} |
| Conformance fixtures | {{ site.data.inventory.fixtures }} done, {{ site.data.inventory.fixtures_planned }} planned |
| Older versions | Preserved as tagged releases - see [specification versions](/spec/versions/) |

## Reference service

<div class="callout" id="currency-vs-conformance">
<p><strong>Two different version numbers.</strong> The specification's current version above (v{{ site.data.version.version }}) is its latest release. The version the reference service verifies against, below, is the release it has been tested against, and it can be older. The two are released separately: a specification release that only corrects wording, fixtures or this site does not need a new service release, and the service catches up when the specification changes something it serves.</p>
<p>So a specification newer than the service's verified version is not a failure. A failing <strong>Tested</strong> result in the matrix below is. The figures built into this page come from the last daily probe run before the page was published; with JavaScript, your browser replaces them with a live read of the service.</p>
</div>

{%- assign snap = site.data.conformance_snapshot -%}
{%- assign snap_svc = snap.runs[0].service -%}
<p id="status-note" class="callout">Snapshot from the probe run of {{ snap.run_at | replace: "T", " " | replace: "Z", " UTC" }} (probe revision <code>{{ snap.probe_revision }}</code>), built into this page.</p>

<table id="service-facts">
  <tbody>
    <tr><td>Service</td><td id="svc-name">{{ snap_svc.name }}</td></tr>
    <tr><td>Version it reports</td><td id="svc-version">{{ snap_svc.version }}</td></tr>
    <tr><td>Specification version it verifies against</td><td id="svc-spec">v{{ snap_svc.spec_version }}</td></tr>
    <tr><td>Read at</td><td id="svc-time">{{ snap.run_at | replace: "T", " " | replace: "Z", " UTC" }} (snapshot)</td></tr>
  </tbody>
</table>

### Version alignment

{%- assign behind = "" -%}
{%- for d in snap_svc.declared -%}{%- assign sp = site.data.profiles | where: "id", d.id | first -%}{%- if sp and sp.version != d.version -%}{%- capture behind -%}{{ behind }}{% if behind != "" %}, {% endif %}{{ sp.title }} (declares v{{ d.version }}, current v{{ sp.version }}){%- endcapture -%}{%- endif -%}{%- endfor %}

<table id="alignment">
  <tbody>
    <tr><td>Latest specification release</td><td>v{{ site.data.version.version }}</td></tr>
    <tr><td>Release the reference service is verified against</td><td id="align-spec">v{{ snap_svc.spec_version }}</td></tr>
    <tr><td>Profiles declared at an older version than the current one</td><td id="align-behind">{% if behind == "" %}none{% else %}{{ behind }}{% endif %}</td></tr>
  </tbody>
</table>

### What a pass proves, and what it does not

A **pass** means the probe called the endpoints a profile requires and every response had the shape the profile defines: the right status codes, `@type` values, required fields, links and envelope, and a service description that declares the profile. That is all it means.

It does **not** show that the data is correct archival description, that the mapping choices are sound, that writes work (the daily run is read-only, so every write check is skipped), or that two implementations can exchange data. Those need other evidence: the [fixtures](https://github.com/openric/spec/tree/main/fixtures) for shapes, review for the mapping, and a second, independent implementation for interoperability, which does not exist yet. A passing read-only probe is a necessary step, not proof of interoperability.

### Checks that did not pass

Every failed or skipped check from the latest run, with the reason the probe gave. A profile with any of these is never shown as a plain pass.

<table id="not-passed">
  <thead><tr><th>Profile</th><th>Result</th><th>Check</th><th>Detail</th></tr></thead>
  <tbody>
{%- assign np = 0 -%}
{%- for r in snap.runs -%}{%- for c in r.results -%}{%- unless c.status == "PASS" -%}{%- assign np = np | plus: 1 %}
    <tr><td>{{ r.profiles[0] }}</td><td>{% if c.status == "FAIL" %}<strong>FAIL</strong>{% else %}{{ c.status }}{% endif %}</td><td>{{ c.check }}</td><td>{{ c.http }}</td></tr>
{%- endunless -%}{%- endfor -%}{%- endfor %}
{%- if np == 0 %}
    <tr><td colspan="4">None in the snapshot built into this page.</td></tr>
{%- endif %}
  </tbody>
</table>

### Conformance matrix

Two columns per implementation, kept apart on purpose. **Declared** is what the implementation claims in its own service description. **Tested** is the result of the [conformance probe](/conformance/) run against it, with the date of the run. The probe is scheduled to run daily against the reference service and is read-only; until a run has published its result, the Tested column says so: checks that would need to write are skipped, and a profile with skipped checks is never shown as a plain pass. A declaration without a test result is a claim to check, not a verified pass. You can run the probe against any server yourself.

<table id="conformance-matrix-table">
  <thead>
    <tr>
      <th>Profile</th><th>Status in the spec</th><th>Reference service: declared</th><th>Reference service: tested</th>
    </tr>
  </thead>
  <tbody>
{%- for p in site.data.profiles %}
{%- assign d = snap_svc.declared | where: "id", p.id | first -%}
{%- assign r = nil -%}{%- for x in snap.runs -%}{%- if x.profiles[0] == p.id -%}{%- assign r = x -%}{%- endif -%}{%- endfor -%}
    <tr><td><a href="/spec/profiles/{{ p.id }}.html">{{ p.title | replace: '&', '&amp;' }}</a></td><td>{{ p.status }} · v{{ p.version }}</td><td data-profile="{{ p.id }}">{% if d %}declared {{ d.conformance }} · v{{ d.version }}{% else %}not declared{% endif %}</td><td data-tested="{{ p.id }}">{% if r %}{% if r.verdict == "pass" %}pass{% elsif r.verdict == "fail" %}<strong>FAIL</strong>{% elsif r.verdict == "pass-with-skips" %}pass, with checks skipped{% else %}{{ r.verdict }}{% endif %} · {{ snap.run_at | slice: 0, 10 }} ({{ r.counts.pass }} pass, {{ r.counts.fail }} fail, {{ r.counts.skip }} skipped){% else %}not tested{% endif %}</td></tr>
{%- endfor %}
  </tbody>
</table>

Independent implementations will get their own column here once one publishes a service description. A second, independently built implementation is a [governance](/governance.html) condition for v1.0.

### Holdings in the reference service

These counts are read from the service's own list endpoints. Most of the data is demonstration data, not an institution's holdings.

<table id="holdings" hidden>
  <tbody></tbody>
</table>

<script id="spec-profiles" type="application/json">{{ site.data.profiles | jsonify }}</script>
<script src="/assets/js/status.js?v={{ site.time | date: '%s' }}"></script>
