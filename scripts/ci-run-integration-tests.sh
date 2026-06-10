#!/usr/bin/env bash
# Uruchamiane wewnatrz: firebase emulators:exec ... "bash scripts/ci-run-integration-tests.sh"
set -euo pipefail

ROOT="${GITHUB_WORKSPACE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT"

npm run seed --prefix scripts

flutter test integration_test \
  -d emulator-5554 \
  --dart-define=USE_FIREBASE_EMULATOR=true \
  --dart-define=EMULATOR_HOST=10.0.2.2
