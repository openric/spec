#!/usr/bin/env python3
# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Every openric: and openricx: term the schemas and fixtures use must be
defined in the published vocabulary (ns/v1.ttl, ns/ext/v1.ttl), and every
fixture that uses a prefix must bind it in its @context.

Needs rdflib. Exit 0 clean, 1 on any problem.
"""
import json
import pathlib
import re
import sys

import rdflib

ROOT = pathlib.Path(__file__).resolve().parent.parent
VOCABS = {"openric": ("https://openric.org/ns/v1#", ROOT / "ns/v1.ttl"),
          "openricx": ("https://openric.org/ns/ext/v1#", ROOT / "ns/ext/v1.ttl")}
TERM = re.compile(r'"(openricx?):([A-Za-z][A-Za-z0-9]*)"')


def main() -> int:
    defined = {}
    for prefix, (ns, path) in VOCABS.items():
        g = rdflib.Graph().parse(path)
        defined[prefix] = {str(s)[len(ns):] for s in g.subjects() if str(s).startswith(ns) and len(str(s)) > len(ns)}

    problems = []
    files = sorted(ROOT.glob("schemas/*.schema.json")) + sorted(ROOT.glob("fixtures/*/expected.jsonld"))
    for f in files:
        rel = f.relative_to(ROOT)
        text = f.read_text(encoding="utf-8")
        used = set(TERM.findall(text))
        for prefix, term in sorted(used):
            if term not in defined[prefix]:
                problems.append(f"{rel}: {prefix}:{term} is not defined in {VOCABS[prefix][1].relative_to(ROOT)}")
        if f.suffix == ".jsonld":
            doc = json.loads(text)
            ctx = doc.get("@context", {}) if isinstance(doc, dict) else {}
            for prefix in sorted({p for p, _ in used}):
                if isinstance(ctx, dict) and ctx and ctx.get(prefix) != VOCABS[prefix][0]:
                    problems.append(f"{rel}: uses {prefix}: but its @context does not bind it to {VOCABS[prefix][0]}")

    for p in problems:
        print(f"FAIL  {p}")
    print(f"vocabulary: {sum(map(len, defined.values()))} terms defined, {len(files)} files checked, {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
