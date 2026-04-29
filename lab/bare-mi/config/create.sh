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

# Seed MI secret into H2
java -cp "$LAB_DIR/icp/bin/icp-server.jar" org.h2.tools.Shell \
    -url "jdbc:h2:file:$LAB_DIR/icp/bin/database/icp_db;MODE=MySQL" \
    -user icp_user -password icp_password \
    -sql "$(cat "$CONFIG_DIR/seed.sql")"

# ── MI ──
DIST_MI_ZIP=$(_glob_one "$DIST_DIR/wso2mi-*.zip")
unzip -qo "$DIST_MI_ZIP" -d "$LAB_DIR" && mv "$LAB_DIR"/wso2mi-* "$LAB_DIR/mi"

# Configure MI → ICP connection
cat >> "$LAB_DIR/mi/conf/deployment.toml" <<'EOF'

[icp_config]
enabled = true
icp_url = "https://localhost:9445"
environment = "dev"
project = "sample-project"
integration = "mi-artifacts-integration"
secret = "tmpmi.mi-artifacts-lab-secret-that-is-at-least-32-bytes-long"
ssl_verify = false
EOF

# Deploy sample artifacts into MI
SYNAPSE="$LAB_DIR/mi/repository/deployment/server/synapse-configs/default"
copy_mi_artifact HealthCheckAPI.xml          "$SYNAPSE/api/"
copy_mi_artifact SampleProxyService.xml      "$SYNAPSE/proxy-services/"
copy_mi_artifact SampleSequence.xml          "$SYNAPSE/sequences/"
copy_mi_artifact SampleEndpoint.xml          "$SYNAPSE/endpoints/"
copy_mi_artifact SampleInboundEndpoint.xml   "$SYNAPSE/inbound-endpoints/"
copy_mi_artifact SampleTask.xml              "$SYNAPSE/tasks/"
copy_mi_artifact SampleLocalEntry.xml        "$SYNAPSE/local-entries/"
copy_mi_artifact SampleMessageStore.xml      "$SYNAPSE/message-stores/"
copy_mi_artifact SampleMessageProcessor.xml  "$SYNAPSE/message-processors/"
copy_mi_artifact SampleTemplate.xml          "$SYNAPSE/templates/"
