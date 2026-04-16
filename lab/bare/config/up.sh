#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

# ── OpenSearch ──
logged_run opensearch opensearch
echo "Waiting for OpenSearch..." >&2
for i in $(seq 1 30); do
    curl -sf http://localhost:9200 >/dev/null 2>&1 && break
    sleep 2
done
curl -sf http://localhost:9200 >/dev/null || { echo "OpenSearch failed to start" >&2; exit 1; }
echo "OpenSearch ready" >&2

curl -sf -X PUT "http://localhost:9200/_index_template/integration-logs" \
    -H "Content-Type: application/json" \
    -d @"$LAB_DIR/opensearch-index-template.json" >&2
echo >&2

# ── Fluent Bit ──
logged_run fluent-bit bash -c "cd '$LAB_DIR/fluent-bit' && fluent-bit -c fluent-bit.conf"
echo "Fluent Bit started" >&2

# ── ICP ──
logged_run icp "$LAB_DIR/icp/bin/icp.sh"

# ── BI ──
logged_run bi bash -c "cd '$LAB_DIR/bi' && java -jar icp.jar"
