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

    data_graph = Graph()
    data_graph.parse(data=_to_jsonld_string(document), format="json-ld")

    shapes_graph = Graph()
    shapes_graph.parse(str(shapes_path), format="turtle")

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


def _to_jsonld_string(document: dict[str, Any]) -> str:
    import json
    return json.dumps(document)
