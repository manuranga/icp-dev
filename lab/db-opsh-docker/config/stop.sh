#!/usr/bin/env bash
set -euo pipefail
source "$ROOT/make/helpers.sh"

pid_stop icp
pid_stop mi
pid_stop bi
