#!/usr/bin/env python3
#
# Copyright (C) 2026 Johan Pieterse / Plain Sailing Information Systems
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# OpenRiC conformance probe helper: the checks the probe cannot make with jq.
#
#   validate.py schema <schema.json> <response.json>   JSON Schema 2020-12 (needs jsonschema)
#   validate.py shacl  <shapes.ttl> <doc.jsonld>...     SHACL (needs pyshacl)
#   validate.py triples <a> <format> <b> <format>...     same triple set in every file (needs rdflib)
#   validate.py ricold <oai.xml> <out.jsonld>           a rico_ld record's JSON-LD: wrapped, parses, @graph not empty
#
# Exit codes: 0 pass, 1 fail (the reason on stdout), 3 the library is not
# installed, so the probe reports the check as skipped, never as passed.

import json
import sys


def unavailable(name):
    print(f"{name} not installed")
    sys.exit(3)


def schema(schema_path, response_path):
    try:
        from jsonschema import Draft202012Validator
    except ImportError:
        unavailable("jsonschema")
    with open(schema_path, encoding="utf-8") as f:
        validator = Draft202012Validator(json.load(f))
    with open(response_path, encoding="utf-8") as f:
        errors = sorted(validator.iter_errors(json.load(f)), key=lambda e: list(e.path))
    if errors:
        e = errors[0]
        print(f"{'/'.join(str(p) for p in e.path) or '(root)'}: {e.message}"[:300])
        sys.exit(1)


def shacl(shapes_path, documents):
    try:
        from pyshacl import validate
        from rdflib import Graph
    except ImportError:
        unavailable("pyshacl")
    from rdflib import URIRef
    data = Graph()
    focus = []
    for path in documents:
        data.parse(path, format="json-ld")
        with open(path, encoding="utf-8") as f:
            document = json.load(f)
        # The entity each response describes, or each entity a dump describes; not the stubs it
        # embeds (@id, @type and a name), which the shapes would otherwise check as full descriptions.
        focus += [URIRef(node["@id"]) for node in document.get("@graph", [document]) if isinstance(node, dict) and "@id" in node]
    conforms, _, text = validate(data, shacl_graph=Graph().parse(shapes_path, format="turtle"), inference="none", allow_warnings=True, focus_nodes=focus or None)
    if not conforms:
        print(" ".join(text.split())[:300])
        sys.exit(1)


def triples(pairs):
    try:
        from rdflib import Graph
        from rdflib.compare import isomorphic
    except ImportError:
        unavailable("rdflib")
    from rdflib import Literal
    from rdflib.namespace import XSD

    def normalised(graph):
        # RDF 1.1: a simple literal and the same string typed xsd:string are one term.
        out = Graph()
        for s, p, o in graph:
            out.add((s, p, Literal(str(o)) if isinstance(o, Literal) and o.datatype == XSD.string else o))
        return out

    graphs = [(path, normalised(Graph().parse(path, format=fmt))) for path, fmt in zip(pairs[::2], pairs[1::2])]
    first_path, first = graphs[0]
    for path, graph in graphs[1:]:
        if not isomorphic(first, graph):
            print(f"{path} has {len(graph)} triples, {first_path} {len(first)}; the graphs differ")
            sys.exit(1)


def ricold(xml_path, out_path):
    import xml.etree.ElementTree as ET
    root = ET.parse(xml_path).getroot()
    found = root.findall(".//{http://www.openarchives.org/OAI/2.0/}metadata/{https://www.ica.org/standards/RiC/ontology#}Record/{https://openric.org/ns/ext/v1#}jsonld")
    if not found:
        print("no <metadata><rico:Record><openricx:jsonld> (Export-Only 3.1)")
        sys.exit(1)
    try:
        document = json.loads(found[0].text or "")
    except ValueError as e:
        print(f"the rico_ld text is not JSON: {e}")
        sys.exit(1)
    if not document.get("@graph") and not document.get("@id"):
        print("the rico_ld document has neither @graph nor @id")
        sys.exit(1)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(document, f)


if __name__ == "__main__":
    mode, args = sys.argv[1], sys.argv[2:]
    {"schema": lambda: schema(*args), "shacl": lambda: shacl(args[0], args[1:]), "triples": lambda: triples(args), "ricold": lambda: ricold(*args)}[mode]()
