#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

_glob_one() {
    local matches=($1)
    (( ${#matches[@]} == 1 )) && [[ -f "${matches[0]}" ]] || { echo "expected exactly one match: $1" >&2; return 1; }
    echo "${matches[0]}"
}

# ── ICP ──
DIST_ICP_ZIP=$(_glob_one "$DIST_DIR/wso2-integration-control-plane-*.zip")
unzip -qo "$DIST_ICP_ZIP" -d "$LAB_DIR" && mv "$LAB_DIR"/wso2-integration-control-plane-* "$LAB_DIR/icp"

# OpenSearch, plain HTTP and no auth (Homebrew default). Prepended so the fields land at
# the toml's top-level scope.
TOML="$LAB_DIR/icp/conf/deployment.toml"
{ echo 'opensearchUrl = "http://localhost:9200"'
  echo 'opensearchUsername = "ignored"'
  echo 'opensearchPassword = "ignored"'
  echo
  cat "$TOML"
} > "$TOML.tmp" && mv "$TOML.tmp" "$TOML"

java -cp "$LAB_DIR/icp/bin/icp-server.jar" org.h2.tools.Shell \
    -url "jdbc:h2:file:$LAB_DIR/icp/bin/database/icp_db;MODE=MySQL" \
    -user icp_user -password icp_password \
    -sql "$(cat "$CONFIG_DIR/seed.sql")"

# ── The workflow artifact ──
# copy_bi_artifact checks the bridge; the engine is this lab's other local dependency.
WORKFLOW_VERSION=$(sed -n 's/^version = "\(.*\)"/\1/p' "$ROOT/workflow/ballerina/Ballerina.toml" | head -1)
[[ -d "$HOME/.ballerina/repositories/local/bala/ballerina/workflow/$WORKFLOW_VERSION" ]] ||
    { echo "ballerina/workflow $WORKFLOW_VERSION not in the local repository — run 'make workflow' first." >&2; exit 1; }

copy_bi_artifact claims-workflow local-bridge "$LAB_DIR/bi"
cp "$CONFIG_DIR/Config.toml" "$LAB_DIR/bi/Config.toml"

# ── Fluent Bit ──
mkdir -p "$LAB_DIR/fluent-bit/db" "$LAB_DIR/fluent-bit/buffer"
sed -e "s|\${BI_LOG_DIR}|$LAB_DIR/bi/logs|g" \
    -e "s|\${BI_STDOUT_LOG}|$LAB_DIR/logs/bi.log|g" \
    "$CONFIG_DIR/fluent-bit.conf" > "$LAB_DIR/fluent-bit/fluent-bit.conf"
cp "$CONFIG_DIR/parsers.conf" "$CONFIG_DIR/scripts.lua" "$LAB_DIR/fluent-bit/"

cp "$CONFIG_DIR"/opensearch-*-template.json "$LAB_DIR/"
