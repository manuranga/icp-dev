#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

pid_stop bi
pid_stop icp
pid_stop fluent-bit
pid_stop opensearch
docker rm -f icplab-temporal >/dev/null 2>&1 || true
