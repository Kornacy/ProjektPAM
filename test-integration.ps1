# Uruchamia testy integracyjne Z KATALOGU GLOWNEGO projektu.
# Uzycie:
#   .\test-integration.ps1
#   .\test-integration.ps1 -DeviceId cb475b22 -EmulatorHost 192.168.1.13

param(
    [string]$DeviceId = "",
    [string]$EmulatorHost = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$params = @{}
if ($DeviceId) { $params.DeviceId = $DeviceId }
if ($EmulatorHost) { $params.EmulatorHost = $EmulatorHost }

& (Join-Path $PSScriptRoot "scripts\run-integration-tests.ps1") @params
