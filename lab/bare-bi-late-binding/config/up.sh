#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

require_ports 9445 9446 9447 9450 9090

logged_run icp "$LAB_DIR/icp/bin/icp.sh"
wait_http ICP https://localhost:9446/

cat >&2 <<EOF

BI is not started: this lab binds it late, with a secret you copy from the UI.
Next: read the Config.toml snippet at https://localhost:9446 (admin/admin), then

    lab/bare-bi-late-binding/config/connect-bi.sh < snippet.toml
EOF
