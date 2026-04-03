#!/usr/bin/env bash
set -euo pipefail

_glob_one() {
    local matches=($1)
    (( ${#matches[@]} == 1 )) && [[ -f "${matches[0]}" ]] || { echo "expected exactly one match: $1" >&2; return 1; }
    echo "${matches[0]}"
}

DIST_ICP_ZIP=$(_glob_one "$DIST_DIR/wso2-integration-control-plane-*.zip")
DIST_MI_ZIP=$(_glob_one "$DIST_DIR/wso2mi-*.zip")

unzip -qo "$DIST_ICP_ZIP" -d "$ENV_DIR" && mv "$ENV_DIR"/wso2-integration-control-plane-* "$ENV_DIR/icp"
unzip -qo "$DIST_MI_ZIP"  -d "$ENV_DIR" && mv "$ENV_DIR"/wso2mi-*  "$ENV_DIR/mi"
mkdir -p "$ENV_DIR/bi"
cp "$DIST_DIR/icp.jar" "$ENV_DIR/bi/icp.jar"
cp "$CONFIG_DIR/Config.toml" "$ENV_DIR/bi/Config.toml"

if [[ -f "$CONFIG_DIR/icp.patch" ]]; then patch -d "$ENV_DIR/icp" -p1 < "$CONFIG_DIR/icp.patch"; fi
if [[ -f "$CONFIG_DIR/mi.patch" ]];  then patch -d "$ENV_DIR/mi"  -p1 < "$CONFIG_DIR/mi.patch"; fi

java -cp "$ENV_DIR/icp/bin/icp-server.jar" org.h2.tools.Shell \
    -url "jdbc:h2:file:$ENV_DIR/icp/bin/database/icp_db;MODE=MySQL" \
    -user icp_user -password icp_password \
    -sql "$(cat "$CONFIG_DIR/seed.sql")"
