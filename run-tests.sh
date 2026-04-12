#!/usr/bin/env bash
#
# Run TestBox tests against one or all CFML engine server configs.
#
# Usage:
#   ./run-tests.sh                          # Run against all engines
#   ./run-tests.sh server-lucee-6-1.json    # Run against a single engine
#   ./run-tests.sh --help
#
# Requires: CommandBox (box) installed and on PATH
#

set -euo pipefail

# ── Colors & symbols ─────────────────────────────────────────────────────────

if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    C_RESET=$(tput sgr0)
    C_BOLD=$(tput bold)
    C_DIM=$(tput setaf 8)
    C_GREEN=$(tput setaf 2)
    C_RED=$(tput setaf 1)
    C_YELLOW=$(tput setaf 3)
    C_CYAN=$(tput setaf 6)
    C_WHITE=$(tput setaf 7)
    C_BG_GREEN=$(tput setab 2)
    C_BG_RED=$(tput setab 1)
    C_BG_YELLOW=$(tput setab 3)
else
    C_RESET="" C_BOLD="" C_DIM="" C_GREEN="" C_RED="" C_YELLOW="" C_CYAN="" C_WHITE=""
    C_BG_GREEN="" C_BG_RED="" C_BG_YELLOW=""
fi

SYM_PASS="${C_GREEN}✔${C_RESET}"
SYM_FAIL="${C_RED}✘${C_RESET}"
SYM_WARN="${C_YELLOW}⚠${C_RESET}"
SYM_DOT="${C_DIM}·${C_RESET}"
SYM_ARROW="${C_DIM}→${C_RESET}"

# ── Config ───────────────────────────────────────────────────────────────────

ALL_SERVERS=(
    server-lucee-6-1.json
    server-lucee-6-0.json
    server-lucee-5-4.json
    server-lucee-5-3.json
    server-adobe-2025.json
    server-adobe-2023.json
    server-adobe-2021.json
    server-boxlang-1.json
)

MAX_WAIT=120

# ── Result tracking ──────────────────────────────────────────────────────────

declare -a RESULT_NAMES=()
declare -a RESULT_STATUS=()
declare -a RESULT_SPECS=()
declare -a RESULT_PASS=()
declare -a RESULT_FAIL=()
declare -a RESULT_ERROR=()
declare -a RESULT_TIME=()
declare -a RESULT_DETAILS=()

# ── Helpers ──────────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
${C_BOLD}Raygun4CFML Test Runner${C_RESET}

${C_BOLD}Usage:${C_RESET}
  $0                          Run tests against all engines
  $0 server-config.json       Run tests against a single engine
  $0 --help                   Show this help

${C_BOLD}Available engines:${C_RESET}
EOF
    for s in "${ALL_SERVERS[@]}"; do
        local name port
        name=$(get_name "$s" 2>/dev/null || echo "?")
        port=$(get_port "$s" 2>/dev/null || echo "?")
        echo "  ${C_DIM}${s}${C_RESET}  ${C_CYAN}${name}${C_RESET} :${port}"
    done
    exit 0
}

get_port() {
    grep '"port"' "$1" | head -1 | sed 's/[^0-9]//g'
}

get_name() {
    grep '"name"' "$1" | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

get_engine() {
    grep '"cfengine"' "$1" | head -1 | sed 's/.*"cfengine"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

# Pretty name: "Lucee 6.1" from "lucee@6.1"
pretty_engine() {
    local engine
    engine=$(get_engine "$1")
    local vendor version
    vendor=$(echo "$engine" | cut -d@ -f1)
    version=$(echo "$engine" | cut -d@ -f2)
    case "$vendor" in
        lucee)   echo "Lucee $version" ;;
        adobe)   echo "Adobe CF $version" ;;
        boxlang) echo "BoxLang $version" ;;
        *)       echo "$engine" ;;
    esac
}

header() {
    echo ""
    echo "  ${C_BOLD}${C_CYAN}$1${C_RESET}"
    echo "  ${C_DIM}$(printf '%.0s─' $(seq 1 ${#1}))${C_RESET}"
}

log() {
    echo "  $1"
}

wait_for_server() {
    local port=$1
    local elapsed=0
    printf "  ${C_DIM}Waiting for server "
    while ! curl -sf -o /dev/null "http://localhost:$port/" 2>/dev/null; do
        if [ $elapsed -ge $MAX_WAIT ]; then
            printf " timeout${C_RESET}\n"
            return 1
        fi
        printf "."
        sleep 2
        elapsed=$((elapsed + 2))
    done
    printf " ready ${C_RESET}(${elapsed}s)\n"
    return 0
}

# ── Cleanup / trap ───────────────────────────────────────────────────────────

CURRENT_SERVER=""

cleanup() {
    if [ -n "$CURRENT_SERVER" ]; then
        echo ""
        log "${C_YELLOW}Stopping server (cleanup)...${C_RESET}"
        box server stop serverConfigFile="$CURRENT_SERVER" 2>/dev/null || true
        CURRENT_SERVER=""
    fi
}

trap cleanup EXIT INT TERM

# ── Run tests on one engine ──────────────────────────────────────────────────

run_single() {
    local config=$1
    local idx=$2
    local total=$3
    local port name engine_pretty
    port=$(get_port "$config")
    name=$(get_name "$config")
    engine_pretty=$(pretty_engine "$config")

    echo ""
    echo "  ${C_BOLD}┌──────────────────────────────────────────────────┐${C_RESET}"
    if [ "$total" -gt 1 ]; then
        printf "  ${C_BOLD}│${C_RESET}  ${C_CYAN}%-44s${C_RESET}${C_DIM}[%d/%d]${C_RESET}${C_BOLD}│${C_RESET}\n" "$engine_pretty" "$idx" "$total"
    else
        printf "  ${C_BOLD}│${C_RESET}  ${C_CYAN}%-50s${C_RESET}${C_BOLD}│${C_RESET}\n" "$engine_pretty"
    fi
    echo "  ${C_BOLD}│${C_RESET}  ${C_DIM}port $port • $config${C_RESET}"
    echo "  ${C_BOLD}└──────────────────────────────────────────────────┘${C_RESET}"

    local start_time
    start_time=$(date +%s)

    # Start server
    log "${SYM_DOT} Starting server..."
    CURRENT_SERVER="$config"
    box server start serverConfigFile="$config" --!verbose --!openBrowser > /dev/null 2>&1

    # Wait for it
    if ! wait_for_server "$port"; then
        log "${SYM_FAIL} Server failed to start within ${MAX_WAIT}s"
        box server stop serverConfigFile="$config" 2>/dev/null || true
        CURRENT_SERVER=""
        local elapsed=$(( $(date +%s) - start_time ))
        RESULT_NAMES+=("$engine_pretty")
        RESULT_STATUS+=("error")
        RESULT_SPECS+=("-")
        RESULT_PASS+=("-")
        RESULT_FAIL+=("-")
        RESULT_ERROR+=("-")
        RESULT_TIME+=("${elapsed}s")
        RESULT_DETAILS+=("Server failed to start")
        return 1
    fi

    # Run tests
    log "${SYM_DOT} Running tests..."
    local http_code
    http_code=$(curl -sf -o /tmp/raygun4cfml-test-result.json -w "%{http_code}" \
        "http://localhost:$port/tests/runner.cfm?reporter=json" 2>/dev/null) || true

    local exit_code=0
    local total_pass="?" total_fail="?" total_error="?" total_specs="?"
    local details=""

    if [ "$http_code" != "200" ] && [ "$http_code" != "000" ]; then
        log "${SYM_FAIL} Test runner returned HTTP $http_code"
        exit_code=1
        details="HTTP $http_code"
    elif [ ! -s /tmp/raygun4cfml-test-result.json ]; then
        log "${SYM_FAIL} Empty response from test runner"
        exit_code=1
        details="Empty response"
    else
        # Extract JSON object from response — ACF may append debug HTML after the JSON
        python3 -c "
import json, sys
raw = sys.stdin.read()
# Find the end of the top-level JSON object
depth = 0
end = 0
for i, ch in enumerate(raw):
    if ch == '{': depth += 1
    elif ch == '}':
        depth -= 1
        if depth == 0:
            end = i + 1
            break
sys.stdout.write(raw[:end])
" < /tmp/raygun4cfml-test-result.json > /tmp/raygun4cfml-test-clean.json 2>/dev/null

        total_pass=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(int(d.get('totalPass',0)))" < /tmp/raygun4cfml-test-clean.json 2>/dev/null) || total_pass="?"
        total_fail=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(int(d.get('totalFail',0)))" < /tmp/raygun4cfml-test-clean.json 2>/dev/null) || total_fail="?"
        total_error=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(int(d.get('totalError',0)))" < /tmp/raygun4cfml-test-clean.json 2>/dev/null) || total_error="?"
        total_specs=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(int(d.get('totalSpecs',0)))" < /tmp/raygun4cfml-test-clean.json 2>/dev/null) || total_specs="?"

        if [ "$total_fail" = "0" ] && [ "$total_error" = "0" ]; then
            log "${SYM_PASS} ${C_GREEN}${total_specs} specs passed${C_RESET}"
        else
            log "${SYM_FAIL} ${C_RED}${total_specs} specs: ${total_pass} passed, ${total_fail} failed, ${total_error} errors${C_RESET}"
            # Collect failure details
            details=$(python3 -c "
import json, sys
d = json.load(sys.stdin)
lines = []
for bundle in d.get('bundleStats', []):
    for suite in bundle.get('suiteStats', []):
        for spec in suite.get('specStats', []):
            if spec.get('status') in ('Failed', 'Error'):
                msg = spec.get('failMessage') or spec.get('error', '')
                lines.append(f\"{spec.get('name')}: {msg}\")
print('\n'.join(lines))
" < /tmp/raygun4cfml-test-clean.json 2>/dev/null) || details=""

            # Print failure details indented
            if [ -n "$details" ]; then
                echo ""
                while IFS= read -r line; do
                    log "    ${SYM_ARROW} ${C_RED}${line}${C_RESET}"
                done <<< "$details"
            fi
            exit_code=1
        fi
    fi

    # Stop server
    log "${SYM_DOT} Stopping server..."
    box server stop serverConfigFile="$config" > /dev/null 2>&1 || true
    CURRENT_SERVER=""

    local elapsed=$(( $(date +%s) - start_time ))

    # Store results
    RESULT_NAMES+=("$engine_pretty")
    if [ $exit_code -eq 0 ]; then
        RESULT_STATUS+=("pass")
    else
        RESULT_STATUS+=("fail")
    fi
    RESULT_SPECS+=("$total_specs")
    RESULT_PASS+=("$total_pass")
    RESULT_FAIL+=("$total_fail")
    RESULT_ERROR+=("$total_error")
    RESULT_TIME+=("${elapsed}s")
    RESULT_DETAILS+=("$details")

    return $exit_code
}

# ── Summary table ────────────────────────────────────────────────────────────

print_summary() {
    local total_engines=${#RESULT_NAMES[@]}
    local passed=0
    local failed=0

    for status in "${RESULT_STATUS[@]}"; do
        if [ "$status" = "pass" ]; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi
    done

    echo ""
    echo ""

    # Table header
    if [ $total_engines -gt 1 ]; then
        echo "  ${C_BOLD}Test Matrix Results${C_RESET}"
        echo "  ${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
        printf "  ${C_BOLD}${C_DIM}%-20s  %-8s  %5s  %5s  %5s  %5s  %7s${C_RESET}\n" \
            "ENGINE" "STATUS" "SPECS" "PASS" "FAIL" "ERROR" "TIME"
        echo "  ${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    fi

    for i in "${!RESULT_NAMES[@]}"; do
        local status_icon status_text status_color
        if [ "${RESULT_STATUS[$i]}" = "pass" ]; then
            status_icon="$SYM_PASS"
            status_text="PASS"
            status_color="$C_GREEN"
        else
            status_icon="$SYM_FAIL"
            status_text="FAIL"
            status_color="$C_RED"
        fi

        if [ $total_engines -gt 1 ]; then
            printf "  ${C_WHITE}%-20s${C_RESET}  %b %-5s  %5s  ${C_GREEN}%5s${C_RESET}  ${C_RED}%5s${C_RESET}  ${C_RED}%5s${C_RESET}  ${C_DIM}%7s${C_RESET}\n" \
                "${RESULT_NAMES[$i]}" \
                "$status_icon" "${status_color}${status_text}${C_RESET}" \
                "${RESULT_SPECS[$i]}" \
                "${RESULT_PASS[$i]}" \
                "${RESULT_FAIL[$i]}" \
                "${RESULT_ERROR[$i]}" \
                "${RESULT_TIME[$i]}"
        fi
    done

    if [ $total_engines -gt 1 ]; then
        echo "  ${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    fi

    # Final verdict
    echo ""
    if [ $failed -eq 0 ]; then
        echo "  ${C_BG_GREEN}${C_BOLD}${C_WHITE} PASS ${C_RESET} ${C_GREEN}${C_BOLD}All ${passed} engine(s) passed${C_RESET}"
    else
        echo "  ${C_BG_RED}${C_BOLD}${C_WHITE} FAIL ${C_RESET} ${C_RED}${C_BOLD}${failed} of ${total_engines} engine(s) failed${C_RESET}"
        echo ""
        for i in "${!RESULT_NAMES[@]}"; do
            if [ "${RESULT_STATUS[$i]}" != "pass" ] && [ -n "${RESULT_DETAILS[$i]}" ]; then
                echo "  ${SYM_FAIL} ${C_BOLD}${RESULT_NAMES[$i]}${C_RESET}"
                while IFS= read -r line; do
                    [ -n "$line" ] && echo "    ${SYM_ARROW} ${C_DIM}${line}${C_RESET}"
                done <<< "${RESULT_DETAILS[$i]}"
            fi
        done
    fi
    echo ""

    return $failed
}

# ── Main ─────────────────────────────────────────────────────────────────────

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
fi

# Preflight
if ! command -v box &> /dev/null; then
    echo "  ${SYM_FAIL} CommandBox (box) not found. Install from https://www.ortussolutions.com/products/commandbox"
    exit 1
fi

if [ ! -d "testbox" ]; then
    header "Installing dependencies"
    box install
fi

# Build server list
SERVERS=()
if [ $# -ge 1 ]; then
    for arg in "$@"; do
        if [ ! -f "$arg" ]; then
            echo "  ${SYM_FAIL} Server config not found: $arg"
            exit 1
        fi
        SERVERS+=("$arg")
    done
else
    for config in "${ALL_SERVERS[@]}"; do
        if [ -f "$config" ]; then
            SERVERS+=("$config")
        else
            echo "  ${SYM_WARN} ${C_YELLOW}Skipping $config (not found)${C_RESET}"
        fi
    done
fi

TOTAL=${#SERVERS[@]}

if [ $TOTAL -eq 0 ]; then
    echo "  ${SYM_FAIL} No server configs found"
    exit 1
fi

# Banner
echo ""
echo "  ${C_BOLD}╔══════════════════════════════════════════════════╗${C_RESET}"
echo "  ${C_BOLD}║${C_RESET}        ${C_CYAN}${C_BOLD}Raygun4CFML Test Runner${C_RESET}                 ${C_BOLD}║${C_RESET}"
echo "  ${C_BOLD}║${C_RESET}        ${C_DIM}Testing ${TOTAL} engine(s)${C_RESET}                       ${C_BOLD}║${C_RESET}"
echo "  ${C_BOLD}╚══════════════════════════════════════════════════╝${C_RESET}"

# Run
IDX=0
for config in "${SERVERS[@]}"; do
    IDX=$((IDX + 1))
    run_single "$config" "$IDX" "$TOTAL" || true
done

# Summary
print_summary
FINAL=$?
trap - EXIT
exit $FINAL
