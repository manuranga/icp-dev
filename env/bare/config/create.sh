#!/usr/bin/env bash
set -euo pipefail

_glob_one() {
    local matches=($1)
    (( ${#matches[@]} == 1 )) && [[ -f "${matches[0]}" ]] || { echo "expected exactly one match: $1" >&2; return 1; }
    echo "${matches[0]}"
}

# ── ICP ──
DIST_ICP_ZIP=$(_glob_one "$DIST_DIR/wso2-integration-control-plane-*.zip")
unzip -qo "$DIST_ICP_ZIP" -d "$ENV_DIR" && mv "$ENV_DIR"/wso2-integration-control-plane-* "$ENV_DIR/icp"

# Enable OpenSearch (plain HTTP, no auth — Homebrew default).
# Prepend to deployment.toml so fields land at file top-level scope.
TOML="$ENV_DIR/icp/conf/deployment.toml"
{ echo 'opensearchUrl = "http://localhost:9200"'
  echo 'opensearchUsername = "ignored"'
  echo 'opensearchPassword = "ignored"'
  echo
  cat "$TOML"
} > "$TOML.tmp" && mv "$TOML.tmp" "$TOML"

# Seed a project secret so BI can connect
java -cp "$ENV_DIR/icp/bin/icp-server.jar" org.h2.tools.Shell \
    -url "jdbc:h2:file:$ENV_DIR/icp/bin/database/icp_db;MODE=MySQL" \
    -user icp_user -password icp_password \
    -sql "$(cat "$CONFIG_DIR/seed.sql")"

# ── BI ──
mkdir -p "$ENV_DIR/bi"
cp "$DIST_DIR/icp.jar" "$ENV_DIR/bi/icp.jar"
cp "$CONFIG_DIR/Config.toml" "$ENV_DIR/bi/Config.toml"

# ── Fluent Bit ──
mkdir -p "$ENV_DIR/fluent-bit/db" "$ENV_DIR/fluent-bit/buffer"
BI_LOG_DIR="$ENV_DIR/bi/logs"
sed "s|\${BI_LOG_DIR}|$BI_LOG_DIR|g" "$CONFIG_DIR/fluent-bit.conf" > "$ENV_DIR/fluent-bit/fluent-bit.conf"
cp "$CONFIG_DIR/parsers.conf" "$ENV_DIR/fluent-bit/parsers.conf"
cp "$CONFIG_DIR/scripts.lua"  "$ENV_DIR/fluent-bit/scripts.lua"

# ── OpenSearch index template ──
cp "$CONFIG_DIR/opensearch-index-template.json" "$ENV_DIR/opensearch-index-template.json"
