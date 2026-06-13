# Uruchamiane wewnatrz: firebase emulators:exec ... "powershell -File scripts/ci-run-integration-tests.ps1"
$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$ScriptsDir = Join-Path $Root "scripts"
$DeviceId = if ($env:DEVICE_ID) { $env:DEVICE_ID } else { "emulator-5554" }
$EmulatorHost = if ($env:EMULATOR_HOST) { $env:EMULATOR_HOST } else { "10.0.2.2" }

Set-Location $Root

Push-Location $ScriptsDir
try {
    npm run seed
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

flutter test integration_test/run_all_test.dart `
    -d $DeviceId `
    '--dart-define=USE_FIREBASE_EMULATOR=true' `
    "--dart-define=EMULATOR_HOST=$EmulatorHost"

exit $LASTEXITCODE
