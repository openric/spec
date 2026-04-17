# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plansailingisystems.co.za
#
# This file is part of OpenRiC.
#
# OpenRiC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

"""SHACL validation via pyshacl.

Stub for the thin slice. Full implementation in Week 1 item 6.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any


def validate_against_shapes(
    document: dict[str, Any],
    shapes_path: Path,
) -> tuple[bool, str]:
    """Validate a JSON-LD document against a SHACL shape file.

    Returns (conforms, report_text).
    """
    try:
        import pyshacl
        from rdflib import Graph
    except ImportError as e:
        return False, f"pyshacl/rdflib not installed: {e}"

    try:
        data_graph = Graph()
        data_graph.parse(data=_to_jsonld_string(document), format="json-ld")
    except Exception as e:
        return False, (
            "Could not parse JSON-LD response as RDF — likely a malformed "
            f"@context. Underlying error: {e}"
        )

    try:
        shapes_graph = Graph()
        shapes_graph.parse(str(shapes_path), format="turtle")
    except Exception as e:
        return False, f"Could not parse SHACL shapes at {shapes_path}: {e}"

    try:
        conforms, _results_graph, results_text = pyshacl.validate(
            data_graph=data_graph,
            shacl_graph=shapes_graph,
            inference="rdfs",
            abort_on_first=False,
            meta_shacl=False,
            advanced=True,
            js=False,
            debug=False,
        )
        return conforms, results_text
    except Exception as e:
        return False, f"pyshacl raised an exception: {e}"


def _to_jsonld_string(document: dict[str, Any]) -> str:
    import json
    return json.dumps(document)
