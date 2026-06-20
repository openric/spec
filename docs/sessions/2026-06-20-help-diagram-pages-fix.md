# 2026-06-20 — OpenRiC: fix Mermaid diagram pages on the help centre (`/help/profiles-tree/`, `/help/system-map/`)

Short, focused session on the **openric-spec** repo (openric.org, GitHub Pages). Two distinct bugs on the two diagram-bearing help pages, fixed in sequence. Spec site v0.43.1 → v0.43.3.

## Architecture recap (non-obvious)

- **openric.org** is a Jekyll site built by **GitHub Pages** from `github.com:openric/spec` — `server: GitHub.com` in the response headers, **not** this host's nginx (the local `openric.org.conf` is unused legacy that has no `/help` route at all). Edits go live only on `git push`; GitHub rebuilds Jekyll. Fastly caches HTML at `cache-control: max-age=600`, so verify with a cache-busting query string (`?cb=…`) right after a deploy — GitHub Pages ignores query strings for static files but Fastly keys on the full URL.
- `bin/release patch|minor|major "msg"` is the canonical ship path: bumps `version.json`, commits **everything staged**, tags `vX.Y.Z`, pushes, and cuts a GitHub release. It does **not** auto-generate `docs/sessions/` logs (unlike Heratio's release script) — those are written by hand here.

## The two bugs

### 1. Mermaid diagram collapsed into the top-left corner (v0.43.1)
Symptom: a big empty box with the diagram shrunk into the top-left, only part of it visible. Cause: **svg-pan-zoom could not resolve a size.** Mermaid 10 emits the SVG with an inline `max-width:<N>px` and only a `viewBox`, while the page CSS left `height:auto` and the container had only `min-height`. svg-pan-zoom then stretched the `<svg>` to fill the box while the diagram itself collapsed. Fix (both pages):
- `.diagram-wrap .mermaid` → a **definite `height`** (460px profiles-tree / 420px system-map) so percentage heights resolve.
- Force the SVG to `width:100%; height:100%; max-width:none` (overriding Mermaid's inline pin) **before** init.
- Call `pz.resize(); pz.fit(); pz.center()` inside a `requestAnimationFrame` after `svgPanZoom(...)` so it fits/centres once layout has settled. Added `contain:true`.

### 2. Markdown body rendered as raw literal text below the diagram (v0.43.3)
Symptom: everything below the diagram — `# System map`, `## The profiles`, `## In words`, `**bold**`, `-` bullet lists, `[links]()` — appeared as **literal Markdown** on the live page. Cause: **the pages were `.html` files, and Jekyll/kramdown only runs the Markdown processor on `.md` files.** The diagram itself still worked because Mermaid renders client-side from `<pre class="mermaid">` regardless of file extension; only the server-side Markdown was skipped. (`_config.yml` is plain `markdown: kramdown` with **no `parse_block_html`**, so block HTML — `<style>`, `<div class="diagram-wrap">`, `<pre class="mermaid">`, `<script>` — passes through untouched.) Fix:
- `git mv help/profiles-tree.html help/profiles-tree.md` and `git mv help/system-map.html help/system-map.md`. The explicit `permalink:` in each file's front-matter keeps the URLs identical; kramdown now renders the body (`<h1 id>`, `<h2 id>`, `<ul><li>`, `<strong>`, `<a>`) while leaving the embedded HTML/diagram/script intact.

## Verification (live, cache-busted)
- profiles-tree: `<h2 id="the-profiles">`, `<li>`/`<strong>` present; mermaid + `flowchart` + `requestAnimationFrame` markers all intact (3/3).
- system-map: `<h1 id="system-map">`, `<h2 id="in-words">`, `<li>…<strong>` present; **zero** raw-markdown leakage.
- Both deployed within ~30s of push.

## Housekeeping
- A stray **v0.43.2** tag/release was created (an empty `version.json`-only bump) because the v0.43.1 fix had already been committed via the suggested command when `bin/release` was run a second time. **Deleted** the GitHub release + remote tag + local tag. The empty commit `fbf71a8` remains in linear `main` history (untagged, harmless) — not worth rewriting `main`. Clean tag line is now v0.43.0 → v0.43.1 → v0.43.3.

## Lessons / operating notes
- **Embedding Markdown in a Jekyll page requires a `.md` extension** — a `.html` file with a Markdown body silently renders the Markdown raw. Diagram/JS pages that mix `<pre class="mermaid">` + Markdown prose must be `.md`; embedded block HTML still passes through kramdown untouched.
- **Mermaid 10 + svg-pan-zoom** needs a sized container + the SVG forced to fill (`max-width:none`, explicit `width/height`) and an explicit `fit()/center()` after a `requestAnimationFrame`, or the diagram collapses into the corner.
- After any openric.org change, confirm live against `server: GitHub.com` with a `?cb=` cache-buster — editing files on this host changes nothing until pushed.

## Follow-up — v0.43.4: mobile pinch-zoom + black-box background

Two more issues surfaced when viewing on mobile:

1. **No two-finger pinch zoom on mobile.** Root cause: **svg-pan-zoom has no built-in touch support** — its docs require **Hammer.js** + a custom events handler. Added `hammerjs@2.0.8` and the library's official mobile recipe (`customEventsHandler` wiring `pinch`/`pan`/`doubletap` to `zoomAtPoint`/`panBy`/`zoomIn`), passed only when `window.Hammer` is present. Touch coexists with the default desktop mouse-wheel/drag handlers. Added `touch-action: none` on the SVG so the browser hands the gesture to the diagram instead of zooming the page.

2. **The "black box" behind the diagram.** Root cause: the global stylesheet's `pre { background: #0f172a; color: #e2e8f0 }` (code-block styling) was bleeding onto `<pre class="mermaid">`, so the neutral-theme diagram floated on dark navy. Fix: `.diagram-wrap .mermaid { background: var(--bg); color: var(--fg) }` (class selector beats the bare `pre` rule) → diagram now sits on white.

Reusable lesson: **svg-pan-zoom needs Hammer.js for any mobile pinch/pan** — it is mouse-only out of the box. And **`<pre class="mermaid">` inherits global `pre` code-block CSS** — reset its background/colour explicitly.
