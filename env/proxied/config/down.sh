#!/usr/bin/env bash
set -euo pipefail

docker compose -p proxied down --rmi local --volumes --remove-orphans 2>/dev/null || true
