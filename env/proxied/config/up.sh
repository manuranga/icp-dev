#!/usr/bin/env bash
set -euo pipefail

docker compose -f "$CONFIG_DIR/docker-compose.yml" --project-directory "$ENV_DIR" up -d
