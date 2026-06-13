# Wypisuje IPv4 komputera w sieci lokalnej (do EMULATOR_HOST na fizycznym telefonie).

$addresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IPAddress -notlike '127.*' -and
        $_.IPAddress -notlike '169.254.*'
    } |
    Select-Object -ExpandProperty IPAddress

if (-not $addresses) {
    Write-Host "Nie znaleziono adresu LAN. Sprawdz: ipconfig"
    exit 1
}

Write-Host "Uzyj jednego z tych adresow jako EMULATOR_HOST:"
foreach ($ip in $addresses) {
    Write-Host "  $ip"
}
