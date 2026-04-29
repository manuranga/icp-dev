#!/usr/bin/env bash
# Writes sample BI logfmt lines to simulate a running BI app.
# Usage: ./config/generate-sample-logs.sh [count]
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$DIR/logs/bi/sample-app"
LOG_FILE="$LOG_DIR/app.log"
COUNT="${1:-10}"

mkdir -p "$LOG_DIR"

now_iso() { date -u +"%Y-%m-%dT%H:%M:%S.000+0000"; }

for i in $(seq 1 "$COUNT"); do
    ts=$(now_iso)

    echo "time=$ts level=INFO module=myorg/myapp message=\"Processing request $i\" logger=myapp.main" >> "$LOG_FILE"

    echo "time=$ts level=INFO module=myorg/myapp logger=metrics protocol=HTTP src.object.name=hello entrypoint.function.name=get http.method=GET http.url=/hello http.status_code_group=2xx response_time_seconds=0.0$((RANDOM % 99 + 1))" >> "$LOG_FILE"

    if (( i % 5 == 0 )); then
        echo "time=$ts level=WARN module=myorg/myapp message=\"Slow response detected for request $i\" logger=myapp.monitor" >> "$LOG_FILE"
    fi

    if (( i % 7 == 0 )); then
        echo "time=$ts level=INFO module=myorg/myapp logger=metrics protocol=HTTP src.object.name=hello entrypoint.function.name=get http.method=POST http.url=/hello http.status_code_group=5xx response_time_seconds=1.$((RANDOM % 99 + 1))" >> "$LOG_FILE"
    fi

    sleep 0.1
done

echo "Wrote $COUNT log entries (with metrics) to $LOG_FILE"
