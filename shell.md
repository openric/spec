---
layout: default
title: The shared shell
description: How the four OpenRiC surfaces share one header, one set of design tokens and one canonical palette of RiC entity colours without becoming one deployment.
permalink: /shell.html
---

# The shared shell

OpenRiC is four independently deployed surfaces:

| Surface | Product label | Deployed from |
|---|---|---|
| openric.org | Explore | `openric/spec`, GitHub Pages |
| ric.theahg.co.za | Model Reference, API | Laravel, self-hosted |
| viewer.openric.org | Graph Explorer | `openric/viewer`, GitHub Pages |
| capture.openric.org | Editor | `openric/capture`, GitHub Pages |

That modularity is one of the project's strongest technical claims - it is the evidence that OpenRiC is a contract rather than a product, and it is not being given up to make the website tidier. But a visitor should not have to reason about it, and until v1 each surface had its own header, its own type stack and its own idea of what colour a Place is.

The shell is the one place those decisions live.

## Using it

Two lines in `<head>`, and delete the page's own branding header:

```html
<link rel="stylesheet" href="https://openric.org/assets/shell/v1.css">
<script defer src="https://openric.org/assets/shell/v1.js"
        data-product="Graph Explorer"></script>
```

| Attribute | Purpose |
|---|---|
| `data-product` | The label beside the logo - what tells a visitor which surface they are on. One of Explore, Model Reference, Graph Explorer, Editor, API. |
| `data-theme` | `dark` for a dark app surface. A white strip above a dark application reads as a rendering fault rather than as chrome. |
| `data-footer` | `false` on a full-bleed app surface where a footer would be in the way. |

Keep whatever controls belong to that surface. The shell replaces branding and the route back to openric.org; it does not replace a toolbar.

## What it guarantees

- One logo, one type stack, one set of colour tokens.
- A product label, so the four are distinguishable at a glance.
- One consistent route back, on every surface.
- Consistent status badges: `live`, `draft`, `normative`, `experimental`, `write`.
- **Consistent entity colours.** A Place is the same colour in the navigator, the graph, Browse and the editor.

## Why it is not sticky

Three of the four surfaces are app-like and already stick something of their own - Browse pins its type tabs to the top of the viewport. A sticky shell above them would either overlap or require every consumer to know the shell's height. A static strip works in every layout without the consumer knowing anything about it.

## Degradation

Every consuming page keeps its own base styling, and the shell is loaded with `defer`. If openric.org is unreachable, a surface loses the shared chrome and keeps working. Nothing in the shell is required for a page to function, and no page should route anything that matters through it.

## The entity colours

The canonical set lives in `v1.css` as custom properties - `--ric-record`, `--ric-place`, `--ric-activity` and so on. Anything colouring a RiC entity should read those rather than restate a hex.

The values are the viewer's `src/colours.js`, which was the most considered of the three sets that existed. This matters because before v1 the Browse demo carried a *different* palette under a comment claiming it matched the viewer. It did not: Record was `#3b82f6` against the viewer's `#45b7d1`, Activity `#ef4444` against `#6f42c1`. A comment asserting consistency is not consistency, which is precisely why there is now one file.

## Changing it

Treat any edit to `v1.css` or `v1.js` as a change to four live sites, because it is. Breaking changes get a `v2` alongside rather than an edit in place, so a surface can adopt on its own schedule - which is the whole point of keeping them independently deployed.
