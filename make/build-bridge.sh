#!/usr/bin/env bash
set -euo pipefail

BAL=$1
export PATH="$(dirname "$BAL"):$PATH"  # gradle's compiler-plugin copies openapi libs from `bal home`; keep it the downloaded distribution, not a stale system bal

cd bridge
./gradlew --no-daemon build  # daemon reuse would keep a stale PATH, hiding the bal above
(cd ballerina && bal pack && bal push --repository=local)
git checkout -- '*Dependencies.toml'  # build churn; the committed lock is what CI uses
