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
#      (a bare "**Version:**" or "**Spec version:**" document header counts as
#      one - use "Last revised in:" for a document on an earlier release)
# plus a global ban on the retired L1-L4 conformance vocabulary.

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

# Files and directories that are historical by purpose. A changelog is
# supposed to name old versions.
HISTORICAL_FILES = {"CHANGELOG.md", "drift-log.md", "SETUP_GITHUB.md", "CLAUDE.md"}
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
    r"|claims? conformance to"
    # A bare document header. A reader takes "Version: 0.37.0" at the top of
    # a spec page as the current release, so a document that last changed in
    # an earlier release says "Last revised in: v0.37.0" instead.
    r"|^\*\*(Spec )?Version:\*\*",
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

INVENTORY_FILE = ROOT / "_data" / "inventory.json"
PROFILES_FILE = ROOT / "_data" / "profiles.json"

NUMBER_WORDS = {
    w: i for i, w in enumerate(
        "zero one two three four five six seven eight nine ten eleven twelve"
        " thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty".split()
    )
}

# A count of profiles, schemas or fixtures typed into prose. It must match the
# inventory unless the line renders it ({{ ... }}) or is plainly historical.
# Narrow on purpose, like CURRENCY_CLAIM: per-profile fixture lists ("these
# seven fixtures are normative for X"), "at least one profile" and version
# strings such as 0.1.0-draft are not inventory claims and must not match.
_N = r"(?<![\d.])(\d+|" + "|".join(NUMBER_WORDS) + r")"
COUNT_CLAIM = re.compile(
    _N + r"(?:\s+|-(?=case))"
    r"(normative(?!\s+documents?)|draft(?=\b(?:\s+profiles?|\s*[),.;|]|$))"
    r"|(?:named |conformance )?profiles|(?:JSON )?schemas"
    r"|case(?=\s+(?:conformance|fixture))|cases(?=\s+cover|\b(?:\s*[),.;|]|$))|(?:input/output )?pairs)\b",
    re.IGNORECASE,
)
FIXTURE_TOTAL = re.compile(r"\ball " + _N + r" (fixtures)\b", re.IGNORECASE)
COUNT_KIND = {
    "normative": "normative", "draft": "draft", "profile": "profile",
    "schema": "schema", "fixture": "fixture", "case": "fixture", "pair": "fixture",
}
# Legacy level rows, roadmap history and "Earlier, vX" notes name the counts
# of their time. Roadmap cards in HTML can opt out with <!-- count-history -->.
COUNT_HISTORY_OK = re.compile(
    r"\bL2-(?:core|graph|full)\b|\bv\d+\.\d+\.x\b|^Earlier, v|count-history", re.IGNORECASE
)

RELATIVE_TIME = re.compile(
    r"\b(?:\w+ (?:days?|weeks?|months?) ago|last (?:week|month|quarter)|"
    r"this (?:week|month|quarter)|next (?:week|month|quarter)|yesterday|recently)\b",
    re.IGNORECASE,
)

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


def compute_inventory() -> dict:
    """Count what the repository actually holds. bin/release writes this to
    _data/inventory.json so pages can render the numbers instead of typing them."""
    manifest = json.loads((ROOT / "fixtures" / "manifest.json").read_text())
    statuses = [f.get("status") for f in manifest["fixtures"]]
    return {
        "schemas": len(list((ROOT / "schemas").glob("*.schema.json"))),
        "fixtures": statuses.count("done"),
        "fixtures_planned": statuses.count("planned"),
    }


def check_inventory(problems: list) -> dict:
    expected = compute_inventory()
    if not INVENTORY_FILE.exists():
        problems.append("  _data/inventory.json is missing - run bin/check-versions.py --write-inventory")
    elif json.loads(INVENTORY_FILE.read_text()) != expected:
        problems.append(
            "  _data/inventory.json is out of date - run bin/check-versions.py --write-inventory\n"
            f"      file:   {INVENTORY_FILE.read_text().strip()}\n"
            f"      actual: {json.dumps(expected)}"
        )
    return expected


def check_profiles(problems: list) -> list:
    """_data/profiles.json is the profile inventory. Every profile page must
    have an entry, and the page's own header must agree with it."""
    profiles = json.loads(PROFILES_FILE.read_text())
    by_id = {p["id"]: p for p in profiles}
    pages = {p.stem: p for p in (ROOT / "spec" / "profiles").glob("*.md") if p.stem != "index"}

    for missing in sorted(set(pages) - set(by_id)):
        problems.append(f"  spec/profiles/{missing}.md has no entry in _data/profiles.json")
    for extra in sorted(set(by_id) - set(pages)):
        problems.append(f"  _data/profiles.json lists '{extra}' but spec/profiles/{extra}.md does not exist")

    for pid in sorted(set(pages) & set(by_id)):
        entry, text = by_id[pid], pages[pid].read_text(encoding="utf-8")
        header = {
            "status": re.search(r"^\*\*Status:\*\*\s*\**(\w+)", text, re.MULTILINE),
            "version": re.search(r"^\*\*Profile version:\*\*\s*(\S+)", text, re.MULTILINE),
            "revised": re.search(r"^\*\*Last revised in spec:\*\*\s*v?(\S+)", text, re.MULTILINE),
        }
        for field, match in header.items():
            found = match.group(1).lower() if match and field == "status" else (match.group(1) if match else None)
            if found != entry[field]:
                problems.append(
                    f"  spec/profiles/{pid}.md header {field} is {found!r}, _data/profiles.json says {entry[field]!r}"
                )
    return profiles


def check_profile_artefacts(profiles: list, problems: list) -> None:
    """Every artefact that names profiles must agree with _data/profiles.json:
    the fixture manifest's profile list and tags, the fixture folders, and the
    SHACL shapes. A normative profile needs at least one done fixture and its
    own shape file; a draft may still lack them."""
    ids = {p["id"] for p in profiles}
    manifest = json.loads((ROOT / "fixtures" / "manifest.json").read_text())
    declared = set(manifest.get("profile_ids", []))
    fixtures = manifest["fixtures"]

    for missing in sorted(ids - declared):
        problems.append(f"  fixtures/manifest.json profile_ids lacks '{missing}'")
    for extra in sorted(declared - ids - {"always-on"}):
        problems.append(f"  fixtures/manifest.json profile_ids has '{extra}', which is not a profile")
    for f in fixtures:
        for tag in f.get("profiles", []):
            if tag not in declared:
                problems.append(f"  fixture '{f['name']}' is tagged '{tag}', which profile_ids does not list")

    folders = {p.name for p in (ROOT / "fixtures").iterdir() if p.is_dir()}
    registered = {f["name"] for f in fixtures}
    for name in sorted(folders - registered):
        problems.append(f"  fixtures/{name}/ exists but is not registered in fixtures/manifest.json")
    for f in fixtures:
        if f.get("status") == "done" and f["name"] not in folders:
            problems.append(f"  fixture '{f['name']}' is marked done but fixtures/{f['name']}/ does not exist")

    for p in profiles:
        if p["status"] != "normative":
            continue
        if not any(p["id"] in f.get("profiles", []) and f.get("status") == "done" for f in fixtures):
            problems.append(f"  normative profile '{p['id']}' has no done fixture")
        if not (ROOT / "shapes" / "profiles" / f"{p['id']}.shacl.ttl").exists():
            problems.append(f"  normative profile '{p['id']}' has no shapes/profiles/{p['id']}.shacl.ttl")


def count_value(token: str):
    return int(token) if token.isdigit() else NUMBER_WORDS.get(token.lower())


def check_drift_log(problems: list) -> None:
    """The drift log's "Last updated" date must not be older than the newest
    dated entry inside it."""
    path = ROOT / "drift-log.md"
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    stamp = re.search(r"\*\*Last updated:\*\*\s*(\d{4}-\d{2}-\d{2})", text)
    if not stamp:
        problems.append("  drift-log.md has no '**Last updated:** YYYY-MM-DD' line")
        return
    newest = max(re.findall(r"\b(20\d\d-\d\d-\d\d)\b", text))
    if newest > stamp.group(1):
        problems.append(
            f"  drift-log.md says Last updated {stamp.group(1)} but contains an entry dated {newest}"
        )


def main() -> int:
    if "--write-inventory" in sys.argv:
        INVENTORY_FILE.write_text(json.dumps(compute_inventory(), indent=2) + "\n")
        print(f"  wrote {INVENTORY_FILE.relative_to(ROOT)}")
        return 0

    current, released = load_version()
    problems: list = []

    check_readme(current, released, problems)
    inventory = check_inventory(problems)
    profiles = check_profiles(problems)
    check_profile_artefacts(profiles, problems)
    check_drift_log(problems)
    expected_counts = {
        "normative": sum(p["status"] == "normative" for p in profiles),
        "draft": sum(p["status"] == "draft" for p in profiles),
        "profile": len(profiles),
        "schema": inventory["schemas"],
        "fixture": inventory["fixtures"],
    }

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

            if RELATIVE_TIME.search(line):
                problems.append(
                    f"  {rel}:{lineno} uses a relative time that will go stale\n"
                    f"      {line.strip()[:110]}\n"
                    "      State the date instead."
                )

            # Only typed counts matter; a count rendered from site data is right by construction.
            typed = re.sub(r"\{\{.*?\}\}", "", line)
            if not COUNT_HISTORY_OK.search(line):
                for token, noun in COUNT_CLAIM.findall(typed) + FIXTURE_TOTAL.findall(typed):
                    kind = COUNT_KIND[noun.lower().split()[-1].rstrip("s")]
                    value = count_value(token)
                    if value is not None and value != expected_counts[kind]:
                        problems.append(
                            f"  {rel}:{lineno} says {token} {noun}, the inventory says {expected_counts[kind]}\n"
                            f"      {line.strip()[:110]}\n"
                            "      Render it from site.data.profiles / site.data.inventory."
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
