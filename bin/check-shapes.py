#!/usr/bin/env python3
# Copyright (C) 2026 Johan Pieterse / Plain Sailing Information Systems
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Regression cases for the hierarchy and agent-link shapes (openric/spec#76, #79): data that follows the mapping
# is not reported, and real faults still are. Needs rdflib and pyshacl. Run: python3 bin/check-shapes.py
import sys
from pathlib import Path

import pyshacl
from rdflib import Graph, URIRef
from rdflib.namespace import SH

ROOT = Path(__file__).resolve().parent.parent
DATA = """
@prefix rico: <https://www.ica.org/standards/RiC/ontology#> .
@prefix ex: <https://example.org/> .
ex:fonds a rico:RecordSet ; rico:title "Fonds" ; rico:hasOrHadHolder ex:repo ; rico:hasOrHadSubject ex:subject .
ex:included a rico:Record ; rico:title "Included by isOrWasIncludedIn" ; rico:isOrWasIncludedIn ex:fonds .
ex:listed a rico:Record ; rico:title "Listed by its parent" .
ex:fonds rico:includesOrIncluded ex:listed .
ex:oldstyle a rico:Record ; rico:title "Linked by isOrWasPartOf" ; rico:isOrWasPartOf ex:fonds .
ex:orphan a rico:Record ; rico:title "No parent" .
ex:city a rico:Place ; rico:name "City" ; rico:isOrWasPartOf ex:country .
ex:country a rico:Place ; rico:name "Country" .
ex:repo a rico:CorporateBody ; rico:name "Holder only" .
ex:subject a rico:Person ; rico:name "Subject only" .
ex:work a rico:Activity ; rico:isOrWasPerformedBy ex:performer ; rico:resultsOrResultedIn ex:fonds .
ex:performer a rico:Person ; rico:name "Performer by isOrWasPerformedBy" .
ex:lonely a rico:Person ; rico:name "No link at all" .
"""

# shape file -> (source shape local name, focus node local name) pairs expected, and no others from these shapes
EXPECT = {
    "shapes/openric.shacl.ttl": {("RecordShape", "orphan")},
    "shapes/profiles/core-discovery.shacl.ttl": {("RecordShape", "orphan")},
    "shapes/full-graph.shacl.ttl": {("OrphanedRecordShape", "orphan"), ("UnlinkedAgentShape", "lonely")},
    "shapes/profiles/graph-traversal.shacl.ttl": {("OrphanedRecordShape", "orphan"), ("UnlinkedAgentShape", "lonely")},
}
WATCHED = {"RecordShape", "OrphanedRecordShape", "UnlinkedAgentShape", "RelationConsistencyShape"}


def local(term):
    return str(term).rsplit("#", 1)[-1].rsplit("/", 1)[-1]


def shape_of(report, result):
    """The named node shape a result comes from (a property shape is a blank node under it)."""
    source = report.value(result, SH.sourceShape)
    if isinstance(source, URIRef):
        return local(source)
    parent = shapes.value(None, SH.property, source)
    return local(parent) if parent is not None else None


data = Graph().parse(data=DATA, format="turtle")
failed = False
for path, expected in EXPECT.items():
    shapes = Graph().parse(ROOT / path, format="turtle")
    _, report, _ = pyshacl.validate(data, shacl_graph=shapes, inference="none")
    got = set()
    for result in report.subjects(None, SH.ValidationResult):
        name = shape_of(report, result)
        if name in WATCHED:
            got.add((name, local(report.value(result, SH.focusNode))))
    if got != expected:
        failed = True
        print(f"FAIL {path}")
        for x in sorted(got - expected):
            print(f"  reported, should not be: {x}")
        for x in sorted(expected - got):
            print(f"  not reported, should be: {x}")
    else:
        print(f"ok   {path}")
sys.exit(1 if failed else 0)
