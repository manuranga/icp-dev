#!/usr/bin/env bash
set -euo pipefail
V=$(grep '^version' ../icp-runtime-bridge/ballerina/Ballerina.toml | head -1 | sed 's/.*"\(.*\)"/\1/')
sed -i '' '/org = "wso2"/,/version =/{s/version = ".*"/version = "'$V'"/;}' Ballerina.toml
