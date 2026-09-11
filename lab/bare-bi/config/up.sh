#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

require_ports 9445 9446 9447 9450 9090 2020  # not 9200: OpenSearch is shared host-wide

# ── OpenSearch (host-wide brew daemon, shared with other labs) ──
curl -sf -o /dev/null http://localhost:9200 || logged_run opensearch opensearch
wait_http OpenSearch http://localhost:9200

for template in wso2_integration_application_log_template \
                wso2_integration_metrics_log_template \
                wso2_mi_application_log_template; do
    curl -s -X DELETE "http://localhost:9200/_index_template/$template" >/dev/null 2>&1 || true
done

curl -sf -X PUT "http://localhost:9200/_index_template/wso2_integration_application_log_template" \
    -H "Content-Type: application/json" \
    -d @"$LAB_DIR/opensearch-index-template.json" >&2
curl -sf -X PUT "http://localhost:9200/_index_template/wso2_integration_metrics_log_template" \
    -H "Content-Type: application/json" \
    -d @"$LAB_DIR/opensearch-metrics-index-template.json" >&2
echo >&2

# ── Fluent Bit ──
logged_run fluent-bit bash -c "cd '$LAB_DIR/fluent-bit' && fluent-bit -c fluent-bit.conf"
echo "Fluent Bit started" >&2

# ── ICP ──
logged_run icp "$LAB_DIR/icp/bin/icp.sh"
wait_http ICP https://localhost:9446/

# ── BI ──
logged_run bi bash -c "cd '$LAB_DIR/bi' && java -jar hello_world.jar"
wait_http BI http://localhost:9090/greeting

wait_for_runtimes 1
