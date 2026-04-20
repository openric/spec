#!/usr/bin/env bash
#
# Copyright (C) 2026 Johan Pieterse / Plain Sailing Information Systems
# Email: johan@plainsailingisystems.co.za
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# OpenRiC conformance probe.
# Hits every documented /api/ric/v1/* endpoint and reports which pass,
# which fail, and which are missing entirely.
#
# Usage:
#   ./probe.sh                                              # full surface
#   BASE=https://your.server/api/ric/v1 ./probe.sh
#   KEY=xxxx BASE=... ./probe.sh                            # + write/delete
#   ./probe.sh --profile=core-discovery                     # just that profile
#   PROFILE=core-discovery,graph-traversal ./probe.sh       # multiple
#
# When --profile=PROFILE is set the probe:
#   * runs only probes tagged for the named profile(s) (plus the always-on
#     service-description + health checks);
#   * verifies that `GET /` declares the named profile in
#     `openric_conformance.profiles[].id`;
#   * still counts unlabelled, always-on checks.
#
# Known profile ids:  core-discovery  graph-traversal  authority-context
#                     provenance-event  digital-object-linkage
#                     round-trip-editing  export-only
#
# Exit codes:
#   0 — all required endpoints conformant
#   1 — one or more required endpoints failed
#   2 — misconfigured (missing dependencies, unreachable base, bad args)

set -u

BASE="${BASE:-https://ric.theahg.co.za/api/ric/v1}"
KEY="${KEY:-}"
VERBOSE="${VERBOSE:-0}"
PROFILE="${PROFILE:-}"

# --- argv parsing -----------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile=*) PROFILE="${1#*=}" ;;
    --profile)   shift; PROFILE="${1:-}" ;;
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)
      sed -n '7,32p' "$0"
      exit 0
      ;;
    *)
      echo "probe.sh: unknown argument: $1" >&2
      echo "Try --help" >&2
      exit 2
      ;;
  esac
  shift
done

PASS=0 FAIL=0 SKIP=0
RESULTS=()

command -v curl >/dev/null 2>&1 || { echo "FATAL: curl required"; exit 2; }
command -v jq   >/dev/null 2>&1 || { echo "FATAL: jq required"; exit 2; }

# Colour output if attached to a terminal
if [[ -t 1 ]]; then
  G=$'\033[0;32m'; R=$'\033[0;31m'; Y=$'\033[0;33m'; B=$'\033[0;36m'; Z=$'\033[0m'
else
  G=''; R=''; Y=''; B=''; Z=''
fi

# ---- helpers ----------------------------------------------------

# in_profile <name>
# True if:
#   - no --profile filter is set (run everything), OR
#   - the filter includes <name>.
# Probe blocks gate themselves on this so a single script can serve both
# full-surface and profile-scoped runs without duplicating logic.
in_profile() {
  local p="$1"
  [[ -z "$PROFILE" ]] && return 0
  local IFS=','
  for entry in $PROFILE; do
    [[ "$entry" == "$p" ]] && return 0
  done
  return 1
}

# probe_profile_declared <profile-id>
# Pulls GET / and asserts the named profile appears in
# `openric_conformance.profiles[].id`. Used only when --profile is set.
probe_profile_declared() {
  local expected="$1"
  local tmp; tmp=$(mktemp)
  local code
  code=$(curl -s -o "$tmp" -w '%{http_code}' --max-time 15 \
    -H 'Accept: application/json' "${BASE}/" 2>/dev/null)

  local status="FAIL" colour="$R" label="/ declares profile '${expected}'"
  if [[ "$code" == "200" ]] \
     && jq -e --arg p "$expected" '.openric_conformance.profiles[]?.id | select(. == $p)' \
            <"$tmp" >/dev/null 2>&1; then
    status="PASS"; colour="$G"; PASS=$((PASS+1))
  else
    FAIL=$((FAIL+1))
    [[ "$VERBOSE" == 1 ]] && { echo "  ↳ $(head -c 300 "$tmp")"; echo; }
  fi
  printf '%s%-5s%s  GET  %-50s  [%s]\n' "$colour" "$status" "$Z" "$label" "$code"
  RESULTS+=("$status|GET / declares $expected|$code")
  rm -f "$tmp"
}

# probe_show_first <label> <list-path> <detail-path-prefix>
# Fetches the first item from a list endpoint and probes its detail URL.
# Used for `GET /records/{key}`, `/agents/{key}`, `/repositories/{key}` where
# we don't know a key ahead of time.
probe_show_first() {
  local label="$1" list_path="$2" prefix="$3"
  local first_id
  first_id=$(curl -s --max-time 10 "${BASE}${list_path}?limit=1" \
    | jq -r '(."openric:items" // ."ric:items" // .items // [])[0]["@id"] // empty' 2>/dev/null \
    | sed 's|.*/||')
  if [[ -n "$first_id" ]]; then
    probe "$label" required GET "${prefix}/${first_id}" '.["@id"] != null'
  else
    printf '%s%-5s%s  GET  %-50s  [--]\n' "$Y" "SKIP" "$Z" "${prefix}/{key} (list empty; no key to probe)"
    SKIP=$((SKIP+1))
    RESULTS+=("SKIP|GET ${prefix}/{key}|empty-list")
  fi
}

# probe <label> <required|optional> <method> <path> [jq-check] [body]
probe() {
  local label="$1" reqd="$2" method="$3" path="$4" check="${5:-}" body="${6:-}"
  local url="${BASE}${path}"
  local hdrs=(-H "Accept: application/json")
  [[ -n "$KEY" ]] && hdrs+=(-H "X-API-Key: ${KEY}")

  local tmp; tmp=$(mktemp)
  local code
  if [[ -n "$body" ]]; then
    code=$(curl -s -o "$tmp" -w '%{http_code}' --max-time 15 \
      -X "$method" "${hdrs[@]}" -H 'Content-Type: application/json' -d "$body" "$url" 2>/dev/null)
  else
    code=$(curl -s -o "$tmp" -w '%{http_code}' --max-time 15 \
      -X "$method" "${hdrs[@]}" "$url" 2>/dev/null)
  fi

  local status="FAIL" colour="$R"
  if [[ "$code" =~ ^(200|201|204)$ ]]; then
    if [[ -z "$check" ]] || jq -e "$check" <"$tmp" >/dev/null 2>&1; then
      status="PASS"; colour="$G"; PASS=$((PASS+1))
    else
      status="FAIL (shape)"; FAIL=$((FAIL+1))
    fi
  elif [[ "$code" == "404" && "$reqd" == "optional" ]]; then
    status="SKIP (404)"; colour="$Y"; SKIP=$((SKIP+1))
  elif [[ "$code" == "401" || "$code" == "403" ]]; then
    if [[ -z "$KEY" ]]; then
      status="SKIP (no key)"; colour="$Y"; SKIP=$((SKIP+1))
    else
      status="FAIL (auth)"; FAIL=$((FAIL+1))
    fi
  else
    FAIL=$((FAIL+1))
  fi

  printf '%s%-5s%s  %s %-50s  [%s]\n' "$colour" "$status" "$Z" "$method" "$path" "$code"
  [[ "$VERBOSE" == 1 && "$status" != "PASS" ]] && { echo "  ↳ $(head -c 200 "$tmp")"; echo; }
  RESULTS+=("$status|$method $path|$code")
  rm -f "$tmp"
}

# probe_oai <verb> [extra-args]
probe_oai() {
  local verb="$1" extra="${2:-}"
  local path="/oai?verb=${verb}${extra}"
  local url="${BASE}${path}"
  local tmp; tmp=$(mktemp)
  local code
  code=$(curl -s -o "$tmp" -w '%{http_code}' --max-time 15 "$url" 2>/dev/null)
  local ok="FAIL" colour="$R"
  if [[ "$code" == "200" ]] && grep -q "<OAI-PMH" "$tmp" && ! grep -q "<error code=" "$tmp"; then
    ok="PASS"; colour="$G"; PASS=$((PASS+1))
  else
    FAIL=$((FAIL+1))
  fi
  printf '%s%-5s%s  OAI %-48s  [%s]\n' "$colour" "$ok" "$Z" "$verb" "$code"
  RESULTS+=("$ok|OAI $verb|$code")
  rm -f "$tmp"
}

# ---- header ----------------------------------------------------

echo "${B}OpenRiC conformance probe${Z}"
echo "base:    $BASE"
echo "key:     $([[ -n "$KEY" ]] && echo 'yes (write+delete probes enabled)' || echo 'no  (read-only probes only)')"
echo "profile: $([[ -n "$PROFILE" ]] && echo "$PROFILE" || echo '(all — full-surface probe)')"
echo
echo "----------------------------------------------------------------"

# ---- §0 always-on: service description + health ----------------
#      These run regardless of profile — they're the bare minimum
#      for any conformance claim.

probe "api-info" required GET "/"               '.name'
probe "health"   required GET "/health"         '.status == "ok"'

# If a profile was requested, verify the server declares it.
if [[ -n "$PROFILE" ]]; then
  IFS=',' read -ra REQUESTED_PROFILES <<< "$PROFILE"
  for rp in "${REQUESTED_PROFILES[@]}"; do
    probe_profile_declared "$rp"
  done
fi

# ---- §1 Core Discovery — records, agents, repositories, vocab, autocomplete ----
# Maps to core-discovery.md §2.1 (ten endpoints).

LIST_SHAPE='(."@type" | test("List$")) and ((."ric:items" // ."openric:items") | type == "array")'

if in_profile "core-discovery"; then
  probe "vocabulary"   required GET "/vocabulary"              '."@type" == "ric:Vocabulary"'
  probe "autocomplete" required GET "/autocomplete?q=a&limit=1" '(type == "array") or (.results | type == "array")'

  probe "list-records"      required GET "/records"      "$LIST_SHAPE"
  probe_show_first "show-record" "/records" "/records"

  probe "list-agents"       required GET "/agents"       "$LIST_SHAPE"
  probe_show_first "show-agent" "/agents" "/agents"

  probe "list-repositories" required GET "/repositories" "$LIST_SHAPE"
  probe_show_first "show-repository" "/repositories" "/repositories"
fi

# ---- §2 Authority & Context — places, rules, activities ----
if in_profile "authority-context"; then
  probe "list-places"     required GET "/places"     "$LIST_SHAPE"
  probe "list-rules"      required GET "/rules"      "$LIST_SHAPE"
  probe "list-activities" required GET "/activities" "$LIST_SHAPE"
  probe "places-flat"     optional GET "/places/flat" '.items | type == "array"'
fi

# ---- §3 Digital Object Linkage — instantiations, functions ----
if in_profile "digital-object-linkage"; then
  probe "list-instantiations" required GET "/instantiations" "$LIST_SHAPE"
  probe "list-functions"      optional GET "/functions"      "$LIST_SHAPE"
fi

# ---- §4 Graph Traversal — graph, relation-types, sparql ----
if in_profile "graph-traversal"; then
  probe "relation-types" required GET "/relation-types" '.items | type == "array"'

  # Discover a seed URI for the graph probe. Uses the first place returned
  # (requires Authority & Context on the server to produce a seed; falls back
  # to records if places aren't available).
  SEED_URI=$(curl -s --max-time 10 "${BASE}/places?limit=1" | \
    jq -r '(."openric:items" // ."ric:items" // .items // [])[0]["@id"] // empty' 2>/dev/null || true)
  if [[ -z "$SEED_URI" ]]; then
    SEED_URI=$(curl -s --max-time 10 "${BASE}/records?limit=1" | \
      jq -r '(."openric:items" // ."ric:items" // .items // [])[0]["@id"] // empty' 2>/dev/null || true)
  fi

  if [[ -n "$SEED_URI" ]]; then
    SEED_ENC=$(printf '%s' "$SEED_URI" | jq -sRr @uri)
    probe "graph-seed" required GET "/graph?uri=${SEED_ENC}&depth=1" '."@type" == "openric:Subgraph"'
  else
    printf '%s%-5s%s  GET  %-50s  [--]\n' "$Y" "SKIP" "$Z" "/graph (no seed URI available)"
    SKIP=$((SKIP+1))
    RESULTS+=("SKIP|GET /graph|no-seed")
  fi

  probe "sparql (experimental)" optional GET "/sparql?query=SELECT%20*%20WHERE%20{%20?s%20?p%20?o%20}%20LIMIT%201" '.'
fi

# ---- §5 Export-Only (OAI-PMH) ----
if in_profile "export-only"; then
  probe_oai "Identify"
  probe_oai "ListMetadataFormats"
  probe_oai "ListSets"
  probe_oai "ListIdentifiers" "&metadataPrefix=oai_dc"
  probe_oai "ListRecords"     "&metadataPrefix=oai_dc"
fi

# ---- §6 Round-Trip Editing — write surface (needs KEY) ----
# Write probes only run when KEY is set AND round-trip-editing is in-profile.

if [[ -n "$KEY" ]] && in_profile "round-trip-editing"; then
  # Create a throwaway Place, read it back, update it, delete it.
  CREATED=$(curl -s -X POST "${BASE}/places" -H "X-API-Key: $KEY" \
    -H 'Content-Type: application/json' \
    -d '{"name":"Conformance probe place","description":"delete me"}')
  NEW_ID=$(echo "$CREATED" | jq -r '.id // empty')
  if [[ -n "$NEW_ID" ]]; then
    printf '%s%-5s%s  POST %-49s  [%s]\n' "$G" "PASS" "$Z" "/places (created id=$NEW_ID)" "201"
    PASS=$((PASS+1))
    probe "show-place"   required GET "/places/${NEW_ID}"                   '.["@id"] != null'
    probe "update-place" required PATCH "/places/${NEW_ID}"                 '.success == true' '{"description":"updated by probe"}'
    probe "delete-place" required DELETE "/places/${NEW_ID}"                '.success == true'
  else
    printf '%s%-5s%s  POST %-49s  [FAIL]\n' "$R" "FAIL" "$Z" "/places (create)"
    echo "  ↳ $(echo "$CREATED" | head -c 200)"
    FAIL=$((FAIL+1))
  fi

  probe "create-agent-probe"  required POST "/agents" '.id != null' '{"name":"Conformance Probe Agent"}'
  AGENT_ID=$(curl -s -X POST "${BASE}/agents" -H "X-API-Key: $KEY" \
    -H 'Content-Type: application/json' -d '{"name":"Probe Agent 2"}' | jq -r '.id // empty')
  [[ -n "$AGENT_ID" ]] && probe "delete-agent-probe" required DELETE "/agents/${AGENT_ID}" '.success == true'

  probe "create-record-probe" required POST "/records" '.id != null' '{"title":"Conformance probe record"}'
  REC_ID=$(curl -s -X POST "${BASE}/records" -H "X-API-Key: $KEY" \
    -H 'Content-Type: application/json' -d '{"title":"Probe Record 2"}' | jq -r '.id // empty')
  [[ -n "$REC_ID" ]] && probe "delete-record-probe" required DELETE "/records/${REC_ID}" '.success == true'

  # ---- §7 scope enforcement -------------------------------------
  # If READ_KEY is set, verify that a read-only-scoped key gets 403 on write
  # routes. Catches regressions in the auth middleware scope gate.
  if [[ -n "${READ_KEY:-}" ]]; then
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 \
      -X POST "${BASE}/places" \
      -H "X-API-Key: $READ_KEY" -H 'Content-Type: application/json' \
      -d '{"name":"Should be rejected — read-only key"}')
    if [[ "$code" == "403" ]]; then
      printf '%s%-5s%s  POST %-49s  [%s]\n' "$G" "PASS" "$Z" "/places (read-only key → 403)" "$code"
      PASS=$((PASS+1))
    else
      printf '%s%-5s%s  POST %-49s  [%s]\n' "$R" "FAIL" "$Z" "/places (read-only key should have been 403)" "$code"
      FAIL=$((FAIL+1))
    fi
  else
    printf '%s%-5s%s  POST %-49s  [--]\n' "$Y" "SKIP" "$Z" "/places scope enforcement (READ_KEY not set)"
    SKIP=$((SKIP+1))
  fi
fi

# ---- summary ---------------------------------------------------

echo "----------------------------------------------------------------"
echo "${B}Summary${Z}: ${G}${PASS} pass${Z}, ${R}${FAIL} fail${Z}, ${Y}${SKIP} skip${Z}"
echo

if [[ $FAIL -gt 0 ]]; then
  echo "${R}✗ Non-conformant.${Z} Failing endpoints:"
  for r in "${RESULTS[@]}"; do
    status="${r%%|*}"; rest="${r#*|}"
    if [[ "$status" == FAIL* ]]; then
      echo "  - $rest"
    fi
  done
  exit 1
fi

echo "${G}✓ Conformant.${Z} This server implements the required OpenRiC surface."
exit 0
