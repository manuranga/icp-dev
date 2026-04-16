#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$LAB_DIR/mounts/postgres" "$LAB_DIR/mounts/opensearch" \
         "$LAB_DIR/mounts/fluent-bit-db" "$LAB_DIR/mounts/fluent-bit-buffer" \
         "$LAB_DIR/logs/bi" "$LAB_DIR/logs/mi" \
         "$LAB_DIR/logs/wire-dump" "$LAB_DIR/logs/wire-dump/.db-offsets"

docker compose -f "$CONFIG_DIR/docker-compose.yml" --project-directory "$LAB_DIR" build

for img in $(docker compose -f "$CONFIG_DIR/docker-compose.yml" --project-directory "$LAB_DIR" config --images); do
    docker image inspect -f '{{.ID}}' "$img" 2>/dev/null
done | sort -u > "$LAB_DIR/.created"
