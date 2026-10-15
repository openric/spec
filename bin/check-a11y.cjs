#!/usr/bin/env node
// Copyright (C) 2026 Johan Pieterse
// Plain Sailing Information Systems
// Email: johan@plainsailingisystems.co.za
//
// This file is part of OpenRiC. Licensed under AGPL-3.0-or-later.
//
// Accessibility smoke test (plan V4, S3): runs axe at WCAG 2 A and AA on the
// pages listed in bin/a11y-pages.txt and fails on any violation. A smoke
// test, not an audit - see known issue K-11.
//
// Usage: CHROME=/usr/bin/google-chrome node bin/check-a11y.cjs http://localhost:4000
// Needs puppeteer-core and axe-core installed (CI installs them, pinned).

const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer-core');
const axeSource = fs.readFileSync(require.resolve('axe-core/axe.min.js'), 'utf8');

const base = (process.argv[2] || 'http://localhost:4000').replace(/\/$/, '');
const pages = fs.readFileSync(path.join(__dirname, 'a11y-pages.txt'), 'utf8')
  .split('\n').map(l => l.trim()).filter(l => l && !l.startsWith('#'));

(async () => {
  const browser = await puppeteer.launch({ executablePath: process.env.CHROME || '/usr/bin/google-chrome', args: ['--no-sandbox'] });
  let failures = 0;
  for (const p of pages) {
    const page = await browser.newPage();
    await page.goto(base + p, { waitUntil: 'networkidle0', timeout: 60000 });
    await page.addScriptTag({ content: axeSource });
    const violations = await page.evaluate(async () =>
      (await axe.run(document, { runOnly: ['wcag2a', 'wcag2aa'] })).violations);
    for (const v of violations) {
      for (const n of v.nodes) {
        const d = (n.any[0] || {}).data || {};
        const colours = d.contrastRatio ? ` (${d.fgColor} on ${d.bgColor}, ${d.contrastRatio}:1)` : '';
        console.log(`FAIL ${p} ${v.id}${colours} ${n.html.slice(0, 100)}`);
        failures++;
      }
    }
    if (!violations.length) console.log(`ok   ${p}`);
    await page.close();
  }
  await browser.close();
  console.log(failures ? `${failures} accessibility violation(s)` : `${pages.length} pages, no violations`);
  process.exit(failures ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
