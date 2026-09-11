#!/usr/bin/env bash
# Bind BI to ICP with a secret copied from the UI.
# Usage: connect-bi.sh < snippet.toml     (or: pbpaste | connect-bi.sh)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
LAB_DIR="$ROOT/lab/bare-bi-late-binding"
export ROOT LAB_DIR
source "$ROOT/make/helpers.sh"

CONFIG="$LAB_DIR/bi/Config.toml"
cat > "$CONFIG"
[[ -s "$CONFIG" ]] || { echo "no snippet on stdin" >&2; exit 1; }

sed -i '' \
    -e 's|<project name>|sample-project|' \
    -e 's|<integration name>|sample-integration|' \
    -e 's|<unique id for the runtime>|bare-bi-late-binding|' \
    -e 's|# serverUrl=.*|serverUrl = "https://localhost:9445"|' \
    "$CONFIG"

cat >> "$CONFIG" <<'EOF'
heartbeatInterval = 10

[ballerina.log]
format = "logfmt"
EOF

echo "Config.toml written:" >&2
cat "$CONFIG" >&2

logged_run bi bash -c "cd '$LAB_DIR/bi' && java -jar hello_world.jar"
wait_http BI http://localhost:9090/greeting
wait_for_runtimes 1
