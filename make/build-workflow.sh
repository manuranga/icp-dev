#!/usr/bin/env bash
set -euo pipefail

BAL=$1
export PATH="$(dirname "$BAL"):$PATH"  # gradle's compiler-plugin resolves against `bal home`; keep it the downloaded distribution

cd workflow
./gradlew --no-daemon build -x test  # the module's own tests need a Temporal server
(cd ballerina && bal pack && bal push --repository=local)
git checkout -- '*Dependencies.toml'  # build churn; the committed lock is what CI uses
