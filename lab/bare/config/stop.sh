#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

pid_stop bi
pid_stop icp
pid_stop fluent-bit
pid_stop opensearch
