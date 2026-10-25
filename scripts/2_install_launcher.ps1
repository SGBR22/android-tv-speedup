#Requires -Version 5.1
param(
    [string]$Target
)

$adb = Join-Path $PSScriptRoot "..\tools\platform-tools\adb.exe"
$apk = Join-Path $PSScriptRoot "..\apks\Luncher.apk"

if (-not (Test-Path $apk)) {
    & (Join-Path $PSScriptRoot "..\bootstrap.ps1")
}

if (-not $Target) {
    $devs = & $adb devices | Select-String "device$"
    if ($devs) {
        $Target = ($devs[0].ToString().Split("`t")[0]).Trim()
    } else {
        Write-Error "No connected ADB device found. Run 1_connect.ps1 first."
        exit 1
    }
}

Write-Host ">>> Installing Luncher on $Target..." -ForegroundColor Cyan
& $adb -s $Target push $apk /data/local/tmp/luncher.apk | Out-Null
$res = (& $adb -s $Target shell pm install -r -g /data/local/tmp/luncher.apk)
& $adb -s $Target shell rm -f /data/local/tmp/luncher.apk

if ($res -match "Success") {
    Write-Host ">>> Luncher installed successfully!" -ForegroundColor Green
    
    Write-Host ">>> Configuring Luncher as default Home launcher..." -ForegroundColor Cyan
    & $adb -s $Target shell cmd package set-home-activity com.luncher.launcher/.home.HomeActivity | Out-Null

    # Safely disable heavy stock Google launchers so HOME button always opens Luncher
    $stockLaunchers = @(
        "com.google.android.tvlauncher",
        "com.google.android.apps.tv.launcherx",
        "com.spocky.projengmenu"
    )
    foreach ($pkg in $stockLaunchers) {
        $check = & $adb -s $Target shell pm list packages $pkg
        if ($check -match $pkg) {
            & $adb -s $Target shell pm disable-user --user 0 $pkg | Out-Null
        }
    }

    Write-Host ">>> Launching Home screen..." -ForegroundColor Cyan
    & $adb -s $Target shell input keyevent 3
    & $adb -s $Target shell am start -n com.luncher.launcher/.home.HomeActivity | Out-Null
    Write-Host ">>> Ultra-minimal Luncher is now active on your TV!" -ForegroundColor Green
} else {
    Write-Error "Installation failed: $res"
}
