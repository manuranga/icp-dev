#!/usr/bin/env bash
set -euo pipefail

BAL=$1

cd bi/icp-runtime-bridge
./gradlew build
cd ballerina && $BAL pack && $BAL push --repository=local
