#!/usr/bin/env bash
source "$ROOT/make/helpers.sh"
pid_alive opensearch || pid_alive fluent-bit || pid_alive icp || pid_alive bi
