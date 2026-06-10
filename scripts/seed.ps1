# Seeduje kategorie w działającym emulatorze Data Connect.
# Wymaga: firebase emulators:start (auth + dataconnect + storage) w osobnym terminalu.

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not $env:FIREBASE_DATACONNECT_EMULATOR_HOST) {
    $env:FIREBASE_DATACONNECT_EMULATOR_HOST = "127.0.0.1:9399"
}
if (-not $env:FIREBASE_AUTH_EMULATOR_HOST) {
    $env:FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099"
}

if (-not (Test-Path "node_modules\firebase-admin")) {
    Write-Host "Instalowanie zaleznosci npm w scripts/ ..."
    npm install
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "Seedowanie emulatora Data Connect..."
npm run seed
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Seed OK. Testy uruchom z KATALOGU GLOWNEGO projektu:"
Write-Host "  cd .."
Write-Host "  .\run-flutter-integration-tests.ps1 -DeviceId cb475b22"
Write-Host ""
exit 0
