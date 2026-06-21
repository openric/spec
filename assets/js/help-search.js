/*
 * OpenRiC help search — client-side, lunr-powered.
 * Copyright (C) 2026 Johan Pieterse / Plain Sailing iSystems. AGPL 3.0.
 *
 * Powers both the instant dropdown on the help home (#help-q / #help-results)
 * and the full search page (#help-search-q / #help-search-results). Loads the
 * Jekyll-built search-index.json once, builds a lunr index, and runs
 * prefix-expanded queries entirely in the browser — no backend.
 */
(function () {
  var idx = null, docs = [];

  // Anonymous demand signal: log a SETTLED search query (debounced + de-duped),
  // never per keystroke. This is the clearest "what people want to know" signal.
  var lastTracked = "", trackTimer = null;
  function trackSearch(v) {
    v = (v || "").trim().toLowerCase();
    if (v.length < 2) return;
    clearTimeout(trackTimer);
    trackTimer = setTimeout(function () {
      if (v === lastTracked) return;
      lastTracked = v;
      if (window.openricTrack) window.openricTrack("search", v);
    }, 1200);
  }

  function esc(s) { return (s || "").replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }

  function load(cb) {
    if (idx) { cb(); return; }
    fetch(window.HELP_INDEX_URL).then(function (r) { return r.json(); }).then(function (data) {
      docs = data;
      idx = lunr(function () {
        this.ref("id");
        this.field("title", { boost: 8 });
        this.field("category", { boost: 3 });
        this.field("summary", { boost: 4 });
        this.field("body");
        data.forEach(function (d) { this.add(d); }, this);
      });
      cb();
    }).catch(function () { cb(); });
  }

  function run(q) {
    if (!idx || !q || q.trim().length < 2) return [];
    var terms = q.trim().split(/\s+/);
    var expanded = terms.map(function (t) { return t + " " + t + "*"; }).join(" ");
    var res;
    try { res = idx.search(expanded); } catch (e) { try { res = idx.search(q); } catch (e2) { res = []; } }
    return res.slice(0, 8).map(function (r) { return docs[parseInt(r.ref, 10)]; }).filter(Boolean);
  }

  function card(d, cls) {
    return '<a class="' + cls + '" href="' + d.url + '"><span class="r-cat">' + esc(d.category) + '</span>'
      + '<div class="r-title">' + esc(d.title) + '</div>'
      + '<div class="r-sum">' + esc(d.summary || "") + '</div></a>';
  }

  // ---- Home instant dropdown ----
  var q = document.getElementById("help-q"), box = document.getElementById("help-results");
  if (q && box) {
    var sel = -1, cur = [];
    function render(items) {
      cur = items; sel = -1;
      box.innerHTML = items.length
        ? items.map(function (d) { return card(d, ""); }).join("")
        : '<div class="r-none">No matches. Try fewer or different words.</div>';
      box.style.display = "block";
    }
    q.addEventListener("input", function () {
      var v = q.value.trim();
      if (v.length < 2) { box.style.display = "none"; return; }
      load(function () { render(run(v)); });
      trackSearch(v);
    });
    q.addEventListener("keydown", function (e) {
      var a = box.querySelectorAll("a");
      if (e.key === "Enter") {
        if (sel >= 0 && cur[sel]) location.href = cur[sel].url;
        else location.href = window.HELP_SEARCH_URL + "?q=" + encodeURIComponent(q.value);
        return;
      }
      if (!a.length) return;
      if (e.key === "ArrowDown") { e.preventDefault(); sel = Math.min(sel + 1, a.length - 1); }
      else if (e.key === "ArrowUp") { e.preventDefault(); sel = Math.max(sel - 1, 0); }
      else return;
      a.forEach(function (el, i) { el.classList.toggle("sel", i === sel); });
    });
    document.addEventListener("click", function (e) { if (!box.contains(e.target) && e.target !== q) box.style.display = "none"; });
  }

  // ---- Full search page ----
  var page = document.getElementById("help-search-results");
  if (page) {
    var pq = document.getElementById("help-search-q");
    var init = (new URLSearchParams(location.search)).get("q") || "";
    function doPage(v) {
      load(function () {
        if (!v) { page.innerHTML = ""; return; }
        trackSearch(v);
        var items = run(v);
        page.innerHTML = items.length
          ? '<p class="muted">' + items.length + " result" + (items.length > 1 ? "s" : "") + ' for &ldquo;' + esc(v) + '&rdquo;</p>' + items.map(function (d) { return card(d, "help-sr"); }).join("")
          : '<p class="muted">No matches for &ldquo;' + esc(v) + '&rdquo;. Try fewer or different words.</p>';
      });
    }
    if (pq) { pq.value = init; pq.addEventListener("input", function () { doPage(pq.value.trim()); }); }
    doPage(init.trim());
  }
})();
