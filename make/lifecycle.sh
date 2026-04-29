#!/usr/bin/env bash
set -euo pipefail

OP=$1 LAB_NAME=$2
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LAB_DIR="$ROOT/lab/$LAB_NAME"
DIST_DIR="$ROOT/dist"
CONFIG_DIR="$LAB_DIR/config"

[[ -d "$CONFIG_DIR" ]] || { echo "lab '$LAB_NAME' not found"; exit 1; }

export ROOT LAB_DIR DIST_DIR CONFIG_DIR

is_running() { [[ -x "$CONFIG_DIR/is-up.sh" ]] && "$CONFIG_DIR/is-up.sh"; }

is_stale() {
    [[ ! -f "$LAB_DIR/.created" ]] && return 0
    local f
    for f in "$DIST_DIR"/*; do
        [[ "$f" -nt "$LAB_DIR/.created" ]] && return 0
    done
    return 1
}

do_create() {
    "$CONFIG_DIR/create.sh"
    touch "$LAB_DIR/.created"
}

do_down() {
    [[ -x "$CONFIG_DIR/down.sh" ]] && "$CONFIG_DIR/down.sh"
    find "$LAB_DIR" -mindepth 1 -maxdepth 1 ! -name config ! -name '*.md' -exec rm -rf {} +
}

case $OP in
    start)
        if is_running; then echo "already running"; exit 0; fi
        if is_stale; then do_down; fi
        [[ -f "$LAB_DIR/.created" ]] || do_create
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
