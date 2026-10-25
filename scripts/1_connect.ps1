#Requires -Version 5.1
param(
    [string]$TvIp
)

$adb = Join-Path $PSScriptRoot "..\tools\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    & (Join-Path $PSScriptRoot "..\bootstrap.ps1")
}

if (-not $TvIp) {
    $TvIp = Read-Host "Enter Android TV IP address (e.g. 192.168.1.50)"
}
$TvIp = $TvIp.Trim()
if ($TvIp -notmatch ":") {
    $target = "${TvIp}:5555"
} else {
    $target = $TvIp
}

Write-Host ">>> Pinging $TvIp..." -ForegroundColor Cyan
if (-not (Test-Connection -ComputerName ($TvIp -replace ":.*","") -Count 2 -Quiet)) {
    Write-Warning "Device does not respond to ping. Please verify TV is turned on and connected to the same Wi-Fi."
}

Write-Host ">>> Connecting via ADB to $target..." -ForegroundColor Cyan
& $adb disconnect $target | Out-Null
& $adb connect $target

Write-Host ">>> Checking connection state..." -ForegroundColor Cyan
$state = (& $adb -s $target get-state) 2>$null
if ($state -eq "device") {
    $model = (& $adb -s $target shell getprop ro.product.model).Trim()
    $android = (& $adb -s $target shell getprop ro.build.version.release).Trim()
    Write-Host ">>> Connected successfully to $model (Android $android)!" -ForegroundColor Green
    return $target
} elseif ($state -eq "unauthorized") {
    Write-Warning "Device is UNAUTHORIZED! Please look at your TV screen and click 'Always allow from this computer' -> OK."
} else {
    Write-Warning "Could not connect to $target. Ensure 'USB Debugging' is enabled in TV Developer Options."
}
