#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

logged_run icp "$ENV_DIR/icp/bin/icp.sh"
logged_run mi  "$ENV_DIR/mi/bin/micro-integrator.sh"
logged_run bi  bash -c "cd '$ENV_DIR/bi' && java -jar icp.jar"
