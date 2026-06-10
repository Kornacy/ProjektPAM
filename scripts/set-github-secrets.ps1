# Wgrywa lokalne pliki Firebase do GitHub Secrets (bez commitowania kluczy).
# Wymaga: gh CLI (https://cli.github.com/) i gh auth login

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

$googleServices = Join-Path $Root "android\app\google-services.json"
$firebaseOptions = Join-Path $Root "lib\firebase_options.dart"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "Brak gh CLI. Zainstaluj: https://cli.github.com/ lub ustaw sekrety recznie (docs/CI-SECRETS.md)"
}

foreach ($path in @($googleServices, $firebaseOptions)) {
    if (-not (Test-Path $path)) {
        Write-Error "Brak pliku: $path — uruchom najpierw: flutterfire configure"
    }
}

Write-Host "Ustawianie GOOGLE_SERVICES_JSON..."
Get-Content $googleServices -Raw | gh secret set GOOGLE_SERVICES_JSON

Write-Host "Ustawianie FIREBASE_OPTIONS_DART..."
Get-Content $firebaseOptions -Raw | gh secret set FIREBASE_OPTIONS_DART

Write-Host ""
Write-Host "Gotowe. Sekrety sa w GitHub Actions (nie w repozytorium)."
Write-Host "Dokumentacja: docs/CI-SECRETS.md"
