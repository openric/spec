#!/usr/bin/env python3
# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Keep contract/openapi.json honest (plan V4, S1.3).

Fails when the contract:
  - carries a version other than version.json's;
  - names a profile that is not in _data/profiles.json, or the wrong status;
  - types a path identifier as anything but a string (a storage assumption);
  - points at a schema or example file that does not exist;
  - has an example that fails the JSON Schema of the response it illustrates.

Needs jsonschema (pip install ./validator). Exit 0 clean, 1 on any problem.
"""
import json
import sys
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parent.parent
CONTRACT = ROOT / "contract/openapi.json"


def main() -> int:
    doc = json.loads(CONTRACT.read_text())
    version = json.loads((ROOT / "version.json").read_text())["version"]
    profiles = {p["id"]: p["status"] for p in json.loads((ROOT / "_data/profiles.json").read_text())}
    problems, examples = [], 0

    if doc.get("openapi", "").split(".")[:2] != ["3", "1"]:
        problems.append(f"openapi is {doc.get('openapi')!r}; the contract uses 3.1 so it can point at the 2020-12 schemas")
    if doc["info"]["version"] != version:
        problems.append(f"info.version {doc['info']['version']} != version.json {version}")

    def resolve(rel: str) -> Path:
        return (CONTRACT.parent / rel).resolve()

    for path, ops in doc["paths"].items():
        for method, op in ops.items():
            where = f"{method.upper()} {path}"
            prof = op.get("x-openric-profile")
            if prof not in profiles:
                problems.append(f"{where}: x-openric-profile {prof!r} is not a profile")
            elif op.get("x-openric-status") != profiles[prof]:
                problems.append(f"{where}: x-openric-status {op.get('x-openric-status')!r}, profile is {profiles[prof]!r}")
            for p in op.get("parameters", []):
                if p["in"] == "path" and p["schema"].get("type") != "string":
                    problems.append(f"{where}: path parameter {p['name']} must be a string, not {p['schema'].get('type')}")
            bodies = [(f"{code} response", r.get("content", {})) for code, r in op["responses"].items()]
            if "requestBody" in op:
                bodies.append(("request body", op["requestBody"]["content"]))
            for label, content in bodies:
                for c in content.values():
                    ref = c.get("schema", {}).get("$ref")
                    schema = None
                    if ref:
                        file, _, frag = ref.partition("#")
                        if not resolve(file).exists():
                            problems.append(f"{where} {label}: schema {ref} does not exist")
                            continue
                        schema = json.loads(resolve(file).read_text())
                        if frag:
                            # A pointer into the file's $defs: keep the $defs so inner refs still resolve.
                            if frag.split("/")[-1] not in schema.get("$defs", {}):
                                problems.append(f"{where} {label}: schema {ref} does not exist")
                                continue
                            schema = {"$defs": schema["$defs"], "$ref": "#" + frag}
                    for name, ex in c.get("examples", {}).items():
                        f = resolve(ex["externalValue"])
                        if not f.exists():
                            problems.append(f"{where} {label}: example {ex['externalValue']} does not exist")
                            continue
                        examples += 1
                        if schema is None:
                            continue
                        errs = list(Draft202012Validator(schema).iter_errors(json.loads(f.read_text())))
                        if errs:
                            problems.append(f"{where} {label}: example {name} fails {ref}: {errs[0].message[:120]}")

    ops = sum(len(v) for v in doc["paths"].values())
    for p in problems:
        print(f"FAIL  {p}")
    print(f"contract {doc['info']['version']}: {ops} operations, {examples} examples checked, {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
