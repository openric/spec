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

  // The shared AHG sender, in E.164 without the plus. Canonical here so the
  // four surfaces cannot drift apart on it - the entity-colour lesson.
  var WHATSAPP = '27648830533';
  var WHATSAPP_TEXT = 'Hi, I have a question about OpenRiC.';

  // data-chrome="false" mounts ONLY the contact button. openric.org's own pages
  // already have their nav and footer and must not get a second set; they still
  // want the button, which is why this flag exists.
  var wantChrome = !(script && script.getAttribute('data-chrome') === 'false');

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

  // WhatsApp click-to-chat. The visitor initiates, so their own 24-hour window
  // opens and no template or consent record is involved. Replies are handled
  // from the workbench WhatsApp view - the sender has no handset of its own.
  function buildWhatsApp() {
    var a = el('a', 'oric-wa');
    a.href = 'https://wa.me/' + WHATSAPP + '?text=' + encodeURIComponent(WHATSAPP_TEXT);
    a.target = '_blank';
    a.rel = 'noopener';
    a.setAttribute('aria-label', 'Message OpenRiC on WhatsApp');
    a.title = 'Message us on WhatsApp';
    a.innerHTML =
      '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
      '<path d="M12.04 2c-5.46 0-9.9 4.44-9.9 9.9 0 1.75.46 3.45 1.32 4.95L2 22l5.3-1.39a9.86 9.86 0 0 0 4.74 1.21h.01c5.46 0 9.9-4.44 9.9-9.9 0-2.64-1.03-5.13-2.9-7A9.82 9.82 0 0 0 12.04 2Zm0 18.02h-.01a8.2 8.2 0 0 1-4.18-1.15l-.3-.18-3.1.81.83-3.03-.2-.31a8.18 8.18 0 0 1-1.26-4.36c0-4.54 3.7-8.23 8.23-8.23 2.2 0 4.26.86 5.82 2.41a8.18 8.18 0 0 1 2.41 5.83c0 4.54-3.7 8.21-8.24 8.21Zm4.52-6.16c-.25-.12-1.47-.72-1.69-.81-.23-.08-.39-.12-.56.13-.16.24-.64.8-.78.97-.15.16-.29.18-.53.06-.25-.13-1.05-.39-1.99-1.23-.74-.66-1.23-1.47-1.38-1.72-.14-.25-.01-.38.11-.5.11-.11.25-.29.37-.43.13-.15.17-.25.25-.41.08-.17.04-.31-.02-.43-.06-.12-.56-1.34-.76-1.84-.2-.48-.41-.42-.56-.43h-.48c-.16 0-.43.06-.65.31-.22.25-.85.84-.85 2.04 0 1.2.87 2.36.99 2.53.12.16 1.71 2.61 4.14 3.66.58.25 1.03.4 1.38.51.58.19 1.11.16 1.53.1.47-.07 1.47-.6 1.67-1.18.21-.58.21-1.07.15-1.18-.06-.11-.22-.17-.47-.29Z"/>' +
      '</svg><span class="oric-wa-label">WhatsApp us</span>';
    return a;
  }

  function mount() {
    if (document.querySelector('.oric-wa')) return; // never double-mount
    if (wantChrome && !document.querySelector('.oric-shell')) {
      document.body.insertBefore(buildHeader(), document.body.firstChild);
      if (wantFooter) document.body.appendChild(buildFooter());
    }
    document.body.appendChild(buildWhatsApp());
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
