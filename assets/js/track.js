/*
 * OpenRiC anonymous demand-signal tracker (client side).
 *
 * Copyright (C) 2026 Johan Pieterse / Plain Sailing iSystems. AGPL 3.0.
 *
 * Sends a tiny, anonymous beacon to the reference API so we can see what
 * content/demos are in demand and pre-empt enhancements. It carries NO personal
 * data — just an event name and a label (a path, a search term, a scenario id).
 * Form-encoded so it never triggers a CORS preflight (reliable on page unload).
 *
 * Public API: window.openricTrack(event, label)
 *   events the beacon may send: page_view | search | wizard_started | wizard_completed
 */
(function () {
  "use strict";
  var API = "https://ric.theahg.co.za/api/ric/v1/track";

  function track(event, label) {
    try {
      var data = new URLSearchParams();
      data.set("event", String(event || ""));
      data.set("label", String(label == null ? "" : label).slice(0, 300));
      if (navigator.sendBeacon) {
        navigator.sendBeacon(API, data);
      } else {
        fetch(API, { method: "POST", body: data, keepalive: true, mode: "cors" });
      }
    } catch (e) { /* tracking is best-effort, never break the page */ }
  }

  window.openricTrack = track;

  // One page-view per load. Use the path only — no query string, no referrer.
  track("page_view", location.pathname);
})();
