#!/usr/bin/env bash
set -euo pipefail

docker rm -f icplab-temporal >/dev/null 2>&1 || true

if curl -sf http://localhost:9200 >/dev/null 2>&1; then
    for template in wso2_integration_application_log_template \
                    wso2_integration_metrics_log_template \
                    wso2_integration_workflow_metrics_template; do
        curl -sf -X DELETE "http://localhost:9200/_index_template/$template" >/dev/null 2>&1 || true
    done
fi
