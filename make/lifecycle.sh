#!/usr/bin/env bash
set -euo pipefail

OP=$1 ENV_NAME=$2
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_DIR="$ROOT/env/$ENV_NAME"
DIST_DIR="$ROOT/dist"
CONFIG_DIR="$ENV_DIR/config"

[[ -d "$CONFIG_DIR" ]] || { echo "env '$ENV_NAME' not found"; exit 1; }

export ROOT ENV_DIR DIST_DIR CONFIG_DIR

is_running() { [[ -x "$CONFIG_DIR/is-up.sh" ]] && "$CONFIG_DIR/is-up.sh"; }

is_stale() {
    [[ ! -f "$ENV_DIR/.created" ]] && return 0
    local f
    for f in "$DIST_DIR"/*; do
        [[ "$f" -nt "$ENV_DIR/.created" ]] && return 0
    done
    return 1
}

do_create() {
    "$CONFIG_DIR/create.sh"
    touch "$ENV_DIR/.created"
}

do_down() {
    [[ -x "$CONFIG_DIR/down.sh" ]] && "$CONFIG_DIR/down.sh"
    find "$ENV_DIR" -mindepth 1 -maxdepth 1 ! -name config -exec rm -rf {} +
}

case $OP in
    start)
        if is_running; then echo "already running"; exit 0; fi
        if is_stale; then do_down; fi
        [[ -f "$ENV_DIR/.created" ]] || do_create
        "$CONFIG_DIR/up.sh"
        ;;
    stop)
        "$CONFIG_DIR/stop.sh"
        ;;
    reset)
        "$CONFIG_DIR/stop.sh" || true
        do_down
        do_create
        "$CONFIG_DIR/up.sh"
        ;;
esac
