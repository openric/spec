#!/usr/bin/env bash
#
# Copyright (C) 2026 Johan Pieterse
# Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
#
# This file is part of OpenRiC. Licensed under AGPL-3.0-or-later.
#
# Runs the getting-started guide's sandbox commands exactly as published -
# every bash block between <!-- ci:sandbox:start --> and <!-- ci:sandbox:end -->
# - against a running minimal server, and fails if any command fails or the
# writes did not return ids. Run from the repository root, with the minimal
# server on localhost:8080 (CI starts it), or set GUIDE_BASE.

set -euo pipefail
GUIDE=guides/getting-started.md
SCRIPT=$(mktemp)

awk '
  /<!-- ci:sandbox:start -->/ { on = 1; next }
  /<!-- ci:sandbox:end -->/   { on = 0; next }
  on && /^```bash/ { code = 1; next }
  on && /^```/     { code = 0; next }
  on && code       { print }
' "$GUIDE" > "$SCRIPT"

test -s "$SCRIPT" || { echo "no sandbox commands found in $GUIDE"; exit 1; }

# GUIDE_BASE points the published commands at another port, for local runs.
if [ -n "${GUIDE_BASE:-}" ]; then
    sed -i "s|http://localhost:8080|${GUIDE_BASE}|g" "$SCRIPT"
fi

cat >> "$SCRIPT" <<'CHECKS'
[[ "$AGENT_ID" =~ ^[0-9]+$ ]] || { echo "agent create returned no id: $AGENT_ID"; exit 1; }
[[ "$REC_ID" =~ ^[0-9]+$ ]] || { echo "record create returned no id: $REC_ID"; exit 1; }
gone=$(curl -s -o /dev/null -w '%{http_code}' "$OPENRIC_BASE/records/$REC_ID")
[ "$gone" = 404 ] || { echo "record $REC_ID still there after delete ($gone)"; exit 1; }
echo "getting-started sandbox commands: all ran"
CHECKS

bash -euo pipefail "$SCRIPT"
rm -f "$SCRIPT"
