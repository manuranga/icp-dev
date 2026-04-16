#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$ENV_DIR/mounts/postgres" "$ENV_DIR/mounts/opensearch" \
         "$ENV_DIR/mounts/fluent-bit-db" "$ENV_DIR/mounts/fluent-bit-buffer" \
         "$ENV_DIR/logs/bi" "$ENV_DIR/logs/mi" \
         "$ENV_DIR/logs/wire-dump" "$ENV_DIR/logs/wire-dump/.db-offsets"

docker compose -f "$CONFIG_DIR/docker-compose.yml" --project-directory "$ENV_DIR" build

for img in $(docker compose -f "$CONFIG_DIR/docker-compose.yml" --project-directory "$ENV_DIR" config --images); do
    docker image inspect -f '{{.ID}}' "$img" 2>/dev/null
done | sort -u > "$ENV_DIR/.created"
