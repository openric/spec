# 2026-06-18 — OpenRiC: archivist-first site, modelling wizard, open-write, validation & AI generator

Large multi-part session spanning the **openric-spec** (openric.org, GitHub Pages) and **OpenRiC** (ric.theahg.co.za, Laravel reference API) repos. Built on the 2026-06-17 site-simplification work (see `2026-06-17-site-simplification-findings.md`).

## Architecture recap (non-obvious)

- **openric.org** = a Jekyll site built from `openric-spec/` by **GitHub Pages** (`server: GitHub.com`, remote `github.com:openric/spec`, `CNAME`). Edits go live on `git push`; GitHub builds Jekyll. The local nginx `openric.org.conf` is unused legacy. `docs/` is excluded from the Jekyll build (internal logs/outreach) — a URL-encoded `{%` in a session log had been failing every Pages build since 2026-05-25 and silently blocking deploys; fixed by `exclude: [docs]` in `_config.yml`. GitHub Pages sets `cache-control: max-age=600` on HTML/JSON, so a hard-refresh is needed right after a deploy (wizard.js is now cache-busted via `?v={{ site.time }}`).
- **ric.theahg.co.za** = the OpenRiC Laravel service. **`vendor/` is a COPY of `packages/*`** (composer path repo, `"symlink": false`, vendor gitignored). Editing `packages/ahg-ric/...` does NOT affect the running app until `composer install` re-copies — during this session the prod `vendor/ahg/{ric,api}/...` was hand-synced so changes went live immediately, with `packages/` committed so a future install matches.

## What shipped

### Site (openric-spec)
- Archivist-first **two-door landing** (`index.md`), `for-archivists.html`, `for-developers.html`, slimmed nav — surfacing the existing RiC-CM navigator (`ric.theahg.co.za/reference/ric-cm/`, modelled on Damigos' Ionian RiC-CM Nav). Shipped earlier as site v0.39.0; "targets RiC-CM 1.0 / RiC-O 1.1" label added.

### Modelling wizard — `/wizard/` (data-driven, branching, editable, live-create)
- Engine `assets/js/wizard.js` + `wizard/index.html` + scenarios in `assets/data/scenarios/*.json` (+ `index.json` for the picker). Each step: prompt → entity choices with **why-it-fits/why-not** → **capture** (real API calls, every field editable) → live create. **id-based navigation supports branching** (a choice's `next` routes to a step; multiple correct paths; capture-less branch steps). Cache-busted + resilient loader (r.ok, retries).
- **15 scenarios**: magnetic-tape, linguistic-fieldwork, correspondence, photographs, cartographic, born-digital-email, oral-history, registers-volumes, organisational-records, audiovisual-film, web-archive, legal-case-file, architectural-drawings, scientific-dataset, records-and-mandates. Cover Record/Record Set/Record Part/Agent/Activity/Place/Instantiation/**Rule** and relations has_creator/has_instantiation/has_or_had_location/has_or_had_subject/results_from/performed_by/is_regulated_by.

### Reference API write support (OpenRiC service)
- **v0.11.0** — `POST /record-parts` + `/record-sets` (typed). Record/Record Set/Record Part are all `information_object` rows discriminated by `level_of_description` name (item→Record, **part→RecordPart** via existing term 299, aggregation→RecordSet); part/whole = `parent_id`. **Fixed a latent serializer bug**: the detail serializer joined `term_i18n` without a culture filter, picking an arbitrary culture's level name and defaulting every detail record to `rico:Record`; now culture-filtered to `en`.

### Open-write window (temporary "free for all to use")
- **v0.12.0** — `ApiAuthenticate` honours **`OPENRIC_OPEN_WRITE=true`** (.env): unauthenticated **POST** gets read+write scope. POST-only (no anon PUT/PATCH/DELETE).
- **v0.13.0 hardening** — endpoint **allowlist** (entity creation only; `/import` + `/upload` re-locked), payload cap (`OPENRIC_OPEN_WRITE_MAX_BYTES` 64KB→413), per-IP daily cap (`OPENRIC_OPEN_WRITE_MAX_PER_DAY` 100→429), minimal scope, **inventory table `openric_open_write`**, and **`php artisan openric:purge-open-write [--older-than=N] [--dry-run]`** for one-command teardown.
- **v0.14.0 sandbox isolation** — `AhgRic\Support\OpenWriteFilter::hide($q,'<alias>.id')` excludes inventoried open-write entities from public lists, `/autocomplete`, and OAI `ListRecords`/`ListIdentifiers` (one global `object` id space → single id exclusion). Detail/by-id reads stay unfiltered so the wizard still shows what it created. Gated by `OPENRIC_HIDE_OPEN_WRITE` (default true). Conformance probe stayed 30/0.
- **To close it all**: `OPENRIC_OPEN_WRITE=false` (+ `config:clear`). Caveat: data still physically in the `heratio` DB; a separate sandbox DB + scoped self-service keys is the deeper V2 step.

### Validation
- `openric-spec/bin/validate-scenarios.mjs` + a CI job (`.github/workflows/ci.yml`). Checks structure, branch refs, relation codes, and **entity-code↔label consistency** — self-tested to catch the "Place = E08" class. **RiC-CM 1.0 codes** (corrected mid-session): Record E04, Record Set E03, Record Part E05, Instantiation E06, Agent E07, **Activity E15**, Rule E16, Mandate E17, **Place E22** (E08=Person, E13=Mechanism; earlier scenarios wrongly used E08/E13).

### AI generator — `POST /api/ric/v1/wizard/suggest` (`WizardSuggestController`, v0.15.0/0.15.1)
- "Describe your material" → **gateway-proxied** LLM → returns a wizard scenario → **validated against RiC-CM 1.0 + relation vocab + allowed endpoints before display** (invalid rejected; dangling `next` refs sanitised; creates nothing). Public, `throttle:10,1`, input-capped.
- **Gateway contract** (from ai-demo `/usr/share/nginx/ai-demo/.env.local` + Heratio ahg-ai-services): OpenAI-compatible **Ollama passthrough** `OPENRIC_AI_URL=https://ai.theahg.co.za/ai/v1/ollama/v1/chat/completions`, `OPENRIC_AI_MODEL=qwen3:8b`, Bearer key (reused ai-demo's `GATEWAY_API_KEY ahg_live_…`; mint a dedicated OpenRiC key later). Payload `{model, messages:[system,user]}`; `/no_think` + strip `<think>`. **Enabled + verified live** (~26–40s/call): "baptism register", "ship logbook", "glass-plate negatives", "WWII posters" all produced valid models. Front-end has a live "Generating… Ns" progress hint. `.env` key is server-only (never committed). Inert (503) if `OPENRIC_AI_*` unset.

## Operating notes
- Enable AI: set `OPENRIC_AI_URL/KEY/MODEL` in OpenRiC `.env` + `config:clear`. Disable: unset.
- Close open-write: `OPENRIC_OPEN_WRITE=false` + `config:clear`; purge created entities: `php artisan openric:purge-open-write`.
- Re-probe after any serializer/controller/route change: `BASE=https://ric.theahg.co.za/api/ric/v1 openric-spec/conformance/probe.sh`.
- Service versions this session: v0.11.0 → v0.15.1. Site: v0.39.x → v0.42.8.
