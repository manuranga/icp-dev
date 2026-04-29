#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

# ── ICP ──
logged_run icp "$LAB_DIR/icp/bin/icp.sh"
echo "Waiting for ICP..." >&2
for i in $(seq 1 30); do
    curl -k -so /dev/null https://localhost:9446/ 2>/dev/null && break
    sleep 2
done
curl -k -so /dev/null https://localhost:9446/ 2>/dev/null || { echo "ICP failed to start" >&2; exit 1; }
echo "ICP ready" >&2

# ── MI ──
logged_run mi "$LAB_DIR/mi/bin/micro-integrator.sh"
echo "Waiting for MI..." >&2
for i in $(seq 1 30); do
    curl -k -so /dev/null https://localhost:9164/management/apis 2>/dev/null && break
    sleep 2
done
curl -k -so /dev/null https://localhost:9164/management/apis 2>/dev/null || { echo "MI failed to start" >&2; exit 1; }
echo "MI ready" >&2
