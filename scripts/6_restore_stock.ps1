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

Write-Host "=== Rolling back all optimizations on $Target ===" -ForegroundColor Yellow

$packagesToRestore = @(
    "com.google.android.tvlauncher",
    "com.google.android.apps.tv.launcherx",
    "com.google.android.tvrecommendations",
    "com.google.android.leanbacklauncher.recommendations",
    "com.mitv.tvhome.michannel",
    "com.miui.tv.analytics",
    "com.xiaomi.statistic",
    "com.google.android.videos",
    "com.google.android.play.games",
    "com.google.android.feedback",
    "com.google.android.tv.bugreportsender",
    "com.google.android.katniss",
    "com.mitv.tvhome.atv",
    "com.xiaomi.mitv.updateservice",
    "com.xiaomi.mitv.mediaexplorer",
    "com.xiaomi.mimusic2",
    "com.xiaomi.floatingframe"
)

foreach ($pkg in $packagesToRestore) {
    $res = & $adb -s $Target shell pm enable $pkg
    Write-Host "    Restoring $pkg: $res"
}

Write-Host ">>> Resetting animations to standard (1.0x)..." -ForegroundColor Cyan
& $adb -s $Target shell settings put global window_animation_scale 1
& $adb -s $Target shell settings put global transition_animation_scale 1
& $adb -s $Target shell settings put global animator_duration_scale 1

Write-Host ">>> Resetting AppOps for Google Play Store..." -ForegroundColor Cyan
& $adb -s $Target shell cmd appops set com.android.vending RUN_IN_BACKGROUND allow
& $adb -s $Target shell cmd appops set com.android.vending RUN_ANY_IN_BACKGROUND allow
& $adb -s $Target shell cmd appops set com.android.vending WAKE_LOCK allow
& $adb -s $Target shell am set-standby-bucket com.android.vending active

Write-Host "`n>>> Factory state restored successfully!" -ForegroundColor Green
