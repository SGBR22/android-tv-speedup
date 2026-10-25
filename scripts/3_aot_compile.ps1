#Requires -Version 5.1
param(
    [string]$Target,
    [string[]]$Packages
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

if (-not $Packages -or $Packages.Count -eq 0) {
    $Packages = @(
        "com.google.android.youtube.tv",
        "com.google.android.webview",
        "com.luncher.launcher",
        "com.google.android.inputmethod.latin",
        "ru.kinopoisk.tv"
    )
}

Write-Host ">>> Starting Ahead-Of-Time (AOT) machine code compilation on $Target..." -ForegroundColor Cyan
Write-Host "    This converts bytecode into native CPU binaries, drastically reducing app launch lag."

foreach ($pkg in $Packages) {
    $isInstalled = & $adb -s $Target shell pm list packages $pkg
    if ($isInstalled -match $pkg) {
        Write-Host ">>> Compiling $pkg with 'speed' filter..." -ForegroundColor Yellow
        $res = (& $adb -s $Target shell cmd package compile -m speed -f $pkg)
        Write-Host "    Result: $res" -ForegroundColor Green
    }
}

Write-Host "`n>>> AOT compilation completed successfully!" -ForegroundColor Green
