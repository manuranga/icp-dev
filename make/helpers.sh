#!/usr/bin/env bash

# ── Lab process management ──

# Starting an already-live process is a no-op, so up.sh can repair a half-dead lab.
logged_run() {
    local name=$1; shift
    pid_alive "$name" && return 0
    local pid_dir="$LAB_DIR/pids" log_dir="$LAB_DIR/logs"
    mkdir -p "$pid_dir" "$log_dir"
    "$@" >> "$log_dir/$name.log" 2>&1 &
    echo $! > "$pid_dir/$name.pid"
}

pid_alive() {
    local pid_file="$LAB_DIR/pids/$1.pid"
    [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null
}

pid_stop() {
    local pid_file="$LAB_DIR/pids/$1.pid"
    [[ -f "$pid_file" ]] || return 0
    local pid i; pid=$(cat "$pid_file")
    pkill -P "$pid" 2>/dev/null || true
    kill "$pid" 2>/dev/null || true
    for i in $(seq 1 10); do  # a hung JVM ignores TERM and would block the next start
        kill -0 "$pid" 2>/dev/null || break
        sleep 1
    done
    kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null
    rm -f "$pid_file"
    return 0
}

require_ports() {
    local port pid ours busy=0
    ours=$(_lab_pids)
    for port in "$@"; do
        pid=$(lsof -nP -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null | head -1 || true)  # free port ⇒ lsof exits 1
        [[ -n "$pid" ]] || continue
        grep -qx "$pid" <<<"$ours" && continue  # tracked survivor of this lab; up.sh keeps it
        printf 'port %s held by pid %s (%s) in %s\n' "$port" "$pid" \
            "$(ps -o comm= -p "$pid" 2>/dev/null)" \
            "$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -1)" >&2
        busy=1
    done
    (( busy == 0 )) || { echo "stop the owning lab, then retry" >&2; return 1; }
}

# Live pids this lab tracks, plus their children (a `bash -c` wrapper owns the java it starts).
_lab_pids() {
    local f pid
    for f in "$LAB_DIR"/pids/*.pid; do
        [[ -f "$f" ]] || continue
        pid=$(cat "$f")
        kill -0 "$pid" 2>/dev/null || continue
        echo "$pid"
        pgrep -P "$pid" 2>/dev/null || true
    done
}

# ── Readiness ──

# wait_http <label> <url> — poll until the url answers
wait_http() {
    local label=$1 url=$2 i
    for i in $(seq 1 30); do
        curl -sk -o /dev/null "$url" && { echo "$label ready" >&2; return 0; }
        sleep 2
    done
    echo "$label never answered: $url" >&2
    return 1
}

# wait_for_runtimes <count> [icp-url] — proves heartbeats reach ICP, not just that ports opened
wait_for_runtimes() {
    local expected=$1 url=${2:-https://localhost:9446} token running=0 i
    token=$(_icp_token "$url")
    [[ -n "$token" ]] || { echo "ICP login failed: $url" >&2; return 1; }
    for i in $(seq 1 30); do
        running=$(_icp_running_count "$url" "$token")
        (( running >= expected )) && { echo "$running runtime(s) heartbeating" >&2; return 0; }
        sleep 2
    done
    echo "expected $expected heartbeating runtime(s), found $running" >&2
    return 1
}

# ── Artifact helpers ──

_bal() {
    local bal
    bal=$(ls -d "$ROOT"/downloads/ballerina-*/bin/bal 2>/dev/null | sort -V | tail -1)
    [[ -n "$bal" ]] || { echo "bal not found in downloads/" >&2; return 1; }
    echo "$bal"
}

_bridge_version() {
    grep '^version' "$ROOT/bridge/ballerina/Ballerina.toml" | head -1 | sed 's/.*"\(.*\)"/\1/'
}

# Build a BI artifact and copy the jar to a destination directory.
# Usage: copy_bi_artifact <name> <local-bridge|remote-bridge[:version]> <dest-dir>
copy_bi_artifact() {
    local name=$1 bridge_mode=$2 dest=$3
    local src="$ROOT/artifacts/bi/$name"
    local toml="$src/Ballerina.toml"
    local bal; bal=$(_bal) || return 1

    [[ -d "$src" ]] || { echo "BI artifact not found: $src" >&2; return 1; }

    # Both files are committed (CI locks against them); this build only borrows them
    local deps="$src/Dependencies.toml"
    cp "$toml" "$toml.bak"
    [[ -f "$deps" ]] && cp "$deps" "$deps.bak"
    trap '_restore "$toml"; _restore "$deps"' RETURN

    case $bridge_mode in
        local-bridge)
            local ver; ver=$(_bridge_version)
            # Verify bridge is in local repo
            local bal_repo="$HOME/.ballerina/repositories/local/bala/wso2/icp.runtime.bridge/$ver"
            [[ -d "$bal_repo" ]] || { echo "Local bridge $ver not found. Run 'make bridge' first." >&2; return 1; }
            sed -i '' '/org = "wso2"/,/^$/{ s/version = ".*"/version = "'"$ver"'"/; }' "$toml"
            # Ensure repository="local" is present
            if ! grep -q 'repository.*=.*"local"' "$toml"; then
                sed -i '' '/name = "icp.runtime.bridge"/a\
repository="local"' "$toml"
            fi
            ;;
        remote-bridge:*)
            local ver="${bridge_mode#remote-bridge:}"
            sed -i '' '/org = "wso2"/,/^$/{ s/version = ".*"/version = "'"$ver"'"/; /repository/d; }' "$toml"
            ;;
        remote-bridge)
            sed -i '' '/org = "wso2"/,/^$/{ /repository/d; }' "$toml"
            ;;
        *)
            echo "Unknown bridge mode: $bridge_mode (use local-bridge or remote-bridge[:version])" >&2
            return 1
            ;;
    esac

    # Build
    (cd "$src" && "$bal" build) || return 1

    # Copy jar
    local pkg_name
    pkg_name=$(grep '^name' "$toml.bak" | head -1 | sed 's/.*"\(.*\)"/\1/')
    mkdir -p "$dest"
    cp "$src/target/bin/$pkg_name.jar" "$dest/$pkg_name.jar"
}

_restore() {
    [[ -f "$1.bak" ]] && mv "$1.bak" "$1"
    return 0
}

_icp_token() {
    curl -sk "$1/auth/login" -H 'Content-Type: application/json' \
        -d '{"username":"admin","password":"admin"}' |
        sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

# The id of the first RUNNING runtime, for labs that must stamp it onto telemetry themselves.
_icp_runtime_id() {
    local url=${1:-https://localhost:9446} token env
    token=$(_icp_token "$url")
    for env in $(_icp_gql "$url" "$token" '{ environments(orgUuid: "default") { items { id } } }' |
                 grep -o '"id":"[^"]*' | cut -d'"' -f4); do
        # An environment with no runtime is normal, and greps that match nothing must not look
        # like failure to a caller running under `set -e`.
        _icp_gql "$url" "$token" "{ runtimes(environmentId: \"$env\") { items { runtimeId status } } }" |
            { grep -o '"runtimeId":"[^"]*", "status":"RUNNING"' || true; } | head -1 | cut -d'"' -f4
    done
    return 0
}

_icp_running_count() {
    local url=$1 token=$2 env total=0
    for env in $(_icp_gql "$url" "$token" '{ environments(orgUuid: "default") { items { id } } }' |
                 grep -o '"id":"[^"]*' | cut -d'"' -f4); do
        total=$(( total + $(_icp_gql "$url" "$token" "{ runtimes(environmentId: \"$env\") { items { status } } }" |
                            grep -o '"status":"RUNNING"' | wc -l || true) ))
    done
    echo "$total"
}

_icp_gql() {
    curl -sk "$1/graphql" -H "Authorization: Bearer $2" -H 'Content-Type: application/json' \
        -d "{\"query\":\"${3//\"/\\\"}\"}"
}

# Copy an MI artifact XML to a destination directory.
# Usage: copy_mi_artifact <filename.xml> <dest-dir>
copy_mi_artifact() {
    local name=$1 dest=$2
    local src="$ROOT/artifacts/mi/$name"
    [[ -f "$src" ]] || { echo "MI artifact not found: $src" >&2; return 1; }
    mkdir -p "$dest"
    cp "$src" "$dest/"
}
