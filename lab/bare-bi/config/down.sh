#!/usr/bin/env bash
set -euo pipefail

# Clean up OpenSearch templates created by this lab
if curl -sf http://localhost:9200 >/dev/null 2>&1; then
    curl -sf -X DELETE "http://localhost:9200/_index_template/wso2_integration_application_log_template" >/dev/null 2>&1 || true
    curl -sf -X DELETE "http://localhost:9200/_index_template/wso2_integration_metrics_log_template" >/dev/null 2>&1 || true
fi
