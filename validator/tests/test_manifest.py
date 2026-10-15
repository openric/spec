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

"""The fixture manifest validates against its schema, so every done fixture
carries its provenance and licence labels (plan V4, S2.1)."""

import json
from pathlib import Path

from jsonschema import Draft202012Validator

FIXTURES = Path(__file__).resolve().parent.parent.parent / "fixtures"


def test_manifest_validates_against_its_schema():
    schema = json.loads((FIXTURES / "manifest.schema.json").read_text())
    manifest = json.loads((FIXTURES / "manifest.json").read_text())
    errors = [e.message for e in Draft202012Validator(schema).iter_errors(manifest)]
    assert errors == []


def test_captured_fixtures_say_where_they_were_captured():
    manifest = json.loads((FIXTURES / "manifest.json").read_text())
    for f in manifest["fixtures"]:
        if f.get("origin") == "captured":
            src = FIXTURES / f["name"] / "source-url.txt"
            assert src.exists() and src.read_text().strip(), f["name"]
