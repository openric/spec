/*
 * OpenRiC modelling wizard — data-driven guided RiC modelling.
 *
 * Copyright (C) 2026 Johan Pieterse / Plain Sailing iSystems.
 * Licensed under the GNU AGPL 3.0.
 *
 * Loads a scenario JSON (assets/data/scenarios/<id>.json) and walks the user
 * through modelling decisions: each step poses a prompt, offers entity choices,
 * explains why each fits or doesn't, and shows the "capture" — the real API
 * call(s) it produces. With a server URL + API key it runs them live against a
 * conformant OpenRiC server and threads the returned ids into later steps.
 */
(function () {
  "use strict";

  var state = { scenario: null, step: 0, captured: {}, done: {}, dummy: 9000, anyLive: false };
  var root;

  function el(tag, attrs, children) {
    var n = document.createElement(tag);
    attrs = attrs || {};
    Object.keys(attrs).forEach(function (k) {
      if (k === "class") n.className = attrs[k];
      else if (k === "html") n.innerHTML = attrs[k];
      else if (k === "text") n.textContent = attrs[k];
      else if (k.indexOf("on") === 0 && typeof attrs[k] === "function") n.addEventListener(k.slice(2), attrs[k]);
      else n.setAttribute(k, attrs[k]);
    });
    (children || []).forEach(function (c) { if (c) n.appendChild(typeof c === "string" ? document.createTextNode(c) : c); });
    return n;
  }

  // Replace {{key.id}} tokens in a body using captured ids.
  function fill(body) {
    var out = Array.isArray(body) ? [] : {};
    Object.keys(body).forEach(function (k) {
      var v = body[k];
      if (typeof v === "string") {
        v = v.replace(/\{\{(\w+)\.id\}\}/g, function (_, key) {
          return state.captured[key] != null ? state.captured[key] : ("{{" + key + ".id}}");
        });
        out[k] = /^\d+$/.test(v) ? parseInt(v, 10) : v;
      } else { out[k] = v; }
    });
    return out;
  }

  function serverBase() {
    var v = (document.getElementById("wiz-server") || {}).value;
    return (v || state.scenario.server_default || "").replace(/\/$/, "");
  }
  function apiKey() { return ((document.getElementById("wiz-key") || {}).value || "").trim(); }

  function settingsPanel() {
    return el("div", { class: "wiz-settings" }, [
      el("div", { class: "wiz-settings-row" }, [
        el("label", { text: "Server" }),
        el("input", { id: "wiz-server", type: "text", value: state.scenario.server_default || "", spellcheck: "false" })
      ]),
      el("div", { class: "wiz-settings-row" }, [
        el("label", { text: "API key" }),
        el("input", { id: "wiz-key", type: "password", placeholder: "write-scoped key — leave blank to preview calls only", spellcheck: "false" })
      ]),
      el("p", { class: "wiz-hint", html: "<strong>Leave both blank to simulate</strong> — the wizard generates placeholder ids and threads them through, so you can walk the whole flow without sending anything. Add a write-scoped key to create the entities for real against the server. Need a key? <a href='https://ric.theahg.co.za/api/ric/v1/keys/request'>Request one</a>." })
    ]);
  }

  function progress() {
    var total = state.scenario.steps.length;
    var bar = el("div", { class: "wiz-progress" });
    for (var i = 0; i < total; i++) {
      bar.appendChild(el("span", { class: "wiz-dot" + (i < state.step ? " past" : i === state.step ? " now" : "") }));
    }
    return el("div", { class: "wiz-progress-wrap" }, [
      el("span", { class: "wiz-step-count", text: "Step " + (state.step + 1) + " of " + total }), bar
    ]);
  }

  function captureBlock(step) {
    var wrap = el("div", { class: "wiz-capture" }, [ el("div", { class: "wiz-capture-head", text: "Capture" }) ]);
    step.capture.forEach(function (call, idx) {
      var body = call.body ? fill(call.body) : null;
      wrap.appendChild(el("div", { class: "wiz-call" }, [
        el("p", { class: "wiz-comment", text: "// " + call.comment }),
        el("pre", { class: "wiz-code", id: "wiz-code-" + idx, text: call.method + " " + call.path + (body ? "\n" + JSON.stringify(body, null, 2) : "") }),
        el("div", { class: "wiz-call-result", id: "wiz-result-" + idx })
      ]));
    });
    var key = apiKey();
    wrap.appendChild(el("div", { class: "wiz-run-row" }, [
      el("button", { class: "wiz-btn wiz-run", onclick: function () { runLive(step); } },
        [key ? "Run live ▶" : "Simulate ▶"]),
      el("button", { class: "wiz-btn wiz-next", onclick: next }, [state.step + 1 < state.scenario.steps.length ? "Next →" : "See the result →"])
    ]));
    return wrap;
  }

  // Re-render the displayed call bodies of the current step so freshly
  // captured ids (live or simulated) replace their {{key.id}} placeholders.
  function paintBodies(step) {
    step.capture.forEach(function (c, idx) {
      var pre = document.getElementById("wiz-code-" + idx);
      if (!pre) return;
      var b = c.body ? fill(c.body) : null;
      pre.textContent = c.method + " " + c.path + (b ? "\n" + JSON.stringify(b, null, 2) : "");
    });
  }

  function runLive(step) {
    var base = serverBase(), key = apiKey(), simulate = !key;
    var calls = step.capture.slice();
    (function chain(i) {
      if (i >= calls.length) return;
      var call = calls[i], body = call.body ? fill(call.body) : null;
      var slot = document.getElementById("wiz-result-" + i);
      if (simulate) {
        var simId = ++state.dummy;
        if (call.save_as) state.captured[call.save_as] = simId;
        slot.className = "wiz-call-result sim";
        slot.textContent = "↪ simulated — would create id " + simId + " · nothing was sent (add a key above to run it for real)";
        paintBodies(step);
        chain(i + 1);
        return;
      }
      slot.className = "wiz-call-result pending"; slot.textContent = "…sending";
      fetch(base + call.path, {
        method: call.method,
        headers: { "Content-Type": "application/json", "X-API-Key": key },
        body: body ? JSON.stringify(body) : null
      }).then(function (r) { return r.json().then(function (j) { return { ok: r.ok, status: r.status, j: j }; }); })
        .then(function (res) {
          if (res.ok && res.j && (res.j.id != null)) {
            state.anyLive = true;
            if (call.save_as) state.captured[call.save_as] = res.j.id;
            slot.className = "wiz-call-result ok";
            slot.textContent = "✓ " + res.status + " — created id " + res.j.id + (res.j.href ? " (" + res.j.href + ")" : "");
            paintBodies(step);
            chain(i + 1);
          } else {
            slot.className = "wiz-call-result err";
            slot.textContent = "✗ " + res.status + " — " + (res.j && (res.j.detail || res.j.title || JSON.stringify(res.j)) || "error");
          }
        }).catch(function (e) {
          slot.className = "wiz-call-result err";
          slot.textContent = "✗ network/CORS error — " + e.message;
        });
    })(0);
  }

  function flash(msg) {
    var f = document.getElementById("wiz-flash");
    if (f) { f.textContent = msg; f.className = "wiz-flash show"; setTimeout(function () { f.className = "wiz-flash"; }, 4000); }
  }

  function renderStep() {
    var step = state.scenario.steps[state.step];
    var why = el("div", { class: "wiz-why", id: "wiz-why" });
    var captureHolder = el("div", { id: "wiz-capture-holder" });

    var choices = el("div", { class: "wiz-choices" });
    step.choices.forEach(function (c, i) {
      choices.appendChild(el("button", {
        class: "wiz-choice", "data-i": i,
        onclick: function () { choose(step, i, choices, why, captureHolder); }
      }, [
        el("span", { class: "wiz-choice-label", text: c.label }),
        c.entity && c.entity !== "—" ? el("span", { class: "wiz-choice-id", text: c.entity }) : null
      ]));
    });

    var panel = el("div", { class: "wiz-panel" }, [
      progress(),
      el("h2", { class: "wiz-prompt", text: step.prompt }),
      choices, why, captureHolder
    ]);
    swap(panel);
  }

  function choose(step, i, choices, why, captureHolder) {
    var c = step.choices[i];
    Array.prototype.forEach.call(choices.children, function (b) { b.classList.remove("sel-ok", "sel-no"); });
    choices.children[i].classList.add(c.correct ? "sel-ok" : "sel-no");
    why.className = "wiz-why show " + (c.correct ? "fit" : "nofit");
    why.innerHTML = "";
    why.appendChild(el("strong", { text: c.label + (c.entity && c.entity !== "—" ? " (" + c.entity + ")" : "") + ": " }));
    why.appendChild(document.createTextNode(c.why));
    captureHolder.innerHTML = "";
    if (c.correct) { state.done[step.id] = c.label; captureHolder.appendChild(captureBlock(step)); }
  }

  function next() {
    if (state.step + 1 < state.scenario.steps.length) { state.step++; renderStep(); window.scrollTo(0, 0); }
    else renderOutcome();
  }

  function renderOutcome() {
    var o = state.scenario.outcome;
    var links = el("div", { class: "wiz-out-links" });
    (o.links || []).forEach(function (l) { links.appendChild(el("a", { class: "wiz-out-link", href: l.href }, [l.label + " →"])); });
    var built = Object.keys(state.captured).length
      ? el("p", { class: "wiz-built", text: (state.anyLive ? "Built live: " : "Assembled (simulated — nothing was created): ") + Object.keys(state.captured).map(function (k) { return k + " #" + state.captured[k]; }).join(" · ") })
      : null;
    swap(el("div", { class: "wiz-panel wiz-outcome" }, [
      el("div", { class: "wiz-verdict", text: o.verdict }),
      el("p", { text: o.summary }),
      built,
      links,
      el("button", { class: "wiz-btn", onclick: function () { state.step = 0; state.captured = {}; state.dummy = 9000; state.anyLive = false; renderStep(); window.scrollTo(0, 0); } }, ["↺ Start over"])
    ]));
  }

  function swap(node) {
    var holder = document.getElementById("wiz-stage");
    holder.innerHTML = ""; holder.appendChild(node);
  }

  function start() {
    swap(el("div", {}, []));
    root.querySelector("#wiz-intro-q").textContent = state.scenario.question;
    renderStep();
  }

  function boot() {
    root = document.getElementById("wizard");
    if (!root) return;
    var id = (new URLSearchParams(location.search)).get("scenario") || root.getAttribute("data-scenario") || "magnetic-tape";
    fetch("/assets/data/scenarios/" + id + ".json").then(function (r) { return r.json(); }).then(function (data) {
      state.scenario = data;
      root.querySelector("#wiz-title").textContent = data.title;
      root.querySelector("#wiz-intro").textContent = data.intro;
      root.querySelector("#wiz-intro-q").textContent = data.question;
      root.querySelector("#wiz-settings-holder").appendChild(settingsPanel());
      root.querySelector("#wiz-start").addEventListener("click", start);
    }).catch(function (e) {
      root.querySelector("#wiz-stage").textContent = "Could not load scenario: " + e.message;
    });
  }

  if (document.readyState !== "loading") boot(); else document.addEventListener("DOMContentLoaded", boot);
})();
