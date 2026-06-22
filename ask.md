---
layout: default
title: Ask a question
description: Ask the OpenRiC maintainers a question - about the spec, the reference API, conformance, or modelling. Your question is emailed straight to us.
permalink: /ask/
---

<style>
  .ask-wrap { max-width: 640px; }
  .ask-field { margin: 1rem 0; }
  .ask-field label { display: block; font-weight: 600; margin-bottom: .35rem; }
  .ask-field textarea, .ask-field input[type="email"] {
    width: 100%; padding: .7rem .8rem; border: 1px solid var(--border); border-radius: var(--radius);
    background: var(--bg); color: var(--fg); font: inherit; font-size: .95rem;
  }
  .ask-field textarea { min-height: 150px; resize: vertical; }
  .ask-hp { position: absolute; left: -5000px; } /* honeypot, off-screen */
  .ask-btn { padding: .6rem 1.3rem; border: 0; border-radius: var(--radius); background: var(--accent); color: #fff; font: inherit; font-weight: 600; cursor: pointer; }
  .ask-btn[disabled] { opacity: .6; cursor: default; }
  .ask-note { font-size: .85rem; color: var(--muted); }
  .ask-msg { margin-top: 1rem; padding: .8rem 1rem; border-radius: var(--radius); display: none; }
  .ask-msg.ok { display: block; background: #eafaf1; color: #065f46; border: 1px solid #10b981; }
  .ask-msg.err { display: block; background: #fef2f2; color: #991b1b; border: 1px solid #ef4444; }
</style>

# Ask a question

<p class="legend">Stuck on the spec, the reference API, conformance, or how to model something in RiC? Ask here - your question is emailed straight to the maintainers. Leave an email if you'd like a reply (optional).</p>

<div class="ask-wrap">
<form id="ask-form" novalidate>
  <div class="ask-field">
    <label for="ask-body">Your question</label>
    <textarea id="ask-body" name="body" required minlength="8" placeholder="e.g. Does the reference API support OAI-PMH selective harvesting by set?"></textarea>
  </div>
  <div class="ask-field">
    <label for="ask-email">Your email <span class="ask-note">(optional - only used to reply)</span></label>
    <input type="email" id="ask-email" name="email" placeholder="you@institution.org" autocomplete="email">
  </div>
  <div class="ask-hp" aria-hidden="true">
    <label>Leave this empty<input type="text" name="website" tabindex="-1" autocomplete="off"></label>
  </div>
  <button class="ask-btn" id="ask-submit" type="submit">Send question</button>
  <p class="ask-note" style="margin-top:.6rem;">We store the question to answer it, and nothing else. No tracking, no account.</p>
  <div class="ask-msg" id="ask-msg" role="status"></div>
</form>
</div>

<script>
(function () {
  var API = "https://ric.theahg.co.za/api/ric/v1/ask";
  var form = document.getElementById("ask-form");
  var btn = document.getElementById("ask-submit");
  var msg = document.getElementById("ask-msg");

  function show(kind, text) { msg.className = "ask-msg " + kind; msg.textContent = text; }

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var body = document.getElementById("ask-body").value.trim();
    if (body.length < 8) { show("err", "Please write a little more so we can help."); return; }

    btn.disabled = true; show("", "");
    var payload = {
      body: body,
      email: document.getElementById("ask-email").value.trim(),
      website: form.website.value,            // honeypot
      page: document.referrer || location.pathname
    };
    fetch(API, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    }).then(function (r) {
      if (!r.ok && r.status !== 200) throw new Error("status " + r.status);
      return r.json();
    }).then(function () {
      form.reset();
      show("ok", "Thanks - your question is on its way. We'll reply if you left an email.");
    }).catch(function () {
      show("err", "Sorry, that didn't send. Please try again, or email johan@theahg.co.za directly.");
    }).then(function () { btn.disabled = false; });
  });
})();
</script>
