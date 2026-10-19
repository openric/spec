/*
 * Copyright (C) 2026 Johan Pieterse
 * Plain Sailing Information Systems
 * Email: johan@plainsailingisystems.co.za
 *
 * This file is part of OpenRiC. Licensed under AGPL-3.0-or-later.
 *
 * /status/ - the page is built with a dated snapshot of the last published
 * probe run (_data/conformance_snapshot.json). This script replaces it with
 * the latest run and a live read of the service description. If either cannot
 * be read, the snapshot stays and the page says so.
 */
(function () {
  "use strict";

  var API = "https://ric.theahg.co.za/api/ric/v1";
  var HOLDINGS = [
    ["records", "Records"],
    ["agents", "Agents"],
    ["places", "Places"],
    ["activities", "Activities"],
    ["rules", "Rules"],
    ["instantiations", "Instantiations"]
  ];

  function el(id) { return document.getElementById(id); }

  function getJson(url) {
    return fetch(url, { headers: { Accept: "application/json" } }).then(function (r) {
      if (!r.ok) throw new Error(url + " returned " + r.status);
      return r.json();
    });
  }

  // The list endpoints do not agree on the key name (ric:total, openric:total, total).
  function totalOf(body) {
    if (!body || typeof body !== "object") return null;
    for (var key in body) {
      if (/(^|:)total$/i.test(key) && typeof body[key] === "number") return body[key];
    }
    return null;
  }

  function showService(desc) {
    var conf = desc.openric_conformance || {};
    el("svc-name").textContent = desc.name || "-";
    el("svc-version").textContent = desc.version || "-";
    el("svc-spec").textContent = conf.spec_version ? "v" + conf.spec_version : "not declared";
    el("svc-time").textContent = new Date().toISOString().replace("T", " ").slice(0, 16) + " UTC (live)";

    var declared = {};
    (conf.profiles || []).forEach(function (p) { declared[p.id] = p; });
    document.querySelectorAll("#conformance-matrix-table td[data-profile]").forEach(function (cell) {
      var p = declared[cell.getAttribute("data-profile")];
      cell.textContent = p
        ? "declared " + (p.conformance || "") + " · v" + p.version + (p.status ? " (" + p.status + ")" : "")
        : "not declared";
    });

    var specProfiles = [];
    try { specProfiles = JSON.parse(el("spec-profiles").textContent); } catch (e) { specProfiles = []; }
    var behind = (conf.profiles || []).map(function (d) {
      var sp = specProfiles.filter(function (x) { return x.id === d.id; })[0];
      return sp && sp.version !== d.version ? sp.title + " (declares v" + d.version + ", current v" + sp.version + ")" : null;
    }).filter(Boolean);
    if (el("align-spec")) el("align-spec").textContent = conf.spec_version ? "v" + conf.spec_version : "not declared";
    if (el("align-behind")) el("align-behind").textContent = behind.length ? behind.join(", ") : "none";

    el("status-note").textContent =
      "Read live from " + API + "/ just now. The service verifies against specification v" +
      (conf.spec_version || "?") + "." + testedNote;
  }

  function showHoldings() {
    var body = el("holdings").querySelector("tbody");
    return Promise.all(HOLDINGS.map(function (h) {
      return getJson(API + "/" + h[0] + "?limit=1").then(totalOf, function () { return null; });
    })).then(function (totals) {
      totals.forEach(function (n, i) {
        if (n === null) return;
        var row = document.createElement("tr");
        var name = document.createElement("td");
        var count = document.createElement("td");
        name.textContent = HOLDINGS[i][1];
        count.textContent = n.toLocaleString("en-ZA");
        row.appendChild(name);
        row.appendChild(count);
        body.appendChild(row);
      });
      if (body.children.length) el("holdings").hidden = false;
    });
  }

  // Tested column: the latest read-only probe run, published daily by the
  // Conformance workflow to the conformance-results branch.
  var RESULTS = "https://raw.githubusercontent.com/openric/spec/conformance-results/latest.json";
  var testedNote = "";
  var VERDICT = { "pass": "pass", "fail": "FAIL", "pass-with-skips": "pass, with checks skipped" };

  function showTested() {
    var cells = document.querySelectorAll("#conformance-matrix-table td[data-tested]");
    return getJson(RESULTS).then(function (run) {
      var byProfile = {};
      (run.runs || []).forEach(function (r) { if (r.profiles && r.profiles[0]) byProfile[r.profiles[0]] = r; });
      var day = (run.run_at || "").slice(0, 10);
      cells.forEach(function (cell) {
        var r = byProfile[cell.getAttribute("data-tested")];
        if (!r) { cell.textContent = "not tested"; return; }
        var c = r.counts || {};
        cell.textContent = (VERDICT[r.verdict] || r.verdict) + " · " + day +
          " (" + c.pass + " pass, " + c.fail + " fail, " + c.skip + " skipped)";
        if (r.verdict === "fail") cell.style.fontWeight = "600";
      });
      var body = el("not-passed") && el("not-passed").querySelector("tbody");
      if (body) {
        while (body.firstChild) body.removeChild(body.firstChild);
        (run.runs || []).forEach(function (r) {
          (r.results || []).forEach(function (c) {
            if (c.status === "PASS") return;
            var row = document.createElement("tr");
            [r.profiles[0], c.status, c.check, c.http].forEach(function (v, i) {
              var td = document.createElement("td");
              if (i === 1 && c.status === "FAIL") { var b = document.createElement("strong"); b.textContent = v; td.appendChild(b); }
              else td.textContent = v;
              row.appendChild(td);
            });
            body.appendChild(row);
          });
        });
        if (!body.children.length) {
          var row = document.createElement("tr"), td = document.createElement("td");
          td.colSpan = 4; td.textContent = "None in the run of " + day + ".";
          row.appendChild(td); body.appendChild(row);
        }
      }
    }, function () {
      testedNote = " The latest probe run could not be read, so the Tested column shows the snapshot.";
      el("status-note").textContent += testedNote;
    });
  }

  showTested();

  getJson(API + "/")
    .then(showService)
    .then(showHoldings)
    .catch(function () {
      el("status-note").textContent +=
        " The reference service could not be reached from your browser just now, so the service figures above are the snapshot. " +
        "Its service description is at " + API + "/.";
    });
})();
