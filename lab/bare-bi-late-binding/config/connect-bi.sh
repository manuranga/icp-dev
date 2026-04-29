#!/usr/bin/env bash
# Obtain a secret from the ICP UI via playwright-cli, write Config.toml, start BI.
set -euo pipefail
source "$ROOT/make/helpers.sh"

echo "Obtaining BI secret from ICP UI via playwright-cli..." >&2
SNIPPET=$("$CONFIG_DIR/obtain-secret.sh")
[[ -n "$SNIPPET" ]] || { echo "Failed to obtain secret snippet" >&2; exit 1; }
echo "Secret obtained" >&2

# Fill in placeholders
CONFIG="$LAB_DIR/bi/Config.toml"
echo "$SNIPPET" > "$CONFIG"

sed -i '' \
    -e 's|<project name>|sample-project|' \
    -e 's|<integration name>|sample-integration|' \
    -e 's|<unique id for the runtime>|bare-bi-late-binding|' \
    -e 's|# serverUrl=.*|serverUrl = "https://localhost:9445"|' \
    "$CONFIG"

# Append extra settings
cat >> "$CONFIG" <<'EOF'
heartbeatInterval = 10

[ballerina.log]
format = "logfmt"
EOF

echo "Config.toml written:" >&2
cat "$CONFIG" >&2
echo >&2

# ── Start BI ──
logged_run bi bash -c "cd '$LAB_DIR/bi' && java -jar hello_world.jar"
echo "BI started" >&2
