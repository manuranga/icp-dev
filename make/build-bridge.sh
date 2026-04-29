#!/usr/bin/env bash
set -euo pipefail

BAL=$1

cd bridge
./gradlew build
cd ballerina && $BAL pack && $BAL push --repository=local
