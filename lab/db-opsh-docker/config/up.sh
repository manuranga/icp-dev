#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

require_ports 9445 9446 9447 9450 8290 8253 9164 9090

logged_run icp "$LAB_DIR/icp/bin/icp.sh"
wait_http ICP https://localhost:9446/

logged_run mi "$LAB_DIR/mi/bin/micro-integrator.sh"
wait_http MI https://localhost:9164/management/apis

logged_run bi bash -c "cd '$LAB_DIR/bi' && java -jar hello_world.jar"
wait_http BI http://localhost:9090/greeting

wait_for_runtimes 2
