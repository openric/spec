#!/usr/bin/env node
/*
 * validate-scenarios.mjs — guard rail for the modelling-wizard scenario library.
 *
 * Copyright (C) 2026 Johan Pieterse / Plain Sailing iSystems. AGPL 3.0.
 *
 * Validates every assets/data/scenarios/<id>.json against the pinned RiC-CM 1.0
 * model and the reference server's relation vocabulary:
 *   1. structure — steps, choices, capture calls, required fields;
 *   2. branch integrity — every step.next / choice.next resolves to a real step;
 *   3. relation codes — every capture relation_type is a known server code;
 *   4. entity codes — every choice.entity is a real RiC-CM 1.0 code AND is
 *      consistent with the choice label (this is what catches "Place = E08").
 *
 * Exit 0 = all valid; exit 1 = at least one problem. Run: node bin/validate-scenarios.mjs
 */

import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const DIR = join(dirname(fileURLToPath(import.meta.url)), '..', 'assets', 'data', 'scenarios');

// RiC-CM 1.0 entity code → canonical name (pinned; the site targets RiC-CM 1.0).
const ENTITY_NAME = {
  'RiC-E01': 'Thing', 'RiC-E02': 'Record Resource', 'RiC-E03': 'Record Set',
  'RiC-E04': 'Record', 'RiC-E05': 'Record Part', 'RiC-E06': 'Instantiation',
  'RiC-E07': 'Agent', 'RiC-E08': 'Person', 'RiC-E09': 'Group', 'RiC-E10': 'Family',
  'RiC-E11': 'Corporate Body', 'RiC-E12': 'Position', 'RiC-E13': 'Mechanism',
  'RiC-E14': 'Event', 'RiC-E15': 'Activity', 'RiC-E16': 'Rule', 'RiC-E17': 'Mandate',
  'RiC-E18': 'Date', 'RiC-E22': 'Place',
};
const AGENT_FAMILY = new Set(['RiC-E07', 'RiC-E08', 'RiC-E09', 'RiC-E10', 'RiC-E11', 'RiC-E12', 'RiC-E13']);

// Distinctive label token → the entity code it must carry (longest tokens first).
// Agent-family labels accept any code in AGENT_FAMILY (Agent is the superclass).
const CONCEPT = [
  ['record set', 'RiC-E03'], ['record part', 'RiC-E05'], ['record resource', 'RiC-E02'],
  ['instantiation', 'RiC-E06'], ['activity', 'RiC-E15'], ['place', 'RiC-E22'],
  ['mandate', 'RiC-E17'], ['rule', 'RiC-E16'], ['date', 'RiC-E18'], ['record', 'RiC-E04'],
  ['agent', 'AGENT'], ['person', 'AGENT'], ['corporate body', 'AGENT'], ['family', 'AGENT'],
  ['group', 'AGENT'], ['mechanism', 'AGENT'],
];

// Relation codes the reference server accepts (ric_relation_type). Update if the
// server's vocabulary changes; the wizard's capture calls must use these.
const RELATION_CODES = new Set([
  'has_creator', 'has_accumulator', 'has_collector', 'has_provenance', 'held_by',
  'managed_by', 'includes', 'has_part', 'is_superior_of', 'is_successor_of',
  'is_predecessor_of', 'follows', 'performs_function', 'has_mandate', 'is_regulated_by',
  'is_associated_with', 'is_equivalent_to', 'has_or_had_location', 'has_or_had_subject',
  'results_from', 'performed_by', 'has_instantiation', 'has_derived_instantiation',
  'has_family_member', 'is_child_of', 'is_sibling_of', 'documents', 'has_genetic_link_to',
  'is_copy_of', 'is_original_of',
]);

// Infer the intended entity from a choice label by matching an entity name at
// the START of the label (after stripping leading articles/quantifiers). This
// avoids false hits on incidental mentions ("the recording" ≠ Record, "under
// one rule" ≠ Rule). Returns null when the label doesn't lead with an entity.
function expectedCode(label) {
  let l = label.toLowerCase().trim();
  while (/^(a|an|the|also|three|two|single|one)\s+/.test(l)) {
    l = l.replace(/^(a|an|the|also|three|two|single|one)\s+/, '');
  }
  for (const [tok, code] of CONCEPT) if (l.startsWith(tok)) return code;
  return null;
}

function validateScenario(id, errs) {
  let j;
  try { j = JSON.parse(readFileSync(join(DIR, id + '.json'), 'utf8')); }
  catch (e) { errs.push(`${id}: cannot parse — ${e.message}`); return; }

  if (!Array.isArray(j.steps) || !j.steps.length) { errs.push(`${id}: no steps`); return; }
  const stepIds = new Set(j.steps.map((s) => s.id));

  for (const st of j.steps) {
    const at = `${id}/${st.id}`;
    if (!st.id) errs.push(`${id}: a step has no id`);
    if (!st.prompt) errs.push(`${at}: no prompt`);
    if (st.next && !stepIds.has(st.next)) errs.push(`${at}: step.next → unknown "${st.next}"`);
    if (!Array.isArray(st.choices) || !st.choices.length) { errs.push(`${at}: no choices`); continue; }

    let hasCorrect = false;
    for (const c of st.choices) {
      if (typeof c.correct !== 'boolean') errs.push(`${at}: choice "${c.label}" missing correct:bool`);
      if (c.correct) hasCorrect = true;
      if (!c.why) errs.push(`${at}: choice "${c.label}" missing why`);
      if (c.next && !stepIds.has(c.next)) errs.push(`${at}: choice.next → unknown "${c.next}"`);
      if (c.entity && c.entity !== '—') {
        if (!ENTITY_NAME[c.entity]) { errs.push(`${at}: unknown entity code "${c.entity}"`); }
        else {
          const exp = expectedCode(c.label || '');
          if (exp === 'AGENT') { if (!AGENT_FAMILY.has(c.entity)) errs.push(`${at}: "${c.label}" looks like an Agent but code is ${c.entity} (${ENTITY_NAME[c.entity]})`); }
          else if (exp && exp !== c.entity) errs.push(`${at}: "${c.label}" implies ${exp} (${ENTITY_NAME[exp]}) but code is ${c.entity} (${ENTITY_NAME[c.entity]})`);
        }
      }
    }
    if (!hasCorrect) errs.push(`${at}: no correct choice`);

    for (const call of st.capture || []) {
      if (!call.method || !call.path) errs.push(`${at}: capture call missing method/path`);
      if (!call.comment) errs.push(`${at}: capture call missing comment`);
      const rt = call.body && call.body.relation_type;
      if (rt && !RELATION_CODES.has(rt)) errs.push(`${at}: unknown relation_type "${rt}"`);
    }
  }
}

const index = JSON.parse(readFileSync(join(DIR, 'index.json'), 'utf8'));
const indexIds = new Set(index.map((s) => s.id));
const files = readdirSync(DIR).filter((f) => f.endsWith('.json') && f !== 'index.json').map((f) => f.replace(/\.json$/, ''));

const errs = [];
for (const s of index) {
  if (!s.id || !s.title) errs.push(`index: entry missing id/title`);
  validateScenario(s.id, errs);
}
for (const f of files) if (!indexIds.has(f)) errs.push(`${f}.json exists but is not listed in index.json`);

if (errs.length) {
  console.error(`✗ ${errs.length} problem(s) in the scenario library:\n` + errs.map((e) => '  - ' + e).join('\n'));
  process.exit(1);
}
console.log(`✓ all ${index.length} scenarios valid (structure · branches · relation codes · entity codes ↔ labels)`);
