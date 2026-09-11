#!/usr/bin/env bash
source "$ROOT/make/helpers.sh"
# OpenSearch is a host-wide brew daemon whose launcher exits: check the port, not a pid
curl -sf -o /dev/null http://localhost:9200 && pid_alive fluent-bit && pid_alive icp && pid_alive bi
