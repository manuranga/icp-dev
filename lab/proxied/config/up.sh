#!/usr/bin/env bash
set -euo pipefail

docker compose -f "$CONFIG_DIR/docker-compose.yml" --project-directory "$LAB_DIR" up -d
