---
layout: default
title: OpenRiC Graph Primitives
---

# OpenRiC Graph Primitives

**Version:** 0.1.0-draft
**Status:** Draft — open for comment

---

## Purpose

Defines the abstract viewing model. Viewers — whether 2D graph, 3D graph, timeline, matrix, or something not yet invented — consume these primitives and render them.

The primitives are deliberately minimal. Complex visual behaviours emerge from composition, not from baking them into the spec.

## Primitives

### `Node`
A RiC entity projected for display. Has:
- `id` — the RiC IRI
- `type` — RiC class (`Record`, `Agent`, `Place`, …)
- `label` — display string (language-tagged)
- `attributes` — optional flat key/value pairs for tooltips / side panels
- `layout_hint` (optional) — see below

### `Edge`
A typed RiC relation. Has:
- `source`, `target` — node IDs
- `predicate` — the RiC relation IRI
- `label` — human-readable
- `directed` — boolean (most RiC relations are directed)

### `Cluster`
A grouping strategy. The server may propose clusterings; the viewer may honour or ignore them.
- `id`, `label`
- `strategy` — e.g. `by-type`, `by-fonds`, `by-date-range`
- `members` — node IDs

### `Drill`
A navigation operation request. A viewer sends a drill request when a user expands or collapses a subgraph.
- `node_id`, `depth`, `direction` (`in` / `out` / `both`)

### `Layout hint`
Non-binding advice from the server. Viewers may use or discard.
- `preferred_position` (x, y, z)
- `weight` — for force-directed layouts
- `group` — for clustered layouts

## Principle

**The spec describes *what data travels*, not *what the screen looks like*.** Viewers remain free to innovate.

---

[Back to OpenRiC](../)
