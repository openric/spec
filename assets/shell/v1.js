/*
 * Copyright (C) 2026 Johan Pieterse / Plain Sailing Information Systems
 * Email: johan@plainsailingisystems.co.za
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * OpenRiC shared shell, v1.
 * Canonical source: https://openric.org/assets/shell/v1.js
 *
 * Injects the shared header and footer so the four OpenRiC surfaces read as
 * one product without being one deployment. Pair it with v1.css.
 *
 * USAGE - two lines in <head>, and remove the page's own header:
 *
 *   <link rel="stylesheet" href="https://openric.org/assets/shell/v1.css">
 *   <script defer src="https://openric.org/assets/shell/v1.js"
 *           data-product="Graph Explorer"></script>
 *
 * data-product is what tells a visitor which of the four they are on:
 * "Explore", "Model Reference", "Graph Explorer", "Editor", "API".
 *
 * data-footer="false" suppresses the footer for a full-bleed app surface
 * where a footer would be in the way.
 *
 * PROGRESSIVE ENHANCEMENT. If this file fails to load, the page loses the
 * shared chrome and keeps working. Nothing here is required for function, so
 * no consuming page should depend on it for navigation that matters.
 */

(function () {
  'use strict';

  var script = document.currentScript ||
    document.querySelector('script[src*="/assets/shell/v1.js"]');

  var product = (script && script.getAttribute('data-product')) || '';
  var wantFooter = !(script && script.getAttribute('data-footer') === 'false');
  // The viewer and editor are dark app surfaces; a white strip above them
  // reads as a rendering fault rather than as chrome.
  var theme = (script && script.getAttribute('data-theme')) || 'light';

  var HOME = 'https://openric.org';

  function el(tag, cls, html) {
    var node = document.createElement(tag);
    if (cls) node.className = cls;
    if (html != null) node.innerHTML = html;
    return node;
  }

  function buildHeader() {
    var header = el('header', 'oric-shell');
    header.setAttribute('data-theme', theme);
    var inner = el('div', 'oric-shell-inner');

    var brand = el('a', 'oric-shell-brand');
    brand.href = HOME;
    brand.appendChild(el('span', 'oric-shell-dot'));
    brand.appendChild(document.createTextNode('OpenRiC'));
    inner.appendChild(brand);

    if (product) {
      inner.appendChild(el('span', 'oric-shell-product', product));
    }

    var links = el('div', 'oric-shell-links');
    [
      ['Explore', HOME + '/explore.html'],
      ['Learn & Model', HOME + '/learn.html'],
      ['Build', HOME + '/for-developers.html'],
      ['Help', HOME + '/help/'],
    ].forEach(function (pair) {
      var a = el('a', null, pair[0]);
      a.href = pair[1];
      links.appendChild(a);
    });

    // One consistent way back, on every surface.
    var back = el('a', 'oric-back', '&larr; openric.org');
    back.href = HOME;
    links.appendChild(back);

    inner.appendChild(links);
    header.appendChild(inner);
    return header;
  }

  function buildFooter() {
    var footer = el('footer', 'oric-shell-footer');
    footer.setAttribute('data-theme', theme);
    var links = el('div', 'oric-shell-footer-links');
    [
      ['Specification', HOME + '/spec/'],
      ['Standards baseline', HOME + '/ric-baseline.html'],
      ['Governance', HOME + '/governance.html'],
      ['Ask a question', HOME + '/ask/'],
      ['GitHub', 'https://github.com/openric/spec'],
    ].forEach(function (pair) {
      var a = el('a', null, pair[0]);
      a.href = pair[1];
      links.appendChild(a);
    });
    footer.appendChild(links);
    footer.appendChild(el('div', null,
      'OpenRiC is an open specification. Specification CC-BY 4.0, reference code AGPL-3.0.'));
    return footer;
  }

  function mount() {
    if (document.querySelector('.oric-shell')) return; // never double-mount
    document.body.insertBefore(buildHeader(), document.body.firstChild);
    if (wantFooter) document.body.appendChild(buildFooter());
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
