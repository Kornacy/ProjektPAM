param(
    # ID urzadzenia z `flutter devices` (np. cb475b22 lub emulator-5554)
    [string]$DeviceId = "",
    # Host PC z perspektywy telefonu/emulatora (10.0.2.2 = emulator Androida)
    [string]$EmulatorHost = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
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
        $lan = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object {
                $_.IPAddress -notlike '127.*' -and
                $_.IPAddress -notlike '169.254.*'
            } |
            Select-Object -First 1 -ExpandProperty IPAddress
        if (-not $lan) {
            Write-Error "Fizyczny telefon: ustaw -EmulatorHost na IP komputera (ipconfig / scripts\get-lan-ip.ps1)"
        }
        $EmulatorHost = $lan
    }
    Write-Host "EMULATOR_HOST = $EmulatorHost"
}

Write-Host "flutter pub get..."
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& (Join-Path $PSScriptRoot "seed.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$testCmd = "flutter test integration_test -d $DeviceId --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=EMULATOR_HOST=$EmulatorHost"
Write-Host "Uruchamianie: $testCmd"

firebase emulators:exec `
    --only auth,dataconnect,storage `
    --project projekt-pam-city-issues `
    $testCmd

exit $LASTEXITCODE
