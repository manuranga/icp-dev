#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

require_ports 9445 9446 9447 9450 8290 7233 8233 2020  # not 9200: OpenSearch is shared host-wide

# ── Temporal ──
# The CLI image's dev server: one container, in-memory persistence, no database. Runs are lost
# when it stops, which is what a lab wants — `make reset claims-workflow` means an empty console.
# Pinned: `latest` would move the server under a lab whose whole point is a fixed baseline.
TEMPORAL_IMAGE=temporalio/temporal:1.8.3
if ! docker ps --filter name=^icplab-temporal$ --filter status=running -q | grep -q .; then
    docker rm -f icplab-temporal >/dev/null 2>&1 || true
    docker run -d --name icplab-temporal -p 7233:7233 -p 8233:8233 \
        "$TEMPORAL_IMAGE" server start-dev --ip 0.0.0.0 --ui-ip 0.0.0.0 >/dev/null
fi
for i in $(seq 1 30); do
    docker exec icplab-temporal temporal operator cluster health 2>/dev/null | grep -q SERVING && break
    (( i < 30 )) || { echo "Temporal never reported SERVING" >&2; exit 1; }
    sleep 2
done
echo "Temporal ready" >&2

# ── OpenSearch (host-wide brew daemon, shared with other labs) ──
curl -sf -o /dev/null http://localhost:9200 || logged_run opensearch opensearch
wait_http OpenSearch http://localhost:9200

# A leftover template from an earlier session blocks the put, so delete then re-put.
for template in wso2_integration_application_log_template \
                wso2_integration_metrics_log_template \
                wso2_integration_workflow_metrics_template; do
    curl -s -X DELETE "http://localhost:9200/_index_template/$template" >/dev/null 2>&1 || true
done

curl -sf -X PUT "http://localhost:9200/_index_template/wso2_integration_application_log_template" \
    -H "Content-Type: application/json" -d @"$LAB_DIR/opensearch-index-template.json" >&2
curl -sf -X PUT "http://localhost:9200/_index_template/wso2_integration_metrics_log_template" \
    -H "Content-Type: application/json" -d @"$LAB_DIR/opensearch-metrics-index-template.json" >&2
curl -sf -X PUT "http://localhost:9200/_index_template/wso2_integration_workflow_metrics_template" \
    -H "Content-Type: application/json" -d @"$LAB_DIR/opensearch-workflow-metrics-index-template.json" >&2
echo >&2

# ── ICP ──
logged_run icp "$LAB_DIR/icp/bin/icp.sh"
wait_http ICP https://localhost:9446/

# ── The workflow artifact ──
logged_run bi bash -c "cd '$LAB_DIR/bi' && java -jar claims_workflow.jar"
wait_http claims-workflow http://localhost:8290/claims

wait_for_runtimes 1

# ── Fluent Bit ──
# Started last, and only once the runtime has registered: the workflow module's worker prints its
# samples from Java with no runtime id on them, and the console's metrics query filters by one, so
# the id has to be stamped on. Nothing is lost by waiting — the tails read from the head.
RUNTIME_ID=$(_icp_runtime_id)
[[ -n "$RUNTIME_ID" ]] || { echo "no RUNNING runtime to stamp onto the worker's samples" >&2; exit 1; }
cat > "$LAB_DIR/fluent-bit/runtime-id.conf" <<EOF
[FILTER]
   Name   record_modifier
   Match  ballerina_worker_stdout
   Record icp_runtimeId $RUNTIME_ID
EOF
logged_run fluent-bit bash -c "cd '$LAB_DIR/fluent-bit' && fluent-bit -c fluent-bit.conf"
echo "Fluent Bit started" >&2
