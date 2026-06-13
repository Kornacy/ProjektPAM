# Tylko flutter test (emulatory i seed musza juz dzialac).
# Zawsze uruchamiaj z katalogu glownego: .\run-flutter-integration-tests.ps1

param(
    [string]$DeviceId = "cb475b22",
    [string]$EmulatorHost = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($EmulatorHost)) {
    if ($DeviceId -match 'emulator') {
        $EmulatorHost = "10.0.2.2"
    } else {
        . (Join-Path $PSScriptRoot "scripts\resolve-emulator-host.ps1")
        $EmulatorHost = Get-EmulatorHostLanIp
        if (-not $EmulatorHost) {
            Write-Error "Ustaw -EmulatorHost (np. IP Wi-Fi). Sprawdz: .\scripts\get-lan-ip.ps1"
        }
    }
}

Write-Host "Katalog: $PWD"
Write-Host "Urzadzenie: $DeviceId"
Write-Host "EMULATOR_HOST: $EmulatorHost"
Write-Host ""

flutter test integration_test/run_all_test.dart `
    -d $DeviceId `
    '--dart-define=USE_FIREBASE_EMULATOR=true' `
    "--dart-define=EMULATOR_HOST=$EmulatorHost"
