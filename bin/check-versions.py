#!/usr/bin/env python3
#
# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
#
# This file is part of OpenRiC. Licensed under AGPL-3.0-or-later.
#
# Version-drift guard.
#
# OpenRiC sells a precise, testable conformance contract, so contradictory
# version claims across its own pages are a credibility problem, not a typo.
# In September 2026 the site carried three generations at once - 0.43.10 in
# version.json, v0.37.0 on the home and spec pages, and v0.2.0 plus retired
# L1-L4 conformance wording on governance and for-institutions.
#
# Design note: this does NOT flag every semantic version it finds. Doing that
# drowns in false positives - CIDOC-CRM 7.1.3, Node 18.14.1, per-profile
# versions, sample API payloads and the legitimate roadmap history are all
# version strings that have nothing to do with the spec's current version.
#
# Instead it checks three narrow things:
#   1. version.json and its _data mirror agree
#   2. the README banner (outside the Jekyll build, so it cannot use Liquid)
#      states the current version
#   3. any line making a CURRENCY CLAIM states the current version, or renders
#      it from site data
# plus a global ban on the retired L1-L4 conformance vocabulary.

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

# Files and directories that are historical by purpose. A changelog is
# supposed to name old versions.
HISTORICAL_FILES = {"CHANGELOG.md", "drift-log.md", "SETUP_GITHUB.md"}
HISTORICAL_DIRS = {"docs", "audit", "node_modules", "validator", "_site", "vendor"}

# Phrases that assert "this is the current version". A version string on one
# of these lines must be the current one.
CURRENCY_CLAIM = re.compile(
    r"is current"
    r"|Current version"
    r"|Current tagged release"
    r"|currently tracking"
    r"|OpenRiC is at"
    r"|hero-eyebrow"
    r"|\| \*\*Specification\*\*"
    r"|Base spec \("
    r"|publicly claim"
    r"|claims? conformance to",
    re.IGNORECASE,
)

# Retired conformance vocabulary. OpenRiC moved to named profiles, so L1-L4
# must not be presented as the current framing. Naming it while explicitly
# flagging it as superseded is correct and stays allowed - the `level` field
# still exists in responses and still needs documenting.
RETIRED = re.compile(r"\bL1\s*-\s*L4\b|\bopenric:L[1-4]\b")
RETIRED_OK = re.compile(
    r"legacy|historical|deprecated|superseded|retained|no longer", re.IGNORECASE
)

VERSION_RE = re.compile(r"\bv?(\d+\.\d+\.\d+)\b")

README_BANNER = re.compile(
    r"^\*\*v(\d+\.\d+\.\d+)\*\* — (\d{4}-\d{2}-\d{2})\. The canonical", re.MULTILINE
)


def load_version():
    root_file = ROOT / "version.json"
    data_file = ROOT / "_data" / "version.json"

    if not root_file.exists():
        sys.exit("version.json is missing - it is the source of truth")
    if not data_file.exists():
        sys.exit("_data/version.json is missing - the site renders from it")

    root = json.loads(root_file.read_text())
    data = json.loads(data_file.read_text())

    if root != data:
        sys.exit(
            "version.json and _data/version.json disagree.\n"
            "  bin/release writes both; neither should be edited by hand.\n"
            f"  root:  {root}\n"
            f"  _data: {data}"
        )
    return root["version"], root["release_date"]


def is_exempt(rel: str) -> bool:
    parts = pathlib.PurePath(rel).parts
    for part in parts[:-1]:
        if part in HISTORICAL_DIRS or part.startswith("."):
            return True
    return rel in HISTORICAL_FILES


def check_readme(current: str, released: str, problems: list) -> None:
    readme = ROOT / "README.md"
    if not readme.exists():
        return
    match = README_BANNER.search(readme.read_text(encoding="utf-8"))
    if not match:
        problems.append(
            "  README.md has no recognisable current-version banner.\n"
            "      bin/release rewrites the line starting '**vX.Y.Z** — DATE. The canonical'"
        )
        return
    if match.group(1) != current or match.group(2) != released:
        problems.append(
            f"  README.md banner states v{match.group(1)} ({match.group(2)}),"
            f" current is v{current} ({released})"
        )


def main() -> int:
    current, released = load_version()
    problems: list = []

    check_readme(current, released, problems)

    for path in sorted(ROOT.rglob("*")):
        if not path.is_file() or path.suffix not in {".md", ".html"}:
            continue

        rel = str(path.relative_to(ROOT))
        if is_exempt(rel):
            continue

        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, PermissionError):
            continue

        for lineno, line in enumerate(text.splitlines(), 1):
            if RETIRED.search(line) and not RETIRED_OK.search(line):
                problems.append(
                    f"  {rel}:{lineno} presents L1-L4 conformance as current\n"
                    f"      {line.strip()[:110]}\n"
                    "      Use the profile-based model, or mark it legacy explicitly."
                )

            if not CURRENCY_CLAIM.search(line):
                continue
            # A page that renders the value from site data is always correct.
            if "site.data.version" in line:
                continue
            for found in VERSION_RE.findall(line):
                if found != current:
                    problems.append(
                        f"  {rel}:{lineno} claims v{found} is current, but version.json says v{current}\n"
                        f"      {line.strip()[:110]}"
                    )

    if problems:
        print(f"Version drift against version.json (v{current}):\n")
        print("\n".join(problems))
        print(
            "\nFix by rendering the value instead of typing it:"
            "\n  {{ site.data.version.version }}"
            "\nIf the reference is genuinely historical, move it into CHANGELOG.md"
            "\nor drift-log.md, or reword it so it makes no currency claim."
        )
        return 1

    print(f"  OK - every currency claim agrees with version.json (v{current})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
