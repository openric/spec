# 2026-06-21 — OpenRiC: anonymous demand-signal tracker + Ask-a-question + /stats dashboard

Spans **openric-spec** (openric.org, GitHub Pages) and the **OpenRiC** Laravel service (ric.theahg.co.za). Goal stated by Johan: "a counter/tracker of every page visited; what demos/functions were actioned — I want to know what people want to know, to pre-empt enhancements. Add a blog/questions area with email back to me." Hard constraint added mid-session: **"I don't want to harvest user data — only pre-empt enhancements."**

## Design decisions (locked with Johan)
- **First-party collector** (not third-party analytics), **anonymous aggregate only**, events: page views, wizard runs, AI-suggest, API actions, **+ help-search queries** (the clearest "what people want to know" signal). Q&A = **ask form → emailed to Johan + stored** (no public content). Insights = a **/stats dashboard** on the site.
- **No personal data harvested — structural, not promised.** Storage is a daily ROLLUP counter; there is no per-visitor row to harvest.

## Backend (OpenRiC service — `packages/ahg-ric`, staged for commit; deployed live this session)
- **Migration** `database/migrations/2026_06_21_120000_create_openric_usage_tables.php` — `openric_usage(day, event_type, label, count)` unique on `(day,event_type,label)`; `openric_question(body, contact_email?, page?, emailed, created_at)`.
- **`Support/UsageRecorder::bump($type,$label)`** — the only writer of `openric_usage`. Portable upsert-increment (try `increment()`, else `insert`, re-increment on race). Best-effort try/catch. Label normalised + 200-char capped. No IP/UA/cookie/session.
- **Controllers**: `UsageController@track` (public beacon; only allows client events `page_view|search|wizard_started|wizard_completed`, rejects server-only events 422), `AskController@ask` (honeypot `website` field + `throttle:5,1`; stores + `Mail::raw` to `OPENRIC_ASK_TO` via sendmail; never throws on mail fail), `StatsController@stats` (Bearer `OPENRIC_STATS_TOKEN`, `hash_equals`; aggregates top pages/searches/wizard/AI/API + question count for `?days=`).
- **Server-side hooks** (can't be faked by the client beacon): `WizardSuggestController` bumps `ai_suggest`(model) on success; **`Support/AuditLog::record()` bumps `api_action`(entityType)** — the single choke-point every mutation already flows through.
- **Routes** added inside the public `/api/ric/v1` group (already CORS-allowlisted, `allow-origin: *`, reflects `Authorization`): `POST /track`, `POST /ask`, `GET /stats`. **No nginx change** needed.
- **.env** (live, not committed): `OPENRIC_ASK_TO="johan@theahg.co.za"`, generated `OPENRIC_STATS_TOKEN`. Mail was already `MAIL_MAILER=sendmail` — "credentials in Heratio" turned out to be just sendmail, already mirrored.
- **Tests**: `tests/Feature/UsageTrackingTest.php` — 8 cases (rollup increment, server-only rejection, search capture, ask store+mail, honeypot, validation, stats auth+aggregation, recorder). Full Feature suite **55 passed**.

## Deployment note (the vendor-copy gotcha)
`AhgRic\` autoloads from **`vendor/ahg/ric/src` (a COPY of `packages/*`, `symlink:false`)** — editing `packages/` does nothing until re-copied. This session hand-synced `packages/ahg-ric/{src,routes}` → `vendor/ahg/ric/` so it went live immediately, ran the migration with `--path` (targeted, so the shared `heratio` DB wasn't otherwise touched), and `config:clear`. A future `composer install` re-copies idempotently.

## Site (openric-spec — shipped v0.43.5)
- `assets/js/track.js` — `window.openricTrack(event,label)`; form-encoded `sendBeacon` (no CORS preflight, reliable on unload); fires one `page_view` (path only, no query/referrer) per load. Injected site-wide via `_layouts/default.html`.
- `assets/js/help-search.js` — tracks **settled** search queries (1.2s debounce + de-dupe), not keystrokes.
- `assets/js/wizard.js` — `wizard_started` in `start()`, `wizard_completed` in `renderOutcome()`, labelled by scenario id.
- `ask.md` (`/ask/`) — contact form → `POST /api/ric/v1/ask`, honeypot, optional email. Footer link added site-wide.
- `stats.md` (`/stats/`) — token gate (localStorage), range 7/30/90, renders totals cards + top pages/searches/wizard/AI/API tables + question count. `sitemap: false`.

## Verified live
`/track` 202 + increments; bad event 422; `/stats` 401 (no token) / 200 (token) with correct aggregation; `/ask` stores + `emailed=1` (real test mail delivered) + honeypot dropped. Site: track.js + `/ask/` + `/stats/` all 200, beacon injected in pages, real page_views for `/` and `/help/` already accruing from live traffic.

## Privacy posture (for any future reviewer)
Only personal datum anywhere is the **optional, volunteered** reply-to email on the contact form. Everything else is aggregate counts with no identity. Search-query text is content-interest, not identity. `/stats` is token-gated because the (anonymous) search list is internal intelligence.

## Follow-up — CSV export + prominent scenario picker (service v0.16.1, site v0.43.6)
- **CSV download**: `GET /api/ric/v1/stats?format=csv&export=usage|questions` (Bearer-gated) streams the full usage rollup or the questions for the `?days=` window via `response()->streamDownload` + `fputcsv`. `/stats` dashboard gained ⬇ Usage CSV / ⬇ Questions CSV buttons (fetch-with-Authorization → Blob download, since `<a href>` can't carry the Bearer). Hardened the token test (override `$_SERVER` too — a real `.env` token was leaking into the test env via the ServerConst adapter); +1 CSV test (9 total).
- **Wizard**: scenario picker restyled into a prominent accent card ("📂 Choose a scenario" + "N worked examples" hint) so visitors notice they can switch scenarios.

## RiC modelling note (asked via /wizard/, answered from KM source=ric)
Q: magnetic tape with mixed-provenance tracks — Record + Record Parts? Answer: the deciding test is intellectual independence, NOT "different agents" (RiC-E05 Record Part *can* carry its own provenance). Genuinely mixed/independent provenance → each track = **Record (E04)**, grouped by **Record Set (E03)**, tape = shared **Instantiation (E06)**; per-track Agents via `has_creator`. Record + Record Parts is only right if the tape is one intellectual record with track-level subdivisions. Grounded in RiC Users group threads (instantiation-vs-record-set).

## Follow-up 2 — per-day trend chart + wizard note callout (service v0.16.2, site v0.43.7)
- **Trend chart**: `GET /stats` now returns a zero-filled `daily` array (one row/day in the window, all event counts); `/stats` renders a lightweight inline-SVG page-views-per-day bar chart (hover = full per-day breakdown), no chart library. +1 test assertion.
- **Wizard note callout**: added optional step-level `note` field to the wizard engine (`step.note` → styled amber `.wiz-note` callout between prompt and choices). Used it on the magnetic-tape `track` step to teach the Record-Part-vs-separate-Records decision: the test is intellectual independence, not "different agents" (E05 may carry its own provenance) — Record Parts for components of one tape-as-record; separate Records (E04) in a Record Set (E03) + shared Instantiation (E06) when each track is a standalone work. Scenario validator still green (18 scenarios).
