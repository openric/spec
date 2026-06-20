#!/usr/bin/env python3
"""
Internal Markdown link checker for the OpenRiC spec site.

Copyright (C) 2026 Johan Pieterse / Plain Sailing iSystems. AGPL 3.0.

Resolves links the way Jekyll serves them, so we flag genuinely-missing targets
without the false positives the old inline checker produced:
  - ABSOLUTE paths ("/conformance/", "/governance.html") resolve from the SITE
    ROOT, not the linking file's directory;
  - .html ↔ .md siblings (Jekyll renders page.md → page.html);
  - directory targets ("/conformance/") resolve via index.md / index.html /
    README.md (jekyll-readme-index);
  - Liquid-templated targets ("{{ '/x' | relative_url }}") are skipped — they
    can't be resolved statically;
  - external (http/mailto/tel) and pure-anchor (#…) links are skipped.

Internal, non-published trees (docs/, validator/, .venv/, _site/, vendor/,
node_modules/) are not site pages and are not scanned.

Exit 0 = all internal links resolve; exit 1 = at least one is broken.
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SKIP_PARTS = {".venv", "validator", "docs", "node_modules", "_site", "vendor"}
LINK = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")


def resolves(md_file: pathlib.Path, target: str) -> bool:
    if target.startswith(("http://", "https://", "mailto:", "tel:", "#")):
        return True
    if target == "" or "{{" in target or "}}" in target:
        return True

    if target.startswith("/"):
        base, rel = ROOT, target[1:]
    else:
        base, rel = md_file.parent, target
    rel = rel.rstrip("/")
    if rel == "":
        return True  # site root / directory root

    # Collection permalinks: Jekyll serves `_help/<name>.md` at `/help/<name>/`
    # (per _config.yml `collections.help.permalink: /help/:name/`). These have no
    # file at `<root>/help/<name>` on disk, so resolve them against the collection
    # source folder. The collection's own index pages (help/index.html etc.) still
    # resolve via the normal path logic below.
    if target.startswith("/help/"):
        name = target[len("/help/"):].rstrip("/")
        if name and "/" not in name and (ROOT / "_help" / f"{name}.md").exists():
            return True

    b = base / rel
    candidates = [
        b,
        b.with_suffix(".md"),
        b.with_suffix(".html"),
        b / "index.md",
        b / "index.html",
        b / "README.md",
    ]
    if rel.endswith(".html"):
        candidates.append(base / (rel[:-5] + ".md"))
    return any(c.exists() for c in candidates)


def main() -> int:
    md_files = [
        p for p in list(ROOT.rglob("*.md")) + list(ROOT.rglob("*.markdown"))
        if not SKIP_PARTS & set(p.relative_to(ROOT).parts)
    ]
    broken = []
    for p in md_files:
        for m in LINK.finditer(p.read_text(encoding="utf-8", errors="ignore")):
            raw = m.group(2).strip()
            if not raw:
                continue
            target = raw.split()[0].split("#")[0]  # drop "title" and #fragment
            if not resolves(p, target):
                broken.append(f"  {p.relative_to(ROOT)}: [{m.group(1)}] -> {target}")

    if broken:
        print("Broken internal links:")
        print("\n".join(broken))
        return 1
    print(f"Checked {len(md_files)} markdown files — all internal links resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
