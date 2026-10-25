#Requires -Version 5.1
param(
    [string]$Target
)

$adb = Join-Path $PSScriptRoot "..\tools\platform-tools\adb.exe"

if (-not $Target) {
    $devs = & $adb devices | Select-String "device$"
    if ($devs) {
        $Target = ($devs[0].ToString().Split("`t")[0]).Trim()
    } else {
        Write-Error "No connected ADB device found. Run 1_connect.ps1 first."
        exit 1
    }
}

Write-Host ">>> [1/3] Setting instant UI animations (0.0x scale)..." -ForegroundColor Cyan
& $adb -s $Target shell settings put global window_animation_scale 0
& $adb -s $Target shell settings put global transition_animation_scale 0
& $adb -s $Target shell settings put global animator_duration_scale 0

Write-Host ">>> [2/3] Restricting background CPU thrashing via AppOps..." -ForegroundColor Cyan
# Restrict Google Play Store background wakeups
& $adb -s $Target shell cmd appops set com.android.vending RUN_IN_BACKGROUND ignore
& $adb -s $Target shell cmd appops set com.android.vending RUN_ANY_IN_BACKGROUND ignore
& $adb -s $Target shell cmd appops set com.android.vending WAKE_LOCK ignore
& $adb -s $Target shell am set-standby-bucket com.android.vending rare

# Restrict Kinopoisk background trackers if installed
$kpCheck = & $adb -s $Target shell pm list packages ru.kinopoisk.tv
if ($kpCheck -match "ru.kinopoisk.tv") {
    & $adb -s $Target shell cmd appops set ru.kinopoisk.tv RUN_IN_BACKGROUND ignore
    & $adb -s $Target shell cmd appops set ru.kinopoisk.tv RUN_ANY_IN_BACKGROUND ignore
    & $adb -s $Target shell cmd appops set ru.kinopoisk.tv WAKE_LOCK ignore
    & $adb -s $Target shell am set-standby-bucket ru.kinopoisk.tv rare
}

Write-Host ">>> [3/3] Trimming disk caches & resetting ZRAM..." -ForegroundColor Cyan
& $adb -s $Target shell pm trim-caches 999G | Out-Null
& $adb -s $Target shell am kill-all | Out-Null
& $adb -s $Target shell input keyevent 3

Write-Host "`n=== Memory and ZRAM Diagnostics ===" -ForegroundColor Green
$mem = & $adb -s $Target shell cat /proc/meminfo
$mem | Select-String "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree"
