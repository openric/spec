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

"""Smoke tests for openric-validate."""

import json
from pathlib import Path

import pytest

from openric_validate.graph_check import check_subgraph_invariants
from openric_validate.schema_check import (
    SchemaCheckError,
    validate_against_schema,
)

FIXTURES = Path(__file__).resolve().parent.parent.parent / "fixtures"
SCHEMAS = Path(__file__).resolve().parent.parent.parent / "schemas"


def test_fonds_minimal_expected_validates_against_record_schema():
    """The fonds-minimal fixture's expected output must pass its schema."""
    expected = json.loads((FIXTURES / "fonds-minimal" / "expected.jsonld").read_text())
    schema = json.loads((SCHEMAS / "record.schema.json").read_text())
    validate_against_schema(expected, schema)


def test_schema_rejects_missing_required_field():
    """A record missing @type should fail validation."""
    schema = json.loads((SCHEMAS / "record.schema.json").read_text())
    bad = {"@id": "http://example.org/r/1", "rico:title": "No type"}
    with pytest.raises(SchemaCheckError):
        validate_against_schema(bad, schema)


def test_subgraph_invariants_pass_on_well_formed():
    """A subgraph with root in nodes and no dangling edges has no violations."""
    sg = {
        "openric:root": "urn:a",
        "openric:nodes": [
            {"id": "urn:a", "type": "rico:Record", "label": "A"},
            {"id": "urn:b", "type": "rico:Person", "label": "B"},
        ],
        "openric:edges": [
            {"source": "urn:a", "target": "urn:b",
             "predicate": "rico:hasCreator", "label": "by"},
        ],
    }
    assert check_subgraph_invariants(sg) == []


def test_subgraph_invariants_catch_dangling_edge():
    sg = {
        "openric:root": "urn:a",
        "openric:nodes": [{"id": "urn:a", "type": "rico:Record", "label": "A"}],
        "openric:edges": [
            {"source": "urn:a", "target": "urn:nowhere",
             "predicate": "rico:isRelatedTo", "label": "rel"},
        ],
    }
    v = check_subgraph_invariants(sg)
    assert any("target" in x.message for x in v)


def test_subgraph_invariants_catch_missing_root():
    sg = {
        "openric:root": "urn:missing",
        "openric:nodes": [{"id": "urn:a", "type": "rico:Record", "label": "A"}],
        "openric:edges": [],
    }
    v = check_subgraph_invariants(sg)
    assert any(x.invariant == "root-presence" for x in v)
