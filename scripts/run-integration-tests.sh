#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE_ID="${DEVICE_ID:-emulator-5554}"
EMULATOR_HOST="${EMULATOR_HOST:-10.0.2.2}"

cd "$ROOT_DIR"

echo "Installing Flutter dependencies..."
flutter pub get

echo "Installing emulator seed script dependencies..."
npm install --prefix scripts

echo "Starting Firebase emulators and running integration tests..."
firebase emulators:exec \
  --only auth,dataconnect,storage \
  --project projekt-pam-city-issues \
  "npm run seed --prefix scripts && flutter test integration_test -d ${DEVICE_ID} --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=EMULATOR_HOST=${EMULATOR_HOST}"
