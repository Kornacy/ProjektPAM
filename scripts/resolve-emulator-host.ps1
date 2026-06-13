# Preferuje adres IPv4 z karty Wi-Fi (telefon musi byc w tej samej sieci co Wi-Fi, nie Ethernet).

function Get-EmulatorHostLanIp {
    $virtualPattern = 'vEthernet|Virtual|VMware|Hyper-V|Loopback|Teredo|Bluetooth|WSL'
    $wifiPattern = 'Wi-?Fi|WLAN|Wireless'

    $candidates = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike '127.*' -and
            $_.IPAddress -notlike '169.254.*'
        } |
        ForEach-Object {
            $adapter = Get-NetAdapter -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
            $alias = $_.InterfaceAlias
            [PSCustomObject]@{
                IPAddress = $_.IPAddress
                InterfaceAlias = $alias
                Status = if ($adapter) { $adapter.Status } else { 'Unknown' }
                IsWifi = $alias -match $wifiPattern
                IsVirtual = $alias -match $virtualPattern
            }
        } |
        Where-Object { -not $_.IsVirtual -and $_.Status -eq 'Up' }

    $wifi = $candidates | Where-Object { $_.IsWifi } | Select-Object -First 1
    if ($wifi) {
        return $wifi.IPAddress
    }

    return ($candidates | Select-Object -First 1 -ExpandProperty IPAddress)
}

function Get-EmulatorHostLanIpCandidates {
    $virtualPattern = 'vEthernet|Virtual|VMware|Hyper-V|Loopback|Teredo|Bluetooth|WSL'
    $wifiPattern = 'Wi-?Fi|WLAN|Wireless'

    Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike '127.*' -and
            $_.IPAddress -notlike '169.254.*'
        } |
        ForEach-Object {
            $adapter = Get-NetAdapter -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
            $alias = $_.InterfaceAlias
            [PSCustomObject]@{
                IPAddress = $_.IPAddress
                InterfaceAlias = $alias
                Status = if ($adapter) { $adapter.Status } else { 'Unknown' }
                IsWifi = $alias -match $wifiPattern
                IsVirtual = $alias -match $virtualPattern
                Preferred = ($alias -match $wifiPattern) -and ($alias -notmatch $virtualPattern)
            }
        } |
        Where-Object { -not $_.IsVirtual -and $_.Status -eq 'Up' } |
        Sort-Object -Property @{ Expression = 'Preferred'; Descending = $true }, InterfaceAlias
}
