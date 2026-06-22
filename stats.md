---
layout: default
title: OpenRiC usage insights
description: Anonymous demand-signal dashboard for openric.org - top pages, popular demos, search queries, and AI/API usage. Admin only.
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

<p class="legend">Anonymous demand signals - what people view, search, and try - so enhancements can be pre-empted. No personal data is collected; these are aggregate counts only.</p>

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
    <button onclick="window.__stCsv('usage')" style="margin-left:auto" title="Download the full usage table for this range">⬇ Usage CSV</button>
    <button onclick="window.__stCsv('questions')" title="Download submitted questions for this range">⬇ Questions CSV</button>
    <button onclick="window.__stForget()">Sign out</button>
  </div>
  <div class="st-cards" id="st-cards"></div>
  <div class="st-sec" id="st-chart" style="margin:1.2rem 0"></div>
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
  window.__stCsv = function (which) {
    fetch(API + "?days=" + days + "&format=csv&export=" + which, { headers: { "Authorization": "Bearer " + token() } })
      .then(function (r) { if (!r.ok) throw new Error("status " + r.status); return r.blob(); })
      .then(function (b) {
        var u = URL.createObjectURL(b), a = document.createElement("a");
        a.href = u; a.download = "openric-" + which + "-last" + days + "d.csv";
        document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(u);
      })
      .catch(function () { alert("Download failed - please re-check your admin token."); });
  };
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

  function chart(daily) {
    if (!daily || !daily.length) return '<h3>Page views per day</h3><p class="st-muted">No data yet.</p>';
    var W = 760, H = 170, pad = 26, n = daily.length;
    var max = Math.max(1, Math.max.apply(null, daily.map(function (r) { return r.page_view; })));
    var bw = (W - pad * 2) / n;
    var bars = daily.map(function (r, i) {
      var h = Math.round((r.page_view / max) * (H - pad * 2));
      var x = pad + i * bw, y = H - pad - h;
      var tip = r.day + " - " + r.page_view + " views, " + r.search + " searches, " + (r.wizard_started || 0) + " wizard, " + r.ai_suggest + " AI, " + r.api_action + " API";
      return '<rect x="' + (x + 0.5) + '" y="' + y + '" width="' + Math.max(1, bw - 1) + '" height="' + h + '" fill="var(--accent-2)"><title>' + tip + '</title></rect>';
    }).join("");
    function lbl(i) { var x = pad + i * bw + bw / 2; return '<text x="' + x + '" y="' + (H - 7) + '" font-size="10" fill="var(--muted)" text-anchor="middle">' + daily[i].day.slice(5) + '</text>'; }
    var ticks = [lbl(0), lbl(Math.floor(n / 2)), lbl(n - 1)].join("");
    return '<h3>Page views per day <span class="st-muted" style="font-weight:400">(hover a bar for the full breakdown)</span></h3>'
      + '<svg viewBox="0 0 ' + W + ' ' + H + '" width="100%" height="' + H + '" preserveAspectRatio="none" role="img" aria-label="Page views per day">'
      + '<text x="2" y="' + (pad - 6) + '" font-size="10" fill="var(--muted)">' + max + '</text>'
      + '<line x1="' + pad + '" y1="' + (H - pad) + '" x2="' + (W - pad) + '" y2="' + (H - pad) + '" stroke="var(--border)"/>'
      + bars + ticks + '</svg>';
  }

  function render(d) {
    document.getElementById("st-since").textContent = "since " + d.since;
    document.getElementById("st-chart").innerHTML = chart(d.daily);
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
