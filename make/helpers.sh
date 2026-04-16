#!/usr/bin/env bash

logged_run() {
    local name=$1; shift
    local pid_dir="$LAB_DIR/pids" log_dir="$LAB_DIR/logs"
    mkdir -p "$pid_dir" "$log_dir"
    "$@" >> "$log_dir/$name.log" 2>&1 &
    echo $! > "$pid_dir/$name.pid"
}

pid_alive() {
    local pid_file="$LAB_DIR/pids/$1.pid"
    [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null
}

pid_stop() {
    local pid_file="$LAB_DIR/pids/$1.pid"
    [[ -f "$pid_file" ]] || return 0
    local pid; pid=$(cat "$pid_file")
    pkill -P "$pid" 2>/dev/null || true
    kill "$pid" 2>/dev/null || true
    rm -f "$pid_file"
}
