---
layout: default
title: Search
description: One search across the OpenRiC help, guides, specification, model pages and project documentation.
permalink: /search/
---

<style>
  .site-search-page { max-width: 760px; margin: 0 auto; }
  #help-search-q { width: 100%; padding: .85rem 1.1rem; font: inherit; font-size: 1.08rem; border: 1px solid var(--border); border-radius: 10px; box-sizing: border-box; margin-bottom: .6rem; }
  #help-search-q:focus { outline: none; border-color: var(--accent-2); box-shadow: 0 0 0 3px rgba(31,95,168,.15); }
  .search-kinds { display: flex; flex-wrap: wrap; gap: .4rem .9rem; font-size: .82rem; color: var(--muted); margin: 0 0 1.4rem; }
  .search-kinds strong { color: var(--muted-2); font-weight: 600; }
  a.help-sr { display: block; padding: .8rem 1rem; border: 1px solid var(--border); border-radius: 9px; margin-bottom: .7rem; color: var(--fg); }
  a.help-sr:hover { border-color: var(--accent-2); text-decoration: none; box-shadow: var(--shadow); }
  .help-sr .r-cat { font-size: .72rem; text-transform: uppercase; letter-spacing: .05em; color: var(--accent-2); }
  .help-sr .r-title { font-weight: 600; font-size: 1.05rem; }
  .help-sr .r-sum { color: var(--muted-2); font-size: .92rem; }
  .site-search-page .muted { color: var(--muted); }
</style>

<div class="site-search-page">
  <h1>Search</h1>
  <p class="muted">One index across the help centre, the guides, the specification, the model pages and the project documentation. Runs entirely in your browser.</p>

  <input type="search" id="help-search-q" placeholder="Search OpenRiC…" autocomplete="off" aria-label="Search OpenRiC" autofocus>

  <p class="search-kinds">
    <span><strong>Guide</strong> how-tos and help articles</span>
    <span><strong>Spec</strong> the normative documents and profiles</span>
    <span><strong>Model</strong> RiC itself, the baseline and vocabularies</span>
    <span><strong>About</strong> governance, institutions, related work</span>
  </p>

  <div id="help-search-results"></div>
</div>

<script src="{{ '/assets/js/lunr.min.js' | relative_url }}"></script>
<script>window.HELP_INDEX_URL = "{{ '/help/search-index.json' | relative_url }}"; window.HELP_SEARCH_URL = "{{ '/search/' | relative_url }}";</script>
<script src="{{ '/assets/js/help-search.js' | relative_url }}"></script>
