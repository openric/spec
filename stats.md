---
layout: default
title: OpenRiC usage insights
description: Anonymous demand-signal dashboard for openric.org — top pages, popular demos, search queries, and AI/API usage. Admin only.
permalink: /stats/
sitemap: false
---

<style>
  .st-gate { max-width: 460px; }
  .st-gate input { width: 100%; padding: .6rem .7rem; border: 1px solid var(--border); border-radius: var(--radius); font: inherit; background: var(--bg); color: var(--fg); }
  .st-bar { display: flex; gap: .5rem; align-items: center; flex-wrap: wrap; margin: 1rem 0; }
  .st-bar button { padding: .4rem .9rem; border: 1px solid var(--border); border-radius: var(--radius); background: var(--surface); color: var(--fg); font: inherit; cursor: pointer; }
  .st-bar button.active { background: var(--accent); color: #fff; border-color: var(--accent); }
  .st-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: .7rem; margin: 1rem 0; }
  .st-card { border: 1px solid var(--border); border-radius: var(--radius); padding: .8rem 1rem; background: var(--surface); }
  .st-card .n { font-size: 1.6rem; font-weight: 700; color: var(--accent); }
  .st-card .k { font-size: .8rem; color: var(--muted-2); text-transform: uppercase; letter-spacing: .03em; }
  .st-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.2rem; }
  .st-tbl { width: 100%; border-collapse: collapse; font-size: .92rem; }
  .st-tbl th { text-align: left; font-size: .78rem; text-transform: uppercase; color: var(--muted-2); border-bottom: 1px solid var(--border); padding: .35rem .2rem; }
  .st-tbl td { padding: .3rem .2rem; border-bottom: 1px solid var(--surface-2); }
  .st-tbl td.c { text-align: right; font-variant-numeric: tabular-nums; color: var(--muted-2); width: 4rem; }
  .st-sec h3 { margin: .2rem 0 .4rem; font-size: 1rem; }
  .st-muted { color: var(--muted); font-size: .9rem; }
</style>

# Usage insights

<p class="legend">Anonymous demand signals — what people view, search, and try — so enhancements can be pre-empted. No personal data is collected; these are aggregate counts only.</p>

<div id="st-gate" class="st-gate" style="display:none">
  <div class="ask-field" style="margin:1rem 0">
    <label for="st-token" style="display:block;font-weight:600;margin-bottom:.35rem">Admin token</label>
    <input type="password" id="st-token" placeholder="OPENRIC_STATS_TOKEN" autocomplete="off">
  </div>
  <button class="st-bar" onclick="window.__stLoad()" style="padding:.5rem 1.1rem;border:0;border-radius:var(--radius);background:var(--accent);color:#fff;font:inherit;font-weight:600;cursor:pointer">View insights</button>
  <p class="st-muted" id="st-gate-msg"></p>
</div>

<div id="st-app" style="display:none">
  <div class="st-bar">
    <span class="st-muted">Range:</span>
    <button data-days="7">7 days</button>
    <button data-days="30" class="active">30 days</button>
    <button data-days="90">90 days</button>
    <span class="st-muted" id="st-since"></span>
    <button onclick="window.__stForget()" style="margin-left:auto">Sign out</button>
  </div>
  <div class="st-cards" id="st-cards"></div>
  <div class="st-grid" id="st-grid"></div>
</div>

<script>
(function () {
  var API = "https://ric.theahg.co.za/api/ric/v1/stats";
  var KEY = "openric_stats_token";
  var days = 30;

  var gate = document.getElementById("st-gate");
  var app = document.getElementById("st-app");
  var gmsg = document.getElementById("st-gate-msg");

  function esc(s) { return (s || "").replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function token() { return localStorage.getItem(KEY) || ""; }

  function showGate(m) { app.style.display = "none"; gate.style.display = "block"; gmsg.textContent = m || ""; }
  function showApp() { gate.style.display = "none"; app.style.display = "block"; }

  window.__stForget = function () { localStorage.removeItem(KEY); showGate(""); };
  window.__stLoad = function () {
    var t = document.getElementById("st-token").value.trim();
    if (t) localStorage.setItem(KEY, t);
    load();
  };

  function card(n, k) { return '<div class="st-card"><div class="n">' + n + '</div><div class="k">' + k + '</div></div>'; }
  function table(title, rows, head) {
    var body = (rows && rows.length)
      ? rows.map(function (r) { return '<tr><td>' + esc(r.label) + '</td><td class="c">' + r.count + '</td></tr>'; }).join("")
      : '<tr><td class="st-muted" colspan="2">No data yet.</td></tr>';
    return '<div class="st-sec"><h3>' + title + '</h3><table class="st-tbl"><thead><tr><th>' + head + '</th><th class="c">Hits</th></tr></thead><tbody>' + body + '</tbody></table></div>';
  }

  function render(d) {
    document.getElementById("st-since").textContent = "since " + d.since;
    var t = d.totals || {};
    document.getElementById("st-cards").innerHTML =
        card(t.page_view || 0, "Page views")
      + card(t.search || 0, "Searches")
      + card((t.wizard_started || 0), "Wizard runs")
      + card(t.wizard_completed || 0, "Wizard completed")
      + card(t.ai_suggest || 0, "AI suggestions")
      + card(t.api_action || 0, "API actions")
      + card(d.questions_count || 0, "Questions");
    document.getElementById("st-grid").innerHTML =
        table("Top pages", d.top_pages, "Page")
      + table("What people search for", d.top_searches, "Query")
      + table("Wizard demos started", d.wizard_started, "Scenario")
      + table("Wizard demos completed", d.wizard_completed, "Scenario")
      + table("AI-suggest models", d.ai_suggest_models, "Model")
      + table("API actions by entity", d.api_actions, "Entity");
  }

  function load() {
    if (!token()) { showGate(""); return; }
    fetch(API + "?days=" + days, { headers: { "Authorization": "Bearer " + token() } })
      .then(function (r) {
        if (r.status === 401) { localStorage.removeItem(KEY); throw new Error("Invalid or missing token."); }
        if (!r.ok) throw new Error("Server error " + r.status);
        return r.json();
      })
      .then(function (d) { showApp(); render(d); })
      .catch(function (e) { showGate(e.message || "Could not load."); });
  }

  Array.prototype.forEach.call(document.querySelectorAll(".st-bar button[data-days]"), function (b) {
    b.addEventListener("click", function () {
      days = parseInt(b.getAttribute("data-days"), 10);
      Array.prototype.forEach.call(document.querySelectorAll(".st-bar button[data-days]"), function (x) { x.classList.toggle("active", x === b); });
      load();
    });
  });

  load();
})();
</script>
