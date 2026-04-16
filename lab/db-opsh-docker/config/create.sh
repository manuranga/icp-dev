#!/usr/bin/env bash
set -euo pipefail

_glob_one() {
    local matches=($1)
    (( ${#matches[@]} == 1 )) && [[ -f "${matches[0]}" ]] || { echo "expected exactly one match: $1" >&2; return 1; }
    echo "${matches[0]}"
}

DIST_ICP_ZIP=$(_glob_one "$DIST_DIR/wso2-integration-control-plane-*.zip")
DIST_MI_ZIP=$(_glob_one "$DIST_DIR/wso2mi-*.zip")

unzip -qo "$DIST_ICP_ZIP" -d "$LAB_DIR" && mv "$LAB_DIR"/wso2-integration-control-plane-* "$LAB_DIR/icp"
unzip -qo "$DIST_MI_ZIP"  -d "$LAB_DIR" && mv "$LAB_DIR"/wso2mi-*  "$LAB_DIR/mi"
mkdir -p "$LAB_DIR/bi"
cp "$DIST_DIR/icp.jar" "$LAB_DIR/bi/icp.jar"
cp "$CONFIG_DIR/Config.toml" "$LAB_DIR/bi/Config.toml"

if [[ -f "$CONFIG_DIR/icp.patch" ]]; then patch -d "$LAB_DIR/icp" -p1 < "$CONFIG_DIR/icp.patch"; fi
if [[ -f "$CONFIG_DIR/mi.patch" ]];  then patch -d "$LAB_DIR/mi"  -p1 < "$CONFIG_DIR/mi.patch"; fi

java -cp "$LAB_DIR/icp/bin/icp-server.jar" org.h2.tools.Shell \
    -url "jdbc:h2:file:$LAB_DIR/icp/bin/database/icp_db;MODE=MySQL" \
    -user icp_user -password icp_password \
    -sql "$(cat "$CONFIG_DIR/seed.sql")"
