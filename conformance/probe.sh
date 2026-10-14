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
#   ./probe.sh --profile=core-discovery --json=result.json  # + machine-readable result
#
# --json writes the run as JSON (schema openric-probe-result/1): when, against
# which server, which probe revision, the service's own declarations, counts,
# a verdict, and every check. Without KEY the probe is read-only, and checks
# that need a key are reported as skipped - never as passed.
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
JSON_OUT="${JSON_OUT:-}"

# --- argv parsing -----------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile=*) PROFILE="${1#*=}" ;;
    --profile)   shift; PROFILE="${1:-}" ;;
    --json=*)    JSON_OUT="${1#*=}" ;;
    --json)      shift; JSON_OUT="${1:-}" ;;
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)
      sed -n '7,38p' "$0"
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
  probe_show_first "show-place"    "/places"     "/places"
  probe "list-rules"      required GET "/rules"      "$LIST_SHAPE"
  probe_show_first "show-rule"     "/rules"      "/rules"
  probe "list-activities" required GET "/activities" "$LIST_SHAPE"
  probe_show_first "show-activity" "/activities" "/activities"
  probe "places-flat"     optional GET "/places/flat" '.items | type == "array"'
fi

# ---- §3 Digital Object Linkage — instantiations, functions ----
if in_profile "digital-object-linkage"; then
  probe "list-instantiations" required GET "/instantiations" "$LIST_SHAPE"
  probe_show_first "show-instantiation" "/instantiations" "/instantiations"
  probe "list-functions"      optional GET "/functions"      "$LIST_SHAPE"
  probe_show_first "show-function"      "/functions"      "/functions"
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

  # SPARQL probe — URL-encode the query body via jq @uri to avoid curl
  # globbing the `{...}` and to escape `?` in variables (`?s ?p ?o`).
  # Asserts canonical SPARQL Results JSON shape (head.vars is an array)
  # so a server wrapping the result in a non-canonical envelope is
  # caught here, not silently passed.
  SPARQL_Q=$(printf '%s' 'SELECT * WHERE { ?s ?p ?o } LIMIT 1' | jq -sRr @uri)
  probe "sparql (experimental)" optional GET "/sparql?query=${SPARQL_Q}" '(.head.vars | type) == "array"'

  # SPARQL dataset description — void:Dataset endpoint at /sparql/info.
  # Optional because sparql-access is a Draft profile; servers without
  # SPARQL legitimately 404 here.
  probe "sparql-info"           optional GET "/sparql/info"          '.'
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
# Follows round-trip-editing.md §6. Never point this at a production service:
# it creates, changes and deletes data. Run it against a disposable server.
#
#   KEY             write + delete scopes (required for this section)
#   WRITE_ONLY_KEY  write scope only - checks a delete is refused (§6.7)
#
# Covered: §6.1-6.4 for places, create/delete for agents and records, §6.6,
# §6.7 (with WRITE_ONLY_KEY) and §6.9. Not yet covered: §6.5 for the other
# entity types and relations, and §6.8 (409 on a referential conflict).

# record <status> <label> <http-code>: one custom check into the counters.
record() {
  local status="$1" label="$2" code="$3" colour="$R"
  case "$status" in
    PASS) colour="$G"; PASS=$((PASS+1)) ;;
    SKIP*) colour="$Y"; SKIP=$((SKIP+1)) ;;
    *) FAIL=$((FAIL+1)) ;;
  esac
  printf '%s%-5s%s  %-59s  [%s]\n' "$colour" "${status%% *}" "$Z" "$label" "$code"
  RESULTS+=("$status|$label|$code")
}

# http <method> <path> [key] [body]: prints "<code> <body>".
http() {
  local method="$1" path="$2" key="${3:-}" body="${4:-}" out
  local args=(-s -w '\n%{http_code}' --max-time 15 -X "$method" -H 'Accept: application/json')
  [[ -n "$key" ]] && args+=(-H "X-API-Key: ${key}")
  [[ -n "$body" ]] && args+=(-H 'Content-Type: application/json' -d "$body")
  out=$(curl "${args[@]}" "${BASE}${path}" 2>/dev/null)
  printf '%s %s' "${out##*$'\n'}" "${out%$'\n'*}"
}

if [[ -n "$KEY" ]] && in_profile "round-trip-editing"; then
  # §6.6 - a write without a key is refused.
  read -r code _ <<<"$(http POST /places "" '{"name":"Probe place without a key"}')"
  [[ "$code" == "401" ]] && record PASS "POST /places without a key is 401 (§6.6)" "$code" \
                         || record "FAIL" "POST /places without a key is 401 (§6.6)" "$code"

  # §6.9 - a body that fails validation is refused.
  read -r code _ <<<"$(http POST /places "$KEY" '{}')"
  [[ "$code" == "422" ]] && record PASS "POST /places with no name is 422 (§6.9)" "$code" \
                         || record "FAIL" "POST /places with no name is 422 (§6.9)" "$code"

  # §6.1 - create, and the href resolves.
  read -r code body <<<"$(http POST /places "$KEY" '{"name":"Conformance probe place","description":"created by the probe"}')"
  NEW_ID=$(jq -r '.id // empty' <<<"$body" 2>/dev/null)
  HREF=$(jq -r '.href // empty' <<<"$body" 2>/dev/null)
  if [[ "$code" == "201" && -n "$NEW_ID" ]]; then
    record PASS "POST /places creates, with an id (§6.1)" "$code"
    if [[ -n "$HREF" ]]; then
      read -r hcode _ <<<"$(http GET "${HREF#*/api/ric/v1}")"
      [[ "$hcode" == "200" ]] && record PASS "the create envelope's href resolves (§6.1)" "$hcode" \
                              || record "FAIL" "the create envelope's href resolves (§6.1)" "$hcode"
    fi

    # §6.2 - update, and the change is visible.
    read -r code body <<<"$(http PATCH "/places/${NEW_ID}" "$KEY" '{"description":"updated by the probe"}')"
    [[ "$code" == "200" ]] && jq -e '.success == true' <<<"$body" >/dev/null 2>&1 \
      && record PASS "PATCH /places/{id} succeeds (§6.2)" "$code" \
      || record "FAIL" "PATCH /places/{id} succeeds (§6.2)" "$code"
    read -r code body <<<"$(http GET "/places/${NEW_ID}")"
    grep -q "updated by the probe" <<<"$body" \
      && record PASS "GET /places/{id} shows the update (§6.2)" "$code" \
      || record "FAIL" "GET /places/{id} shows the update (§6.2)" "$code"

    # §6.7 - a write-only key cannot delete.
    if [[ -n "${WRITE_ONLY_KEY:-}" ]]; then
      read -r code _ <<<"$(http DELETE "/places/${NEW_ID}" "$WRITE_ONLY_KEY")"
      [[ "$code" == "403" ]] && record PASS "DELETE with a write-only key is 403 (§6.7)" "$code" \
                             || record "FAIL" "DELETE with a write-only key is 403 (§6.7)" "$code"
    else
      record "SKIP (no WRITE_ONLY_KEY)" "DELETE with a write-only key is 403 (§6.7)" "--"
    fi

    # §6.3 - delete, then the entity is gone.
    read -r code body <<<"$(http DELETE "/places/${NEW_ID}" "$KEY")"
    [[ "$code" == "200" ]] && jq -e '.success == true' <<<"$body" >/dev/null 2>&1 \
      && record PASS "DELETE /places/{id} succeeds (§6.3)" "$code" \
      || record "FAIL" "DELETE /places/{id} succeeds (§6.3)" "$code"
    read -r code _ <<<"$(http GET "/places/${NEW_ID}")"
    [[ "$code" == "404" ]] && record PASS "GET /places/{id} after delete is 404 (§6.3)" "$code" \
                           || record "FAIL" "GET /places/{id} after delete is 404 (§6.3)" "$code"

    # §6.4 - the revision list shows create, update and delete.
    read -r code body <<<"$(http GET "/places/${NEW_ID}/revisions")"
    if [[ "$code" == "200" ]] && jq -e '."@type" == "openric:RevisionList"
          and ([.items[].action] | (index("create") != null and index("update") != null and index("delete") != null))' \
          <<<"$body" >/dev/null 2>&1; then
      record PASS "revisions list create, update and delete (§6.4)" "$code"
    else
      record "FAIL" "revisions list create, update and delete (§6.4)" "$code"
    fi
  else
    record "FAIL" "POST /places creates, with an id (§6.1)" "$code"
  fi

  # §6.5, partly - the same create and delete for agents and records.
  for t in agents records; do
    case "$t" in agents) b='{"name":"Conformance probe agent"}' ;; records) b='{"title":"Conformance probe record"}' ;; esac
    read -r code body <<<"$(http POST "/$t" "$KEY" "$b")"
    id=$(jq -r '.id // empty' <<<"$body" 2>/dev/null)
    if [[ "$code" == "201" && -n "$id" ]]; then
      record PASS "POST /$t creates (§6.5)" "$code"
      read -r code body <<<"$(http DELETE "/$t/${id}" "$KEY")"
      [[ "$code" == "200" ]] && record PASS "DELETE /$t/{id} succeeds (§6.5)" "$code" \
                             || record "FAIL" "DELETE /$t/{id} succeeds (§6.5)" "$code"
    else
      record "FAIL" "POST /$t creates (§6.5)" "$code"
    fi
  done
elif in_profile "round-trip-editing"; then
  # Without a key the write surface cannot be tested. Record that as skipped,
  # so a read-only run never reports Round-Trip Editing as a plain pass.
  printf '%s%-5s%s  %-54s  [--]\n' "$Y" "SKIP" "$Z" "create/update/delete round trip (no KEY; read-only run)"
  SKIP=$((SKIP+1))
  RESULTS+=("SKIP|create/update/delete round trip|no-key")
fi

# ---- summary ---------------------------------------------------

# write_json <verdict>: the run as JSON, for the published conformance matrix.
write_json() {
  [[ -z "$JSON_OUT" ]] && return 0
  local svc writes
  svc=$(curl -s --max-time 15 -H 'Accept: application/json' "${BASE}/" 2>/dev/null \
    | jq -c '{name, version, spec_version: .openric_conformance.spec_version,
              declared: [.openric_conformance.profiles[]? | {id, version, conformance}]}' 2>/dev/null)
  [[ -z "$svc" ]] && svc=null
  [[ -n "$KEY" ]] && writes=true || writes=false
  printf '%s\n' "${RESULTS[@]}" | jq -R -s \
    --arg base "$BASE" --arg profile "$PROFILE" --arg verdict "$1" \
    --arg run_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg probe_revision "${PROBE_REVISION:-unknown}" \
    --argjson pass "$PASS" --argjson fail "$FAIL" --argjson skip "$SKIP" \
    --argjson writes "$writes" --argjson service "$svc" \
    '{schema: "openric-probe-result/1", run_at: $run_at, probe_revision: $probe_revision,
      base: $base, profiles: ($profile | split(",") | map(select(length > 0))),
      writes_attempted: $writes, verdict: $verdict,
      counts: {pass: $pass, fail: $fail, skip: $skip}, service: $service,
      results: (split("\n") | map(select(length > 0))
                | map(split("|") | {status: .[0], check: .[1], http: .[2]}))}' > "$JSON_OUT"
}

# pass: nothing failed and nothing skipped. pass-with-skips: nothing failed,
# but some checks did not run (usually because there was no key).
if [[ $FAIL -gt 0 ]]; then write_json fail
elif [[ $SKIP -gt 0 ]]; then write_json pass-with-skips
else write_json pass
fi

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
