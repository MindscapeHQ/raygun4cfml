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

# All available server configs in test order
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

MAX_WAIT=120  # seconds to wait for server startup

usage() {
    echo "Usage: $0 [server-config.json | --help]"
    echo ""
    echo "Run TestBox tests against CFML engines."
    echo ""
    echo "  No arguments     Run tests against all engines"
    echo "  server-*.json    Run tests against a single engine"
    echo "  --help           Show this help"
    echo ""
    echo "Available server configs:"
    for s in "${ALL_SERVERS[@]}"; do
        echo "  $s"
    done
    exit 0
}

# Extract port from a server JSON config
get_port() {
    grep '"port"' "$1" | head -1 | sed 's/[^0-9]//g'
}

# Extract server name from a server JSON config
get_name() {
    grep '"name"' "$1" | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

# Wait for server to respond
wait_for_server() {
    local port=$1
    local elapsed=0
    echo -n "  Waiting for server on port $port "
    while ! curl -sf -o /dev/null "http://localhost:$port/" 2>/dev/null; do
        if [ $elapsed -ge $MAX_WAIT ]; then
            echo " TIMEOUT"
            return 1
        fi
        echo -n "."
        sleep 2
        elapsed=$((elapsed + 2))
    done
    echo " ready (${elapsed}s)"
    return 0
}

# Run tests against a single server config
run_single() {
    local config=$1
    local port
    local name
    port=$(get_port "$config")
    name=$(get_name "$config")

    echo "═══════════════════════════════════════════════════════"
    echo "  Engine: $name ($config) — port $port"
    echo "═══════════════════════════════════════════════════════"

    # Start server
    echo "  Starting server..."
    box server start serverConfigFile="$config" --!verbose 2>&1 | sed 's/^/  /'

    # Wait for it to be ready
    if ! wait_for_server "$port"; then
        echo "  ❌ Server failed to start within ${MAX_WAIT}s"
        box server stop serverConfigFile="$config" 2>/dev/null || true
        return 1
    fi

    # Run tests via JSON reporter
    echo "  Running tests..."
    local result
    local http_code
    http_code=$(curl -sf -o /tmp/raygun4cfml-test-result.json -w "%{http_code}" \
        "http://localhost:$port/tests/runner.cfm?reporter=json" 2>/dev/null) || true

    local exit_code=0

    if [ "$http_code" != "200" ] && [ "$http_code" != "000" ]; then
        echo "  ❌ Test runner returned HTTP $http_code"
        exit_code=1
    elif [ ! -s /tmp/raygun4cfml-test-result.json ]; then
        echo "  ❌ Empty response from test runner"
        exit_code=1
    else
        # Parse JSON results — look for totalFail and totalError
        local total_pass total_fail total_error total_specs
        total_pass=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('totalPass',0))" < /tmp/raygun4cfml-test-result.json 2>/dev/null) || total_pass="?"
        total_fail=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('totalFail',0))" < /tmp/raygun4cfml-test-result.json 2>/dev/null) || total_fail="?"
        total_error=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('totalError',0))" < /tmp/raygun4cfml-test-result.json 2>/dev/null) || total_error="?"
        total_specs=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('totalSpecs',0))" < /tmp/raygun4cfml-test-result.json 2>/dev/null) || total_specs="?"

        echo "  Results: $total_specs specs | ✅ $total_pass passed | ❌ $total_fail failed | 💥 $total_error errors"

        if [ "$total_fail" != "0" ] || [ "$total_error" != "0" ]; then
            # Show failure details
            python3 -c "
import json, sys
d = json.load(sys.stdin)
for bundle in d.get('bundleStats', []):
    for suite in bundle.get('suiteStats', []):
        for spec in suite.get('specStats', []):
            if spec.get('status') in ('Failed', 'Error'):
                print(f\"  → {spec.get('name')}: {spec.get('failMessage', spec.get('error', ''))}\")
" < /tmp/raygun4cfml-test-result.json 2>/dev/null || true
            exit_code=1
        fi
    fi

    # Stop server
    echo "  Stopping server..."
    box server stop serverConfigFile="$config" 2>&1 | sed 's/^/  /'
    echo ""

    return $exit_code
}

# --- Main ---

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
fi

# Check for CommandBox
if ! command -v box &> /dev/null; then
    echo "❌ CommandBox (box) not found. Install from https://www.ortussolutions.com/products/commandbox"
    exit 1
fi

# Ensure dependencies are installed
if [ ! -d "testbox" ]; then
    echo "Installing dependencies..."
    box install
    echo ""
fi

FAILED_ENGINES=()

if [ $# -eq 1 ]; then
    # Single engine
    if [ ! -f "$1" ]; then
        echo "❌ Server config not found: $1"
        exit 1
    fi
    run_single "$1" || FAILED_ENGINES+=("$1")
else
    # All engines
    echo "Running tests against all ${#ALL_SERVERS[@]} engines..."
    echo ""
    for config in "${ALL_SERVERS[@]}"; do
        if [ -f "$config" ]; then
            run_single "$config" || FAILED_ENGINES+=("$config")
        else
            echo "⚠️  Skipping $config (file not found)"
        fi
    done
fi

# Summary
echo "═══════════════════════════════════════════════════════"
if [ ${#FAILED_ENGINES[@]} -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Failures on ${#FAILED_ENGINES[@]} engine(s):"
    for e in "${FAILED_ENGINES[@]}"; do
        echo "   - $e"
    done
    exit 1
fi
