#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap script for Android TV Speedup toolkit.
    Downloads portable Google Platform-Tools (ADB) and the ultra-minimal Luncher APK.
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rootDir = $PSScriptRoot

$toolsDir = Join-Path $rootDir "tools"
$apksDir  = Join-Path $rootDir "apks"
$logsDir  = Join-Path $rootDir "logs"

New-Item -ItemType Directory -Force -Path $toolsDir, $apksDir, $logsDir | Out-Null

$adbExe = Join-Path $toolsDir "platform-tools\adb.exe"

# 1. Download Android Platform-Tools (ADB) if missing
if (-not (Test-Path $adbExe)) {
    Write-Host ">>> [1/2] Downloading official Google Android Platform-Tools..." -ForegroundColor Cyan
    $zipPath = Join-Path $toolsDir "platform-tools.zip"
    $adbUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    try {
        Invoke-WebRequest -Uri $adbUrl -OutFile $zipPath -UseBasicParsing
        Write-Host ">>> Extracting Platform-Tools..." -ForegroundColor Cyan
        Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        Write-Host ">>> ADB installed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to download Platform-Tools: $_"
        exit 1
    }
} else {
    Write-Host ">>> ADB is already installed." -ForegroundColor Green
}

# 2. Download Luncher APK from GitHub releases if missing
$luncherApk = Join-Path $apksDir "Luncher.apk"
if (-not (Test-Path $luncherApk)) {
    Write-Host ">>> [2/2] Downloading ultra-minimal Luncher APK from GitHub..." -ForegroundColor Cyan
    try {
        $apiUri = "https://api.github.com/repos/CVasilakis/luncher/releases/latest"
        $release = Invoke-RestMethod -Uri $apiUri -Headers @{"User-Agent"="PowerShell"}
        $asset = $release.assets | Where-Object { $_.name -like "*.apk" } | Select-Object -First 1
        if ($asset) {
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $luncherApk -UseBasicParsing
            Write-Host ">>> Luncher APK downloaded successfully ($([math]::Round((Get-Item $luncherApk).Length / 1KB, 1)) KB)." -ForegroundColor Green
        }
    } catch {
        Write-Warning "Could not fetch Luncher from GitHub API automatically. You can place any launcher APK into the 'apks' folder."
    }
} else {
    Write-Host ">>> Luncher APK is already present." -ForegroundColor Green
}

Write-Host "`n=== Environment ready! You can now run .\tune-tv.ps1 ===" -ForegroundColor Cyan
