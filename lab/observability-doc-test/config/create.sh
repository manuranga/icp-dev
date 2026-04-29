#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

_glob_one() {
    local matches=($1)
    (( ${#matches[@]} == 1 )) && [[ -f "${matches[0]}" ]] || { echo "expected exactly one match: $1" >&2; return 1; }
    echo "${matches[0]}"
}

# ── Step 1: OpenSearch is Homebrew-installed, no setup needed ──

# ── Step 3: ICP Server ──
DIST_ICP_ZIP=$(_glob_one "$DIST_DIR/wso2-integration-control-plane-*.zip")
unzip -qo "$DIST_ICP_ZIP" -d "$LAB_DIR" && mv "$LAB_DIR"/wso2-integration-control-plane-* "$LAB_DIR/icp"

# Doc says: add opensearch connection to deployment.toml
TOML="$LAB_DIR/icp/conf/deployment.toml"
{ echo 'opensearchUrl = "http://localhost:9200"'
  echo 'opensearchUsername = "ignored"'
  echo 'opensearchPassword = "ignored"'
  echo
  cat "$TOML"
} > "$TOML.tmp" && mv "$TOML.tmp" "$TOML"

# ── Step 4: BI Application ──
copy_bi_artifact hello-world local-bridge "$LAB_DIR/bi"
cp "$CONFIG_DIR/Config.toml" "$LAB_DIR/bi/Config.toml"

# ── Step 5: Fluent Bit ──
mkdir -p "$LAB_DIR/fluent-bit/db" "$LAB_DIR/fluent-bit/buffer"
BI_LOG_DIR="$LAB_DIR/bi/logs"
sed "s|\${BI_LOG_DIR}|$BI_LOG_DIR|g" "$CONFIG_DIR/fluent-bit.conf" > "$LAB_DIR/fluent-bit/fluent-bit.conf"
cp "$CONFIG_DIR/parsers.conf" "$LAB_DIR/fluent-bit/parsers.conf"
cp "$CONFIG_DIR/scripts.lua"  "$LAB_DIR/fluent-bit/scripts.lua"

# ── Step 2: Index template ──
cp "$CONFIG_DIR/opensearch-index-template.json" "$LAB_DIR/opensearch-index-template.json"
cp "$CONFIG_DIR/opensearch-metrics-index-template.json" "$LAB_DIR/opensearch-metrics-index-template.json"
