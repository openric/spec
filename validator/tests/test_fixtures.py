# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
#
# This file is part of OpenRiC.
#
# OpenRiC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

"""Parametrised tests that walk every fixture and validate it.

For each fixture folder in /fixtures/<case>/:
  - Load expected.jsonld
  - Resolve the matching schema via the CLI's @type → schema map
  - Assert the JSON validates cleanly
  - If @type is openric:Subgraph, also assert the six invariants hold
"""

import json
from pathlib import Path

import pytest

from openric_validate.cli import _resolve_schema
from openric_validate.schema_check import validate_against_schema
from openric_validate.graph_check import check_subgraph_invariants

FIXTURES = Path(__file__).resolve().parent.parent.parent / "fixtures"
SCHEMAS = Path(__file__).resolve().parent.parent.parent / "schemas"


def _fixture_cases() -> list[tuple[str, Path]]:
    cases = []
    for child in sorted(FIXTURES.iterdir()):
        if not child.is_dir():
            continue
        expected = child / "expected.jsonld"
        if expected.exists():
            cases.append((child.name, expected))
    return cases


def _source_url(fixture_dir: Path) -> str:
    url_file = fixture_dir / "source-url.txt"
    return url_file.read_text().strip() if url_file.exists() else ""


@pytest.mark.parametrize("name,expected_path", _fixture_cases())
def test_fixture_validates_against_schema(name: str, expected_path: Path):
    """Every fixture's expected.jsonld must validate against its resolved schema."""
    response = json.loads(expected_path.read_text())
    url = _source_url(expected_path.parent)
    short_type, schema_path = _resolve_schema(response, SCHEMAS, url)
    if schema_path is None:
        pytest.skip(f"{name}: no JSON Schema for this response shape "
                    "(raw RDF / SPARQL / revisions — validated by other means)")
    assert schema_path.exists(), f"Schema file missing: {schema_path}"
    schema = json.loads(schema_path.read_text())
    # raises SchemaCheckError if invalid; pytest will catch and fail the test
    validate_against_schema(response, schema)


@pytest.mark.parametrize("name,expected_path", _fixture_cases())
def test_subgraph_fixtures_satisfy_invariants(name: str, expected_path: Path):
    """Subgraph-type fixtures must satisfy the six graph-primitive invariants."""
    response = json.loads(expected_path.read_text())
    url = _source_url(expected_path.parent)
    short_type, _ = _resolve_schema(response, SCHEMAS, url)
    if short_type != "Subgraph":
        pytest.skip(f"{name} is not a Subgraph fixture")
    violations = check_subgraph_invariants(response)
    assert violations == [], (
        f"Fixture {name} fails invariants: "
        + "; ".join(f"[{v.invariant}] {v.message}" for v in violations)
    )
