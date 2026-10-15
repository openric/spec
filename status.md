---
layout: default
title: OpenRiC - Current status
description: What the OpenRiC specification defines and what the reference service declares, read live from the service and from the specification's own release data.
permalink: /status/
---

# Current status

This page is generated, not written. The specification figures come from the release data in the repository; the reference-service figures are read live from the service when you open the page. Nothing below is typed by hand.

## Specification

| | |
|---|---|
| Current version | **v{{ site.data.version.version }}**, released {{ site.data.version.release_date }} |
| Profiles | {{ site.data.profiles | size }} defined: {{ site.data.profiles | where: "status", "normative" | size }} normative, {{ site.data.profiles | where: "status", "draft" | size }} draft |
| JSON Schemas | {{ site.data.inventory.schemas }} |
| Conformance fixtures | {{ site.data.inventory.fixtures }} done, {{ site.data.inventory.fixtures_planned }} planned |
| Older versions | Preserved as tagged releases - see [specification versions](/spec/versions/) |

## Reference service

<p id="status-note" class="callout">Reading the service description from <code>https://ric.theahg.co.za/api/ric/v1/</code>...</p>

<table id="service-facts" hidden>
  <tbody>
    <tr><td>Service</td><td id="svc-name"></td></tr>
    <tr><td>Version it reports</td><td id="svc-version"></td></tr>
    <tr><td>Specification version it verifies against</td><td id="svc-spec"></td></tr>
    <tr><td>Read at</td><td id="svc-time"></td></tr>
  </tbody>
</table>

### Conformance matrix

Two columns per implementation, kept apart on purpose. **Declared** is what the implementation claims in its own service description. **Tested** is the result of the [conformance probe](/conformance/) run against it, with the date of the run. The probe runs daily against the reference service and is read-only: checks that would need to write are skipped, and a profile with skipped checks is never shown as a plain pass. A declaration without a test result is a claim to check, not a verified pass. You can run the probe against any server yourself.

<table id="conformance-matrix-table">
  <thead>
    <tr>
      <th>Profile</th><th>Status in the spec</th><th>Reference service: declared</th><th>Reference service: tested</th>
    </tr>
  </thead>
  <tbody>
{%- for p in site.data.profiles %}
    <tr><td><a href="/spec/profiles/{{ p.id }}.html">{{ p.title | replace: '&', '&amp;' }}</a></td><td>{{ p.status }} · v{{ p.version }}</td><td data-profile="{{ p.id }}">-</td><td data-tested="{{ p.id }}">-</td></tr>
{%- endfor %}
  </tbody>
</table>

Independent implementations will get their own column here once one publishes a service description. A second, independently built implementation is a [governance](/governance.html) condition for v1.0.

### Holdings in the reference service

These counts are read from the service's own list endpoints. Most of the data is demonstration data, not an institution's holdings.

<table id="holdings" hidden>
  <tbody></tbody>
</table>

<script src="/assets/js/status.js?v={{ site.time | date: '%s' }}"></script>
