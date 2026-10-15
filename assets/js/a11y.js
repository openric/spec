// Copyright (C) 2026 Johan Pieterse
// Plain Sailing Information Systems
// Email: johan@plainsailingisystems.co.za
//
// This file is part of OpenRiC. Licensed under AGPL-3.0-or-later.
//
// A code block wider than the page scrolls sideways; make it focusable so it
// can be scrolled from the keyboard (WCAG 2.1.1, axe scrollable-region-focusable).
(function () {
  function run() {
    document.querySelectorAll('pre').forEach(function (pre) {
      if (pre.scrollWidth > pre.clientWidth && !pre.hasAttribute('tabindex')) {
        pre.setAttribute('tabindex', '0');
      }
    });
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', run);
  } else {
    run();
  }
})();
