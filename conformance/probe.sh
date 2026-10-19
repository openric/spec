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
#   PE_MAX=50 ./probe.sh --profile=provenance-event         # activities to read (25)
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

# Graph Primitives section 6, invariant 5: every node type is a RiC-O 1.1
# class or an OpenRiC extension class. Class local names, taken from
# RiC-O_1-1.rdf (107 owl:Class) and https://openric.org/ns/ext/v1.ttl.
RICO_CLASSES="
  AccumulationRelation Activity ActivityDocumentationRelation ActivityType
  Agent AgentControlRelation AgentHierarchicalRelation AgentName
  AgentTemporalRelation AgentToAgentRelation Appellation AppellationRelation
  AuthorityRelation AuthorshipRelation CarrierExtent CarrierType
  ChildRelation Concept ContentType Coordinates CorporateBody
  CorporateBodyType CorrespondenceRelation CreationRelation Date DateType
  DemographicGroup DerivationRelation DescendanceRelation
  DocumentaryFormType Event EventRelation EventType Extent ExtentType Family
  FamilyRelation FamilyType FunctionalEquivalenceRelation Group
  GroupSubdivisionRelation Identifier IdentifierType Instantiation
  InstantiationExtent InstantiationToInstantiationRelation
  IntellectualPropertyRightsRelation KnowingOfRelation KnowingRelation
  Language LeadershipRelation LegalStatus ManagementRelation Mandate
  MandateRelation MandateType Mechanism MembershipRelation MigrationRelation
  Name OccupationType OrganicOrFunctionalProvenanceRelation
  OrganicProvenanceRelation OwnershipRelation PerformanceRelation Person
  PhysicalLocation Place PlaceName PlaceRelation PlaceType Position
  PositionHoldingRelation PositionToGroupRelation ProductionTechniqueType
  Proxy Record RecordPart RecordResource RecordResourceExtent
  RecordResourceGeneticRelation RecordResourceHoldingRelation
  RecordResourceToInstantiationRelation
  RecordResourceToRecordResourceRelation RecordSet RecordSetType RecordState
  Relation RepresentationType RoleType Rule RuleRelation RuleType
  SequentialRelation SiblingRelation SpouseRelation StudyAtRelation
  TeachingRelation TemporalRelation Thing Title TitleType Type TypeRelation
  UnitOfMeasurement WholePartRelation WorkRelation
"
OPENRICX_CLASSES="
  ActivityList AgentList Checksum ContactPoint DateRange DateRangeSet
  Function FunctionList InstantiationList PlaceList RecordList RecordSetList
  RepositoryList RuleList
"
# One space-separated line with a space at each end, so " Name " matches.
RICO_CLASSES=" $(printf '%s ' $RICO_CLASSES)"
OPENRICX_CLASSES=" $(printf '%s ' $OPENRICX_CLASSES)"

# node_types <subgraph-json>: one node type per line.
node_types() {
  printf '%s' "$1" | jq -r '(."openric:nodes" // .nodes // [])[].type // "(none)"' 2>/dev/null || true
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

# Core Discovery 0.4.0 §3.3: openric:items plus integer total, page and limit.
LIST_SHAPE='(."@type" | test("List$")) and (."openric:items" | type == "array") and ([."openric:total", ."openric:page", ."openric:limit"] | all(type == "number"))'

if in_profile "core-discovery"; then
  probe "vocabulary"   required GET "/vocabulary"              '.classes | type == "array"'
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

# ---- §2b Provenance & Event - activity bodies (provenance-event.md §6) ----
# Read-only. Checks the list and up to PE_MAX activities (default 25) against
# §6 rules 1-6 in jq, which approximates the profile's SHACL shapes; rule 7
# needs a graph walk and is reported as skipped.
if in_profile "provenance-event"; then
  PE_MAX="${PE_MAX:-25}"
  PE_DIR=$(mktemp -d)
  code=$(curl -s -o "$PE_DIR/list.json" -w '%{http_code}' --max-time 15 \
    -H 'Accept: application/json' "${BASE}/activities?limit=${PE_MAX}" 2>/dev/null)
  ids=$(jq -r '(."openric:items" // ."ric:items" // [])[]["@id"] // empty' "$PE_DIR/list.json" 2>/dev/null | sed 's|.*/||')
  n=0
  for id in $ids; do
    curl -s --max-time 15 -H 'Accept: application/json' "${BASE}/activities/${id}" >"$PE_DIR/a-${id}.json" 2>/dev/null
    n=$((n+1)); sleep "${PE_PAUSE:-1}"
  done

  # One line per broken rule: "<rule> <activity id>". Targets may be one stub or
  # an array; @type may be a string or an array.
  PE_RULES='
    def many: if type == "array" then .[] else . end;
    def types: [."@type"? // empty | many];
    def kind: ((."rico:hasActivityType" // empty | many | (."@id"? // .)) // "") | tostring;
    def dated: [."rico:isAssociatedWithDate" // empty | many | select(type == "object" and (types | index("openricx:DateRange")))] | length > 0;
    def results: [(."rico:resultsOrResultedIn", ."rico:affectsOrAffected") // empty | many];
    def agents: [(."rico:hasOrHadParticipant", ."rico:isOrWasPerformedBy") // empty | many];
    ."@id" as $id
    | (if types != ["rico:Activity"] then "1 \($id)" else empty end),
      (if (kind | test("/production$")) and ((results | length) == 0 or (agents | length) == 0 or (dated | not)) then "2 \($id)" else empty end),
      (if (kind | test("/accumulation$")) and ((results | length) == 0 or (dated | not)) then "3 \($id)" else empty end),
      (if dated | not then "4 \($id)" else empty end),
      (agents[] | select((types | length) == 0 or ((types - ["rico:Person","rico:CorporateBody","rico:Family","rico:Mechanism","rico:Agent"]) | length) > 0) | "5 \($id)"),
      (results[] | select((types | length) == 0 or ((types - ["rico:RecordSet","rico:Record","rico:RecordPart"]) | length) > 0) | "6 \($id)")'
  : >"$PE_DIR/broken"
  jq -r '(."openric:items" // ."ric:items" // [])[] | ."@id" as $id | [."@type" // empty] | flatten | select(. != ["rico:Activity"]) | "1 \($id) (list)"' \
    "$PE_DIR/list.json" >>"$PE_DIR/broken" 2>/dev/null
  for f in "$PE_DIR"/a-*.json; do
    [[ -e "$f" ]] || continue
    jq -r "$PE_RULES" "$f" >>"$PE_DIR/broken" 2>/dev/null || echo "0 ${f##*/a-}" >>"$PE_DIR/broken"
  done
  has_kind() { jq -e --arg k "$1" '[(."rico:hasActivityType" // empty) | if type == "array" then .[] else . end | (."@id"? // .) | tostring | select(test("/" + $k + "$"))] | length > 0' "$PE_DIR"/a-*.json 2>/dev/null | grep -q true; }

  if [[ "$n" == 0 ]]; then
    record "SKIP (no activities)" "activity bodies follow §6 (none to check)" "$code"
  else
    pe_rule() {  # pe_rule <rule> <label> [kind that must exist]
      local first; first=$(awk -v r="$1" '$1 == r {print $2, $3; exit}' "$PE_DIR/broken")
      if [[ -n "${3:-}" ]] && ! has_kind "$3"; then
        record "SKIP (no $3 activity in sample)" "$2" "n=$n"
      elif [[ -n "$first" ]]; then
        record "FAIL" "$2 - e.g. ${first##*/}" "n=$n"
      else
        record PASS "$2" "n=$n"
      fi
    }
    pe_rule 0 "every activity body is JSON (§6)"
    pe_rule 1 "@type is rico:Activity, in the list too (§6.1)"
    pe_rule 2 "production: results, participant, DateRange (§6.2)" production
    pe_rule 3 "accumulation: results and DateRange (§6.3)" accumulation
    pe_rule 4 "every activity has a DateRange (§6.4)"
    pe_rule 5 "participants are Agent types (§6.5)"
    pe_rule 6 "results are Record types (§6.6)"
  fi
  record "SKIP (needs a graph walk)" "activity reachable from a record (§6.7)" "--"
  rm -rf "$PE_DIR"
fi

# ---- §3 Digital Object Linkage — instantiations, functions ----
if in_profile "digital-object-linkage"; then
  probe "list-instantiations" required GET "/instantiations" "$LIST_SHAPE"
  probe_show_first "show-instantiation" "/instantiations" "/instantiations"
  probe "list-functions"      optional GET "/functions"      "$LIST_SHAPE"
  probe_show_first "show-function"      "/functions"      "/functions"
fi

# ---- §4 Graph Traversal — graph, relation-types ----
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

    # Graph Primitives section 6, invariant 7 (spec v0.51.0): a node that stands
    # for an API entity carries the entity's API @id. The seed came from the
    # server's own list endpoint, so the root must be exactly that @id; and one
    # other record or agent node, fetched as JSON-LD, must describe itself by
    # the same id. Places are not sampled: a server may type place access-point
    # terms as rico:Place, and the invariant lets those keep their own ids.
    GRAPH_BODY=$(curl -s --max-time 15 -H 'Accept: application/json' "${BASE}/graph?uri=${SEED_ENC}&depth=1" 2>/dev/null || true)
    SEEN_TYPES=$(node_types "$GRAPH_BODY")
    ROOT_ID=$(printf '%s' "$GRAPH_BODY" | jq -r '."openric:root" // .root // empty' 2>/dev/null || true)
    if [[ "$ROOT_ID" == "$SEED_URI" ]]; then
      record PASS "graph root is the seed's API @id (invariant 7)" "ok"
    else
      record FAIL "graph root is the seed's API @id (invariant 7)" "${ROOT_ID:-none}"
    fi
    # The seed may be a place, and a record's graph may hold only a finding
    # aid, so the second check walks the first records' graphs. A record or
    # agent node is dereferenced: 404 or 410 means the API does not serve it
    # as an entity, which the invariant allows, so the next node is tried; a
    # document whose @id differs from the node id is a failure. Every graph
    # walked also feeds the invariant 5 check below.
    DEREF_RESULT=""
    DEREF_TRIED=" "
    for REC_URI in $(curl -s --max-time 10 "${BASE}/records?limit=10" | \
        jq -r '(."openric:items" // ."ric:items" // .items // [])[]["@id"] // empty' 2>/dev/null || true); do
      GRAPH_BODY=$(curl -s --max-time 15 -H 'Accept: application/json' "${BASE}/graph?uri=$(printf '%s' "$REC_URI" | jq -sRr @uri)&depth=1" 2>/dev/null || true)
      SEEN_TYPES+=$'\n'$(node_types "$GRAPH_BODY")
      [[ -n "$DEREF_RESULT" ]] && continue
      for OTHER_ID in $(printf '%s' "$GRAPH_BODY" | jq -r --arg r "$REC_URI" '(."openric:nodes" // .nodes // [])[] | select(.id != $r) | select((.type // "") | test("(Record|RecordSet|RecordPart|Person|CorporateBody|Family|Agent)$")) | .id' 2>/dev/null || true); do
        [[ "$DEREF_TRIED" == *" $OTHER_ID "* ]] && continue
        DEREF_TRIED+="$OTHER_ID "
        DEREF_OUT=$(curl -s -L --max-time 15 -w '\n%{http_code}' -H 'Accept: application/ld+json' "$OTHER_ID" 2>/dev/null || true)
        DEREF_CODE=${DEREF_OUT##*$'\n'}
        [[ "$DEREF_CODE" == "404" || "$DEREF_CODE" == "410" ]] && continue
        DEREF_ID=$(printf '%s' "${DEREF_OUT%$'\n'*}" | jq -r '."@id" // empty' 2>/dev/null || true)
        if [[ "$DEREF_ID" == "$OTHER_ID" ]]; then
          DEREF_RESULT="PASS|ok"
        else
          DEREF_RESULT="FAIL|${OTHER_ID} -> ${DEREF_ID:-no @id} (${DEREF_CODE})"
        fi
        break
      done
    done
    if [[ -n "$DEREF_RESULT" ]]; then
      record "${DEREF_RESULT%%|*}" "a record or agent node dereferences to itself (invariant 7)" "${DEREF_RESULT#*|}"
    else
      record "SKIP (no record or agent node the API serves)" "a record or agent node dereferences to itself (invariant 7)" "--"
    fi
    # Invariant 5 over every node of every graph fetched above.
    BAD_TYPES=""
    TYPE_COUNT=0
    while IFS= read -r T; do
      [[ -z "$T" ]] && continue
      TYPE_COUNT=$((TYPE_COUNT+1))
      case "$T" in
        rico:*) [[ "$RICO_CLASSES" == *" ${T#rico:} "* ]] && continue ;;
        https://www.ica.org/standards/RiC/ontology\#*) [[ "$RICO_CLASSES" == *" ${T#*#} "* ]] && continue ;;
        openricx:*) [[ "$OPENRICX_CLASSES" == *" ${T#openricx:} "* ]] && continue ;;
        https://openric.org/ns/ext/v1\#*) [[ "$OPENRICX_CLASSES" == *" ${T#*#} "* ]] && continue ;;
      esac
      [[ " $BAD_TYPES " == *" $T "* ]] || BAD_TYPES="${BAD_TYPES:+$BAD_TYPES }$T"
    done <<< "$SEEN_TYPES"
    if (( TYPE_COUNT == 0 )); then
      record "SKIP (no nodes)" "every node type is a RiC-O or OpenRiC class (invariant 5)" "--"
    elif [[ -z "$BAD_TYPES" ]]; then
      record PASS "every node type is a RiC-O or OpenRiC class (invariant 5)" "${TYPE_COUNT} nodes"
    else
      record FAIL "every node type is a RiC-O or OpenRiC class (invariant 5)" "$BAD_TYPES"
    fi
  else
    printf '%s%-5s%s  GET  %-50s  [--]\n' "$Y" "SKIP" "$Z" "/graph (no seed URI available)"
    SKIP=$((SKIP+1))
    RESULTS+=("SKIP|GET /graph|no-seed")
  fi
fi

# ---- SPARQL Access (draft profile) ----
# Required when the run asks for sparql-access by name; optional in a full
# run, because servers that do not offer SPARQL legitimately 404 here.
if in_profile "sparql-access"; then
  SPARQL_LEVEL=optional
  [[ ",${PROFILE}," == *",sparql-access,"* ]] && SPARQL_LEVEL=required

  # SPARQL probe — URL-encode the query body via jq @uri to avoid curl
  # globbing the `{...}` and to escape `?` in variables (`?s ?p ?o`).
  # Asserts canonical SPARQL Results JSON shape (head.vars is an array)
  # so a server wrapping the result in a non-canonical envelope is
  # caught here, not silently passed.
  SPARQL_Q=$(printf '%s' 'SELECT * WHERE { ?s ?p ?o } LIMIT 1' | jq -sRr @uri)
  probe "sparql"      "$SPARQL_LEVEL" GET "/sparql?query=${SPARQL_Q}" '(.head.vars | type) == "array"'

  # SPARQL dataset description: the void:Dataset endpoint at /sparql/info.
  probe "sparql-info" "$SPARQL_LEVEL" GET "/sparql/info"                '.'
fi

# ---- §5 Export-Only (OAI-PMH) ----
if in_profile "export-only"; then
  probe_oai "Identify"
  probe_oai "ListMetadataFormats"
  probe_oai "ListSets"
  probe_oai "ListIdentifiers" "&metadataPrefix=oai_dc"
  probe_oai "ListRecords"     "&metadataPrefix=oai_dc"
fi

# ---- §6 Round-Trip Editing - write surface (needs KEY) ----
# Follows round-trip-editing.md §6. Never point this at a production service:
# it creates, changes and deletes data. Run it against a disposable server.
#
#   KEY             write + delete scopes (required for this section)
#   WRITE_ONLY_KEY  write scope only - checks a delete is refused (§6.7)
#
# Covers §6.1-6.4 for all eight entity types and for relations (§6.5), §6.6,
# §6.7 (with WRITE_ONLY_KEY), §6.8 (409 deleting a record that has children)
# and §6.9 (422 for a body missing its required field, per type).

# rte_cycle <type> <create-body> <patch-field> [write-only-key]
# Create, read the href, update and see the change, delete, see 404, and find
# create, update and delete in the revision list. Prints the new id.
rte_cycle() {
  local t="$1" b="$2" field="$3" wo="${4:-}" code body id href
  read -r code body <<<"$(http POST "/$t" "$KEY" "$b")"
  id=$(jq -r '.id // empty' <<<"$body" 2>/dev/null)
  href=$(jq -r '.href // empty' <<<"$body" 2>/dev/null)
  if [[ "$code" != "201" || -z "$id" ]]; then
    record "FAIL" "POST /$t creates, with an id (§6.1)" "$code"; return
  fi
  record PASS "POST /$t creates, with an id (§6.1)" "$code"
  local show="/$t/${id}"
  if [[ -n "$href" ]]; then
    show="${href#*/api/ric/v1}"
    read -r code _ <<<"$(http GET "$show")"
    [[ "$code" == "200" ]] && record PASS "/$t create href resolves (§6.1)" "$code" \
                           || record "FAIL" "/$t create href resolves (§6.1)" "$code"
  fi

  read -r code body <<<"$(http PATCH "/$t/${id}" "$KEY" "{\"${field}\":\"updated by the probe\"}")"
  [[ "$code" == "200" ]] && jq -e '.success == true' <<<"$body" >/dev/null 2>&1 \
    && record PASS "PATCH /$t/{id} succeeds (§6.2)" "$code" \
    || record "FAIL" "PATCH /$t/{id} succeeds (§6.2)" "$code"
  read -r code body <<<"$(http GET "$show")"
  grep -q "updated by the probe" <<<"$body" \
    && record PASS "GET after PATCH shows the change on /$t (§6.2)" "$code" \
    || record "FAIL" "GET after PATCH shows the change on /$t (§6.2)" "$code"

  if [[ -n "$wo" ]]; then
    read -r code _ <<<"$(http DELETE "/$t/${id}" "$wo")"
    [[ "$code" == "403" ]] && record PASS "DELETE with a write-only key is 403 (§6.7)" "$code" \
                           || record "FAIL" "DELETE with a write-only key is 403 (§6.7)" "$code"
  fi

  read -r code body <<<"$(http DELETE "/$t/${id}" "$KEY")"
  [[ "$code" == "200" ]] && record PASS "DELETE /$t/{id} succeeds (§6.3)" "$code" \
                         || record "FAIL" "DELETE /$t/{id} succeeds (§6.3)" "$code"
  read -r code _ <<<"$(http GET "$show")"
  [[ "$code" == "404" ]] && record PASS "GET /$t after delete is 404 (§6.3)" "$code" \
                         || record "FAIL" "GET /$t after delete is 404 (§6.3)" "$code"

  read -r code body <<<"$(http GET "/$t/${id}/revisions")"
  if [[ "$code" == "200" ]] && jq -e '."@type" == "openric:RevisionList"
        and ([.items[].action] | (index("create") != null and index("update") != null and index("delete") != null))' \
        <<<"$body" >/dev/null 2>&1; then
    record PASS "/$t revisions list create, update and delete (§6.4)" "$code"
  else
    record "FAIL" "/$t revisions list create, update and delete (§6.4)" "$code"
  fi
}

if [[ -n "$KEY" ]] && in_profile "round-trip-editing"; then
  # §6.6 - a write without a key is refused.
  read -r code _ <<<"$(http POST /places "" '{"name":"Probe place without a key"}')"
  [[ "$code" == "401" ]] && record PASS "POST /places without a key is 401 (§6.6)" "$code" \
                         || record "FAIL" "POST /places without a key is 401 (§6.6)" "$code"

  # §6.9 - a body missing the type's required field is refused, for every type.
  for t in places rules activities instantiations agents records repositories functions relations; do
    read -r code _ <<<"$(http POST "/$t" "$KEY" '{}')"
    [[ "$code" == "422" ]] && record PASS "POST /$t with an empty body is 422 (§6.9)" "$code" \
                           || record "FAIL" "POST /$t with an empty body is 422 (§6.9)" "$code"
  done

  # §6.1-6.5 - the full cycle for every entity type. The write-only check
  # (§6.7) runs once, on places.
  rte_cycle places         '{"name":"Conformance probe place"}'           description "${WRITE_ONLY_KEY:-}"
  [[ -z "${WRITE_ONLY_KEY:-}" ]] && record "SKIP (no WRITE_ONLY_KEY)" "DELETE with a write-only key is 403 (§6.7)" "--"
  rte_cycle rules          '{"title":"Conformance probe rule"}'           description
  rte_cycle activities     '{"name":"Conformance probe activity"}'        description
  rte_cycle instantiations '{"title":"Conformance probe instantiation"}'  description
  rte_cycle agents         '{"name":"Conformance probe agent"}'           history
  rte_cycle records        '{"title":"Conformance probe record"}'         scope_and_content
  rte_cycle repositories   '{"name":"Conformance probe repository"}'      history
  rte_cycle functions      '{"name":"Conformance probe function"}'        description

  # §6.5 for relations: a new record and a new agent joined by a relation type
  # whose domain is Record and range Agent (has_creator on the reference
  # service), then both deleted.
  read -r _ b1 <<<"$(http POST /records "$KEY" '{"title":"Probe relation subject"}')"
  read -r _ b2 <<<"$(http POST /agents "$KEY" '{"name":"Probe relation object"}')"
  s_id=$(jq -r '.id // empty' <<<"$b1" 2>/dev/null); o_id=$(jq -r '.id // empty' <<<"$b2" 2>/dev/null)
  rtype=$(curl -s --max-time 15 "${BASE}/relation-types" | jq -r '(.items // ."openric:items" // .) as $all
    | ([$all[] | select((.metadata // "{}" | fromjson? // {}) as $m | $m.domain == "Record" and $m.range == "Agent")] + $all)[0]
    | (.code // .id // empty)' 2>/dev/null)
  if [[ -n "$s_id" && -n "$o_id" && -n "$rtype" ]]; then
    rte_cycle relations "{\"subject_id\":${s_id},\"object_id\":${o_id},\"relation_type\":\"${rtype}\"}" evidence
  else
    record "FAIL" "set up a relation between a new record and agent (§6.5)" "--"
  fi
  [[ -n "$s_id" ]] && http DELETE "/records/${s_id}" "$KEY" >/dev/null
  [[ -n "$o_id" ]] && http DELETE "/agents/${o_id}" "$KEY" >/dev/null

  # §6.8 - deleting a record that still has a child record is 409.
  read -r _ pb <<<"$(http POST /records "$KEY" '{"title":"Probe parent record"}')"
  p_id=$(jq -r '.id // empty' <<<"$pb" 2>/dev/null)
  read -r _ cb <<<"$(http POST /records "$KEY" "{\"title\":\"Probe child record\",\"parent_id\":${p_id:-0}}")"
  c_id=$(jq -r '.id // empty' <<<"$cb" 2>/dev/null)
  if [[ -n "$p_id" && -n "$c_id" ]]; then
    read -r code _ <<<"$(http DELETE "/records/${p_id}" "$KEY")"
    [[ "$code" == "409" ]] && record PASS "DELETE a record with children is 409 (§6.8)" "$code" \
                           || record "FAIL" "DELETE a record with children is 409 (§6.8)" "$code"
  else
    record "FAIL" "set up a parent and child record (§6.8)" "--"
  fi
  for i in "$c_id" "$p_id"; do [[ -n "$i" ]] && http DELETE "/records/${i}" "$KEY" >/dev/null; done
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
