#!/usr/bin/env bash
set -euo pipefail
label=$1; shift
log="/tmp/icp-dev/${label}.log"
mkdir -p /tmp/icp-dev
printf '%s %s' "$label" "$log"
if eval "$@" >>"$log" 2>&1; then
    echo " ok"
else
    echo " failed"
    exit 1
fi
