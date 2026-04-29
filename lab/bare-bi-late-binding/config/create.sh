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

# ── BI-1 (jar only; Config.toml written later by connect-bi.sh) ──
copy_bi_artifact hello-world local-bridge "$LAB_DIR/bi"

# ── BI-2 (second app, secret obtained from project level) ──
mkdir -p "$LAB_DIR/bi2"
cp "$LAB_DIR/bi/hello_world.jar" "$LAB_DIR/bi2/hello_world.jar"

# ── CLAUDE.md ──
cp "$CONFIG_DIR/CLAUDE.md" "$LAB_DIR/CLAUDE.md"
