param(
    [string]$DeviceId = "",
    [string]$EmulatorHost = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ScriptsDir = Join-Path $ProjectRoot "scripts"
Set-Location $ProjectRoot

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
    Write-Host "Szukam podlaczonego urzadzenia Android..."
    flutter devices
    $devices = flutter devices --machine | ConvertFrom-Json
    $android = $devices | Where-Object { $_.targetPlatform -match 'android' } | Select-Object -First 1
    if (-not $android) {
        Write-Error "Brak urzadzenia Android. Podlacz telefon (USB debugging) lub uruchom emulator."
    }
    $DeviceId = $android.id
    Write-Host "Uzywam urzadzenia: $DeviceId ($($android.name))"
}

if ([string]::IsNullOrWhiteSpace($EmulatorHost)) {
    if ($DeviceId -match 'emulator') {
        $EmulatorHost = "10.0.2.2"
    } else {
        . (Join-Path $PSScriptRoot "resolve-emulator-host.ps1")
        $EmulatorHost = Get-EmulatorHostLanIp
        if (-not $EmulatorHost) {
            Write-Error "Fizyczny telefon: ustaw -EmulatorHost na IP Wi-Fi (.\scripts\get-lan-ip.ps1)"
        }
    }
    Write-Host "EMULATOR_HOST = $EmulatorHost (preferowany adres Wi-Fi)"
}

Write-Host "flutter pub get..."
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Instalowanie zaleznosci npm w scripts/..."
Push-Location $ScriptsDir
try {
    npm install
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

$env:DEVICE_ID = $DeviceId
$env:EMULATOR_HOST = $EmulatorHost

Write-Host "Uruchamianie: firebase emulators:exec + ci-run-integration-tests.ps1"

& firebase emulators:exec `
    --only "auth,dataconnect,storage" `
    --project "projekt-pam-city-issues" `
    "powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ci-run-integration-tests.ps1"

exit $LASTEXITCODE
