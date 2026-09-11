#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

require_ports 9445 9446 9447 9450 8290 8253 9164 8095

# ── ICP ──
logged_run icp "$LAB_DIR/icp/bin/icp.sh"
wait_http ICP https://localhost:9446/

# ── MI ──
logged_run mi "$LAB_DIR/mi/bin/micro-integrator.sh"
wait_http MI https://localhost:9164/management/apis

wait_for_runtimes 1
