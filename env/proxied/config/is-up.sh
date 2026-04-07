#!/usr/bin/env bash

table=$(docker compose -p proxied ps 2>/dev/null)
ok=true
for svc in icp proxy mi bi; do
  echo "$table" | grep -qE "proxied-${svc}-.*Up" || { echo "$svc is not up"; ok=false; }
done
$ok || exit 1
echo -e "\n${table}\n\nUI: https://localhost:9460/"
