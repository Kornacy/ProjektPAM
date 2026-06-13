#!/usr/bin/env bash
# Uruchamiane wewnatrz: firebase emulators:exec ... "bash scripts/ci-run-integration-tests.sh"
set -euo pipefail

ROOT="${GITHUB_WORKSPACE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT"

DEVICE_ID="${DEVICE_ID:-emulator-5554}"
EMULATOR_HOST="${EMULATOR_HOST:-10.0.2.2}"

(cd scripts && npm run seed)

flutter test integration_test/run_all_test.dart \
  -d "$DEVICE_ID" \
  --dart-define=USE_FIREBASE_EMULATOR=true \
  --dart-define=EMULATOR_HOST="$EMULATOR_HOST"
