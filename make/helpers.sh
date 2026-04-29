#!/usr/bin/env bash

# ── Lab process management ──

logged_run() {
    local name=$1; shift
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
    local pid; pid=$(cat "$pid_file")
    pkill -P "$pid" 2>/dev/null || true
    kill "$pid" 2>/dev/null || true
    rm -f "$pid_file"
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

    # Back up Ballerina.toml
    cp "$toml" "$toml.bak"
    trap 'mv "$toml.bak" "$toml"' RETURN

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

# Copy an MI artifact XML to a destination directory.
# Usage: copy_mi_artifact <filename.xml> <dest-dir>
copy_mi_artifact() {
    local name=$1 dest=$2
    local src="$ROOT/artifacts/mi/$name"
    [[ -f "$src" ]] || { echo "MI artifact not found: $src" >&2; return 1; }
    mkdir -p "$dest"
    cp "$src" "$dest/"
}
