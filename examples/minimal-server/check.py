#!/usr/bin/env python3
#
# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
#
# This file is part of OpenRiC. Licensed under AGPL-3.0-or-later.
#
"""Validate a server's Core Discovery responses against the OpenRiC JSON Schemas.

Fetches each Core Discovery endpoint, and every record, agent and repository
the lists name, and validates each response against its schema in schemas/.
Read-only. Exits non-zero if anything fails.

    BASE=http://localhost:8080 python3 examples/minimal-server/check.py
"""

import json
import os
import pathlib
import sys
import urllib.error
import urllib.request

from jsonschema import Draft202012Validator

BASE = os.environ.get("BASE", "http://localhost:8080").rstrip("/")
SCHEMAS = pathlib.Path(__file__).resolve().parents[2] / "schemas"


def fetch(path):
    req = urllib.request.Request(BASE + path, headers={"Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return resp.status, json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as err:
        return err.code, json.loads(err.read().decode("utf-8") or "null")


def schema(name):
    return Draft202012Validator(json.loads((SCHEMAS / f"{name}.schema.json").read_text()))


failures = 0


def check(path, schema_name, expect=200):
    global failures
    status, body = fetch(path)
    errors = [] if status == expect else [f"HTTP {status}, expected {expect}"]
    errors += [f"{'/'.join(map(str, e.absolute_path)) or '(root)'}: {e.message}"
               for e in schema(schema_name).iter_errors(body)]
    print(("FAIL" if errors else "ok  ") + f"  {path}  [{schema_name}]")
    for e in errors[:5]:
        print("        " + e)
    failures += bool(errors)
    return body


check("/", "service-description")
check("/vocabulary", "vocabulary")
check("/autocomplete?q=marsh&limit=5", "autocomplete")
for kind, item_schema in (("records", "record"), ("agents", "agent"), ("repositories", "repository")):
    listing = check(f"/{kind}", "list")
    for item in (listing or {}).get("openric:items", []):
        check(f"/{kind}/" + item["@id"].rsplit("/", 1)[-1], item_schema)
check("/records/does-not-exist", "error", expect=404)

print(f"\n{'All responses valid.' if not failures else f'{failures} response(s) failed.'}")
sys.exit(1 if failures else 0)
