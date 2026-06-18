# 2026-06-17 — openric.org site-simplification: discovery & plan

**Trigger:** Johan finds openric.org / ric.theahg.co.za "too complicated — technical and too much."
He cites Matthew Damigos' **RiC-CM Nav tool + Modelling Playground** as the model to emulate:
*plain, simple, archivist-oriented.* Goal: simpler, user/archivist-first landing, with a
clearly separated **technical section** for developers/implementers.

## How openric.org is actually composed (non-obvious — spans 3 layers)

The public site is a **composite served by one nginx vhost** (`/etc/nginx/sites-available/openric.org`):

| Path | Backed by | Repo / source |
|------|-----------|---------------|
| `location = /` and all spec pages (Spec, Guides, FAQ, Architecture, Conformance, Governance, profiles, proof, demo, api-explorer) | **Jekyll static site** | `/usr/share/nginx/openric-spec/` (`index.md`, `_layouts/default.html`) |
| `/docs` `/explorer` `/whats-new` `/ric-api` `/login` `/static` `/app` | **OpenRiC Laravel app** (proxy → 127.0.0.1:5055) | `/usr/share/nginx/OpenRiC/` |

- `ric.theahg.co.za` serves the **same Laravel app** (`/usr/share/nginx/OpenRiC/public`) — the reference API + admin explorer.
- This repo's `resources/views/welcome.blade.php` is **still the stock Laravel welcome page** — it is NOT the public landing. The real landing is `openric-spec/index.md`.

## What makes it "too much"

`openric-spec/index.md` is **327 lines / ~10 dense sections**, developer-first throughout:
`How the pieces fit together` · `Who is this for?` · `Start here — evaluate in 5 minutes`
· `Four public deployments` · `Pages on openric.org` (5 tool cards) · `Condensed roadmap` (12 phases)
· `Read next` · `Engagement` · `Licence` · `Contact`.

Top nav (`_layouts/default.html`) = 8+ items, all technical:
`Start here · Spec · Guides · FAQ · Architecture · Conformance · Governance · Discussions · GitHub`.

Language assumes JSON-LD, SHACL, OpenAPI, CORS, conformance probes, "46 endpoints", "X-API-Key".
The "Who is this for?" block already has an **Archivists** card — but it's card 3 of 4, below the fold,
and points straight at the raw `spec/`.

## The asset we already have (under-surfaced)

A **RiC-CM reference navigator already exists** at `ric.theahg.co.za/reference/ric-cm/` —
SPARQL-backed, with **declared-vs-inherited attribute/relation separation** and versioned URLs.
This is conceptually the same thing Johan admires in the Damigos Nav tool. Today it is mentioned in
**one sentence inside a card** on the landing. It should become the archivist hero. (See prior session
`2026-05-25-v0.38.1-ric-ag-and-ric-cm-nav.md`.)

## Decisions (Johan, 2026-06-17)

- **Landing shape:** two distinct doors — *archivist/user* vs *developer/implementer*.
- **Scope:** full redesign (landing + nav + audience sub-pages + surface the navigator).

## Where openric.org actually lives (corrects an earlier assumption)

openric.org is **GitHub Pages** (`server: GitHub.com`, remote `git@github.com:openric/spec.git`, `CNAME` = openric.org),
built from this `openric-spec` repo by Jekyll on push. The local nginx `openric.org.conf` (which proxies `/` to
the Laravel app on :5055) is **unused legacy** — not the live path. So landing edits = `openric-spec/` + `git push`,
and GitHub builds Jekyll (local `jekyll`/`bundle` not required). `ric.theahg.co.za` is a *separate* landing served by
the Laravel app and was **not** touched this session.

## Implemented this session (staged, not committed)

1. **`_layouts/default.html`** — nav slimmed from 8 flat technical links to human-first:
   `Explore the model` (CTA → live navigator) · `For archivists` · `For institutions` · | · `Developers` · `Spec` · `GitHub`.
   Demo banner re-pointed to the model navigator. Added `.doors/.door/.door-mini/.entity-chip` CSS. Footer links expanded.
2. **`index.md`** — replaced the 327-line dense landing with a short, warm two-door splash: hero, plain-language
   RiC/OpenRiC explanation, two big doors (archivists / developers) + a mini institutions door.
3. **`for-developers.html`** (new) — the former dense technical body (how-the-pieces-fit, deployments, pages, 12-phase roadmap, read-next, engagement, licence) moved here under a developer hero.
4. **`for-archivists.html`** (new) — plain, Damigos-style home centred on the live **RiC-CM navigator**
   (`https://ric.theahg.co.za/reference/ric-cm/`): declared-vs-inherited explained in plain terms (credits the Ionian
   `dlib-ionian-university/ric-cm-nav`), "what is RiC", entity chips, browse-real-data cards, the ISx→RiC table, going-deeper links.

**Key reuse:** the archivist experience is the **already-built** `ahg-ric-model` Laravel package
(`/reference/ric-cm/{version}/…`, SPARQL-backed, `InheritanceResolver`, explicitly modelled on the Damigos tool) —
it was live but absent from the landing/nav. The redesign surfaces it rather than building anew.

**Open follow-up:** optional nginx proxy so the navigator can live under `openric.org/explore` instead of linking
cross-domain to `ric.theahg.co.za` (`/reference` is not currently proxied on the openric.org vhost).

Rule reminder: staged only — Johan runs `bin/release` (or commit+push) to publish to GitHub Pages.
