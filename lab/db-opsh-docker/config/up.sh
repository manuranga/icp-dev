#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

logged_run icp "$LAB_DIR/icp/bin/icp.sh"
logged_run mi  "$LAB_DIR/mi/bin/micro-integrator.sh"
logged_run bi  bash -c "cd '$LAB_DIR/bi' && java -jar icp.jar"
