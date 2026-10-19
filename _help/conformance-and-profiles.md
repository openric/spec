---
title: Conformance & profiles
category: Conformance & profiles
order: 1
summary: How OpenRiC conformance works - the profile model, the legacy levels, the profiles, declaring what you support, and running the conformance probe. With a sample run.
---

OpenRiC conformance is **profile-based**: a server declares which named capabilities it supports, and consumers know exactly what to expect - no all-or-nothing claim.

## Profiles, not levels

A **profile** says *which* endpoints and entities a server exposes (Core Discovery, Authority & Context, and so on); see the [profiles tree](/help/profiles-tree/). A server declares the profiles it supports, each at a profile version. Older material talks about four conformance levels, L1 to L4; they are legacy and no longer part of a claim.

## The {{ site.data.profiles | size }} profiles

{%- assign p_norm = site.data.profiles | where: "status", "normative" -%}{%- assign p_draft = site.data.profiles | where: "status", "draft" -%}
**{{ p_norm.size }} normative:** {% for p in p_norm %}[{{ p.title }}](/spec/profiles/{{ p.id }}.html){% unless forloop.last %}, {% endunless %}{% endfor %}.  
**{{ p_draft.size }} draft:** {% for p in p_draft %}[{{ p.title }}](/spec/profiles/{{ p.id }}.html){% unless forloop.last %}, {% endunless %}{% endfor %}.

Full catalogue: [/spec/profiles/](/spec/profiles/).

## Declaring what you support

A server advertises its profiles in the service description at `GET /api/ric/v1/`:

```json
{
  "name": "Example Archive Catalogue",
  "openric_conformance": {
    "spec_version": "{{ site.data.version.version }}",
    "profiles": [
      { "id": "core-discovery", "version": "0.6.0", "conformance": "full" }
    ]
  }
}
```

## Run the probe

The conformance probe is pure bash + jq - point it at any server:

```bash
BASE=https://ric.theahg.co.za/api/ric/v1 ./conformance/probe.sh
# → one PASS, FAIL or SKIP line per check, then a summary
# Scope to one profile:
BASE=https://ric.theahg.co.za/api/ric/v1 ./conformance/probe.sh --profile=core-discovery
```

It checks every documented endpoint and reports pass/fail; exit code 0 = conformant. With a `KEY=` it also exercises the write surface, so only add a key for a server whose data you may change - never the public reference service.

## SHACL

Beyond endpoints, published graphs are validated against the [SHACL shapes](/spec/). The draft [Governance profile](/spec/profiles/governance.html) makes SHACL a **merge gate**, wired into CI.

## Next

- [Build a conformant server](/help/build-a-conformant-server/)
- The [profiles tree](/help/profiles-tree/)
