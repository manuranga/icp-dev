#!/usr/bin/env bash
set -euo pipefail

BAL=$1 TASKS=${2:-clean build}

export PATH="$(dirname "$BAL"):$PATH"

cd icp
./gradlew --no-daemon $TASKS  # daemon reuse would keep a stale PATH, hiding the bal above
mv build/distribution/wso2-integration-control-plane-*.zip ../dist/
git checkout -- '*Dependencies.toml'  # build churn; the committed lock is what CI uses
