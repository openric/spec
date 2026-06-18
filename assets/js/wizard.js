/*
 * OpenRiC modelling wizard — data-driven, editable, open-write, branching.
 *
 * Copyright (C) 2026 Johan Pieterse / Plain Sailing iSystems. AGPL 3.0.
 *
 * Loads a scenario JSON (assets/data/scenarios/<id>.json) and walks the user
 * through modelling decisions. Each step poses a prompt and offers entity
 * choices with a "why it fits / why it doesn't" rationale; correct choices
 * reveal the "capture" (the real API calls, every field editable) and a Next
 * button. Navigation is id-based: a choice may carry `next` (a step id) so the
 * wizard BRANCHES — multiple choices can be correct and lead to different valid
 * paths. Steps with no `capture` are pure branch decisions. Creates live
 * against the (currently open) reference server. A picker (index.json) lets the
 * library grow.
 */
(function () {
  "use strict";

  var state = { scenario: null, index: [], byId: {}, current: null, trail: [], captured: {}, nextId: null };
  var root;

  function el(tag, attrs, children) {
    var n = document.createElement(tag);
    attrs = attrs || {};
    Object.keys(attrs).forEach(function (k) {
      if (k === "class") n.className = attrs[k];
      else if (k === "html") n.innerHTML = attrs[k];
      else if (k === "text") n.textContent = attrs[k];
      else if (k.indexOf("on") === 0 && typeof attrs[k] === "function") n.addEventListener(k.slice(2), attrs[k]);
      else if (attrs[k] != null) n.setAttribute(k, attrs[k]);
    });
    (children || []).forEach(function (c) { if (c) n.appendChild(typeof c === "string" ? document.createTextNode(c) : c); });
    return n;
  }

  function isAuto(key, val) {
    return /(_id|^id)$/.test(key) || key === "relation_type"
      || (typeof val === "string" && /\{\{.*\}\}/.test(val));
  }

  function tok(v) {
    if (typeof v !== "string") return v;
    var s = v.replace(/\{\{(\w+)\.id\}\}/g, function (_, k) {
      return state.captured[k] != null ? state.captured[k] : ("{{" + k + ".id}}");
    });
    return /^\d+$/.test(s) ? parseInt(s, 10) : s;
  }

  function buildBody(call, idx) {
    if (!call.body) return null;
    var out = {};
    Object.keys(call.body).forEach(function (k) {
      var inp = document.getElementById("wiz-in-" + idx + "-" + k);
      if (inp) { var v = inp.value; out[k] = /^\d+$/.test(v) ? parseInt(v, 10) : v; }
      else { out[k] = tok(call.body[k]); }
    });
    return out;
  }

  function serverBase() {
    var v = (document.getElementById("wiz-server") || {}).value;
    return (v || state.scenario.server_default || "").replace(/\/$/, "");
  }

  // ---- navigation -------------------------------------------------------
  function stepIndex(id) { for (var i = 0; i < state.scenario.steps.length; i++) if (state.scenario.steps[i].id === id) return i; return -1; }
  function afterInArray(id) { var i = stepIndex(id); return (i >= 0 && i + 1 < state.scenario.steps.length) ? state.scenario.steps[i + 1].id : null; }
  function hasBranching() { return state.scenario.steps.some(function (s) { return (s.choices || []).some(function (c) { return c.next; }); }); }

  function goTo(id) {
    if (!id) { renderOutcome(); return; }
    state.current = id;
    state.trail.push(id);
    renderStep();
    window.scrollTo(0, 0);
  }

  // ---- chrome -----------------------------------------------------------
  function settingsPanel() {
    return el("div", { class: "wiz-settings" }, [
      el("div", { class: "wiz-settings-row" }, [
        el("label", { text: "Server" }),
        el("input", { id: "wiz-server", type: "text", value: state.scenario.server_default || "", spellcheck: "false" })
      ]),
      el("p", { class: "wiz-hint", html: "This reference server is currently <strong>open for input</strong> — no key needed. Edit any field to model your own material; the wizard creates it live. Creates only — existing records can't be edited or deleted here." })
    ]);
  }

  function scenarioPicker() {
    if (!state.index || state.index.length < 2) return null;
    var sel = el("select", { id: "wiz-pick", class: "wiz-pick", onchange: function () { location.search = "?scenario=" + this.value; } });
    state.index.forEach(function (s) {
      var o = el("option", { value: s.id }, [s.title]);
      if (s.id === state.scenario.id) o.selected = "selected";
      sel.appendChild(o);
    });
    return el("div", { class: "wiz-pick-row" }, [el("label", { text: "Scenario" }), sel]);
  }

  function progress() {
    if (hasBranching()) {
      return el("div", { class: "wiz-progress-wrap" }, [el("span", { class: "wiz-step-count", text: "Step " + state.trail.length })]);
    }
    var total = state.scenario.steps.length, at = stepIndex(state.current);
    var bar = el("div", { class: "wiz-progress" });
    for (var i = 0; i < total; i++) bar.appendChild(el("span", { class: "wiz-dot" + (i < at ? " past" : i === at ? " now" : "") }));
    return el("div", { class: "wiz-progress-wrap" }, [el("span", { class: "wiz-step-count", text: "Step " + (at + 1) + " of " + total }), bar]);
  }

  // ---- capture (editable + live create) ---------------------------------
  function editableFields(call, idx) {
    if (!call.body) return null;
    var wrap = el("div", { class: "wiz-fields" });
    Object.keys(call.body).forEach(function (k) {
      if (isAuto(k, call.body[k])) return;
      wrap.appendChild(el("label", { class: "wiz-field" }, [
        el("span", { class: "wiz-field-key", text: k }),
        el("input", { id: "wiz-in-" + idx + "-" + k, type: "text", value: String(call.body[k]),
          oninput: function () { paintBodies(state.byId[state.current]); } })
      ]));
    });
    return wrap.children.length ? wrap : null;
  }

  function preText(call, idx) { var b = buildBody(call, idx); return call.method + " " + call.path + (b ? "\n" + JSON.stringify(b, null, 2) : ""); }
  function paintBodies(step) { (step.capture || []).forEach(function (c, idx) { var pre = document.getElementById("wiz-code-" + idx); if (pre) pre.textContent = preText(c, idx); }); }

  function captureBlock(step) {
    var wrap = el("div", { class: "wiz-capture" }, [el("div", { class: "wiz-capture-head", text: "Capture — edit any field, then create it" })]);
    step.capture.forEach(function (call, idx) {
      wrap.appendChild(el("div", { class: "wiz-call" }, [
        el("p", { class: "wiz-comment", text: "// " + call.comment }),
        editableFields(call, idx),
        el("pre", { class: "wiz-code", id: "wiz-code-" + idx, text: preText(call, idx) }),
        el("div", { class: "wiz-call-result", id: "wiz-result-" + idx })
      ]));
    });
    wrap.appendChild(el("div", { class: "wiz-run-row" }, [
      el("button", { class: "wiz-btn wiz-run", onclick: function () { runCreate(step); } }, ["Create it ▶"])
    ]));
    return wrap;
  }

  function runCreate(step) {
    var base = serverBase(), calls = step.capture.slice();
    (function chain(i) {
      if (i >= calls.length) return;
      var call = calls[i], body = buildBody(call, i);
      var slot = document.getElementById("wiz-result-" + i);
      slot.className = "wiz-call-result pending"; slot.textContent = "…creating";
      fetch(base + call.path, {
        method: call.method,
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: body ? JSON.stringify(body) : null
      }).then(function (r) {
        return r.json().then(function (j) { return { ok: r.ok, status: r.status, j: j }; })
          .catch(function () { return { ok: r.ok, status: r.status, j: null }; });
      }).then(function (res) {
        if (res.ok && res.j && res.j.id != null) {
          if (call.save_as) state.captured[call.save_as] = res.j.id;
          slot.className = "wiz-call-result ok";
          slot.textContent = "✓ " + res.status + " — created id " + res.j.id + (res.j.href ? " (" + res.j.href + ")" : "");
          paintBodies(step);
          chain(i + 1);
        } else {
          slot.className = "wiz-call-result err";
          slot.textContent = "✗ " + res.status + " — " + (res.j && (res.j.detail || res.j.title || res.j.message || JSON.stringify(res.j)) || "error");
        }
      }).catch(function (e) {
        slot.className = "wiz-call-result err";
        slot.textContent = "✗ network/CORS error — " + e.message;
      });
    })(0);
  }

  // ---- step rendering ---------------------------------------------------
  function renderStep() {
    var step = state.byId[state.current];
    var why = el("div", { class: "wiz-why", id: "wiz-why" });
    var holder = el("div", { id: "wiz-after-holder" });
    var choices = el("div", { class: "wiz-choices" });
    step.choices.forEach(function (c, i) {
      choices.appendChild(el("button", { class: "wiz-choice", onclick: function () { choose(step, i, choices, why, holder); } }, [
        el("span", { class: "wiz-choice-label", text: c.label }),
        c.entity && c.entity !== "—" ? el("span", { class: "wiz-choice-id", text: c.entity }) : null
      ]));
    });
    swap(el("div", { class: "wiz-panel" }, [progress(), el("h2", { class: "wiz-prompt", text: step.prompt }), choices, why, holder]));
  }

  function choose(step, i, choices, why, holder) {
    var c = step.choices[i];
    Array.prototype.forEach.call(choices.children, function (b) { b.classList.remove("sel-ok", "sel-no"); });
    choices.children[i].classList.add(c.correct ? "sel-ok" : "sel-no");
    why.className = "wiz-why show " + (c.correct ? "fit" : "nofit");
    why.innerHTML = "";
    why.appendChild(el("strong", { text: c.label + (c.entity && c.entity !== "—" ? " (" + c.entity + ")" : "") + ": " }));
    why.appendChild(document.createTextNode(c.why));
    holder.innerHTML = "";
    if (!c.correct) return;

    // Route: choice.next → step.next → next-in-array → outcome.
    state.nextId = c.next || step.next || afterInArray(step.id) || null;
    if (step.capture && step.capture.length) holder.appendChild(captureBlock(step));
    holder.appendChild(el("div", { class: "wiz-run-row" }, [
      el("button", { class: "wiz-btn wiz-next", onclick: function () { goTo(state.nextId); } },
        [state.nextId ? "Next →" : "See the result →"])
    ]));
  }

  function renderOutcome() {
    var o = state.scenario.outcome || {};
    var links = el("div", { class: "wiz-out-links" });
    (o.links || []).forEach(function (l) { links.appendChild(el("a", { class: "wiz-out-link", href: l.href }, [l.label + " →"])); });
    var built = Object.keys(state.captured).length
      ? el("p", { class: "wiz-built", text: "Created live: " + Object.keys(state.captured).map(function (k) { return k + " #" + state.captured[k]; }).join(" · ") })
      : null;
    swap(el("div", { class: "wiz-panel wiz-outcome" }, [
      el("div", { class: "wiz-verdict", text: o.verdict || "Done." }),
      o.summary ? el("p", { text: o.summary }) : null,
      built, links,
      el("button", { class: "wiz-btn", onclick: restart }, ["↺ Start over"])
    ]));
  }

  function swap(node) { var h = document.getElementById("wiz-stage"); h.innerHTML = ""; h.appendChild(node); }

  function restart() { state.captured = {}; state.trail = []; goTo(state.scenario.steps[0].id); }
  function start() { swap(el("div", {}, [])); state.trail = []; goTo(state.scenario.steps[0].id); }

  function boot() {
    root = document.getElementById("wizard");
    if (!root) return;
    var id = (new URLSearchParams(location.search)).get("scenario") || root.getAttribute("data-scenario") || "magnetic-tape";
    fetch("/assets/data/scenarios/index.json")
      .then(function (r) { return r.ok ? r.json() : []; }).catch(function () { return []; })
      .then(function (idx) {
        state.index = idx || [];
        return fetch("/assets/data/scenarios/" + id + ".json").then(function (r) { return r.json(); });
      })
      .then(function (data) {
        state.scenario = data;
        state.byId = {};
        data.steps.forEach(function (s) { state.byId[s.id] = s; });
        root.querySelector("#wiz-title").textContent = data.title;
        root.querySelector("#wiz-intro").textContent = data.intro;
        root.querySelector("#wiz-intro-q").textContent = data.question;
        var sh = root.querySelector("#wiz-settings-holder");
        var pick = scenarioPicker(); if (pick) sh.appendChild(pick);
        sh.appendChild(settingsPanel());
        root.querySelector("#wiz-start").addEventListener("click", start);
      })
      .catch(function (e) { root.querySelector("#wiz-stage").textContent = "Could not load scenario: " + e.message; });
  }

  if (document.readyState !== "loading") boot(); else document.addEventListener("DOMContentLoaded", boot);
})();
