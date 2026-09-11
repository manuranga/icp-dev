#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

# compose publishes only 9460 (proxy → ICP) and gates services on healthchecks
docker compose -f "$CONFIG_DIR/docker-compose.yml" --project-directory "$LAB_DIR" up -d

wait_http ICP https://localhost:9460/
wait_for_runtimes 2 https://localhost:9460
