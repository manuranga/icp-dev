#!/usr/bin/env bash
source "$ROOT/make/helpers.sh"
# OpenSearch is a host-wide brew daemon whose launcher exits, and Temporal is a container:
# check those by port/engine, the rest by pid.
curl -sf -o /dev/null http://localhost:9200 \
    && docker ps --filter name=^icplab-temporal$ --filter status=running -q | grep -q . \
    && pid_alive fluent-bit && pid_alive icp && pid_alive bi
