# Wypisuje IPv4 komputera do EMULATOR_HOST (preferuje Wi-Fi).

. "$PSScriptRoot\resolve-emulator-host.ps1"

$candidates = Get-EmulatorHostLanIpCandidates

if (-not $candidates) {
    Write-Host "Nie znaleziono adresu LAN. Sprawdz: ipconfig"
    exit 1
}

$preferred = Get-EmulatorHostLanIp

Write-Host "Zalecany EMULATOR_HOST (Wi-Fi): $preferred"
Write-Host ""
Write-Host "Wszystkie dostepne adresy:"
foreach ($entry in $candidates) {
    $tag = if ($entry.IPAddress -eq $preferred) { "  <- zalecany" } else { "" }
    $type = if ($entry.IsWifi) { "Wi-Fi" } else { "LAN" }
    Write-Host ("  {0}  [{1}] {2}{3}" -f $entry.IPAddress, $type, $entry.InterfaceAlias, $tag)
}

Write-Host ""
Write-Host "Uzycie:"
Write-Host "  .\test-integration.ps1 -EmulatorHost $preferred"
