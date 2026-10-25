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

$bloatList = @(
    # Recommendation carousels and ads
    "com.google.android.tvrecommendations",
    "com.google.android.leanbacklauncher.recommendations",
    "com.mitv.tvhome.michannel",
    
    # Telemetry and diagnostics
    "com.miui.tv.analytics",
    "com.xiaomi.statistic",
    "com.google.android.feedback",
    "com.google.android.tv.bugreportsender",
    
    # Unused media stores & games
    "com.google.android.videos",
    "com.google.android.play.games",
    
    # Background assistant listener
    "com.google.android.katniss",
    
    # Vendor bloat (Xiaomi PatchWall suite)
    "com.mitv.tvhome.atv",
    "com.xiaomi.mitv.updateservice",
    "com.xiaomi.mitv.mediaexplorer",
    "com.xiaomi.mimusic2",
    "com.xiaomi.floatingframe"
)

Write-Host ">>> Safely disabling background bloatware on $Target..." -ForegroundColor Cyan

foreach ($pkg in $bloatList) {
    $check = & $adb -s $Target shell pm list packages $pkg
    if ($check -match $pkg) {
        $res = & $adb -s $Target shell pm disable-user --user 0 $pkg
        Write-Host "    $pkg -> $res"
    }
}

Write-Host "`n>>> Debloat completed. Memory has been freed!" -ForegroundColor Green
