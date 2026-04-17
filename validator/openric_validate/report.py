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

"""Report accumulation + output formatting (human / json / junit)."""

from __future__ import annotations

import json
import sys
from dataclasses import dataclass, field, asdict
from enum import Enum
from typing import Iterable


class Severity(str, Enum):
    PASS = "pass"
    INFO = "info"
    WARNING = "warning"
    VIOLATION = "violation"


@dataclass
class Finding:
    check: str
    severity: Severity
    message: str
    target: str = ""


@dataclass
class Report:
    findings: list[Finding] = field(default_factory=list)

    def add(self, finding: Finding) -> None:
        self.findings.append(finding)

    def count(self, severity: Severity) -> int:
        return sum(1 for f in self.findings if f.severity == severity)

    def exit_code(self) -> int:
        if self.count(Severity.VIOLATION):
            return 1
        if self.count(Severity.WARNING):
            return 2
        return 0

    def emit(self, fmt: str) -> None:
        if fmt == "json":
            self._emit_json()
        elif fmt == "junit":
            self._emit_junit()
        else:
            self._emit_human()

    def _emit_human(self) -> None:
        ICONS = {
            Severity.PASS: "\u2713",
            Severity.INFO: "\u2022",
            Severity.WARNING: "!",
            Severity.VIOLATION: "\u2717",
        }
        for f in self.findings:
            print(f"  {ICONS[f.severity]} [{f.check}] {f.message}")
            if f.target:
                print(f"      at {f.target}")

        total = len(self.findings)
        passes = self.count(Severity.PASS)
        warns = self.count(Severity.WARNING)
        viols = self.count(Severity.VIOLATION)
        print()
        print(f"  Summary: {passes} pass, {warns} warning, {viols} violation"
              f" ({total} findings total)")

    def _emit_json(self) -> None:
        payload = {
            "openric_validator_version": "0.1.0",
            "summary": {
                "pass": self.count(Severity.PASS),
                "warning": self.count(Severity.WARNING),
                "violation": self.count(Severity.VIOLATION),
                "total": len(self.findings),
            },
            "findings": [
                {**asdict(f), "severity": f.severity.value}
                for f in self.findings
            ],
        }
        json.dump(payload, sys.stdout, indent=2)
        sys.stdout.write("\n")

    def _emit_junit(self) -> None:
        total = len(self.findings)
        failures = self.count(Severity.VIOLATION)
        print('<?xml version="1.0" encoding="UTF-8"?>')
        print(f'<testsuite name="openric-validate" tests="{total}" failures="{failures}">')
        for f in self.findings:
            cls = f.check.replace("-", "_")
            print(f'  <testcase classname="{cls}" name="{_xml_escape(f.target) or cls}">')
            if f.severity == Severity.VIOLATION:
                print(f'    <failure message="{_xml_escape(f.message)}"/>')
            elif f.severity == Severity.WARNING:
                print(f'    <system-out>{_xml_escape(f.message)}</system-out>')
            print('  </testcase>')
        print('</testsuite>')


def _xml_escape(s: str) -> str:
    return (s.replace("&", "&amp;").replace("<", "&lt;")
              .replace(">", "&gt;").replace('"', "&quot;"))
