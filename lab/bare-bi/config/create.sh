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

# Enable OpenSearch (plain HTTP, no auth — Homebrew default).
# Prepend to deployment.toml so fields land at file top-level scope.
TOML="$LAB_DIR/icp/conf/deployment.toml"
{ echo 'opensearchUrl = "http://localhost:9200"'
  echo 'opensearchUsername = "ignored"'
  echo 'opensearchPassword = "ignored"'
  echo
  cat "$TOML"
} > "$TOML.tmp" && mv "$TOML.tmp" "$TOML"

# Seed a project secret so BI can connect
java -cp "$LAB_DIR/icp/bin/icp-server.jar" org.h2.tools.Shell \
    -url "jdbc:h2:file:$LAB_DIR/icp/bin/database/icp_db;MODE=MySQL" \
    -user icp_user -password icp_password \
    -sql "$(cat "$CONFIG_DIR/seed.sql")"

# ── BI ──
copy_bi_artifact hello-world local-bridge "$LAB_DIR/bi"
cp "$CONFIG_DIR/Config.toml" "$LAB_DIR/bi/Config.toml"

# ── Fluent Bit ──
mkdir -p "$LAB_DIR/fluent-bit/db" "$LAB_DIR/fluent-bit/buffer"
BI_LOG_DIR="$LAB_DIR/bi/logs"  # now contains app.log + metrics.log (separate files)
sed "s|\${BI_LOG_DIR}|$BI_LOG_DIR|g" "$CONFIG_DIR/fluent-bit.conf" > "$LAB_DIR/fluent-bit/fluent-bit.conf"
cp "$CONFIG_DIR/parsers.conf" "$LAB_DIR/fluent-bit/parsers.conf"
cp "$CONFIG_DIR/scripts.lua"  "$LAB_DIR/fluent-bit/scripts.lua"

# ── OpenSearch index template ──
cp "$CONFIG_DIR/opensearch-index-template.json" "$LAB_DIR/opensearch-index-template.json"
cp "$CONFIG_DIR/opensearch-metrics-index-template.json" "$LAB_DIR/opensearch-metrics-index-template.json"
