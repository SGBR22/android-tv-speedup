#Requires -Version 5.1
<#
.SYNOPSIS
    Android TV Speedup & Ultra-Minimal Setup - Master CLI
#>

Clear-Host
$rootDir = $PSScriptRoot
$scriptsDir = Join-Path $rootDir "scripts"
$toolsDir = Join-Path $rootDir "tools"
$adb = Join-Path $toolsDir "platform-tools\adb.exe"

# Ensure bootstrap has run
if (-not (Test-Path $adb)) {
    & (Join-Path $rootDir "bootstrap.ps1")
}

function Get-ConnectedTarget {
    $devs = & $adb devices | Select-String "device$"
    if ($devs) {
        return ($devs[0].ToString().Split("`t")[0]).Trim()
    }
    return $null
}

$target = Get-ConnectedTarget

function Show-Header {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "     ⚡ Android TV Speedup & Ultra-Minimal Setup ⚡      " -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    if ($target) {
        $model = (& $adb -s $target shell getprop ro.product.model 2>$null)
        Write-Host " Connected Device: $target ($model)" -ForegroundColor Green
    } else {
        Write-Host " Status: Not Connected (Choose option 2 to connect)" -ForegroundColor Red
    }
    Write-Host "----------------------------------------------------------"
}

function Ensure-Target {
    if (-not $script:target) {
        $ip = Read-Host "Enter TV IP address (e.g. 192.168.1.50)"
        $script:target = & (Join-Path $scriptsDir "1_connect.ps1") -TvIp $ip
    }
    return $script:target
}

do {
    Show-Header
    Write-Host "[1] 🚀 Full Speedup (Luncher + AOT + Debloat + Memory Boost)" -ForegroundColor Green
    Write-Host "[2] 🔌 Connect to TV over Wi-Fi"
    Write-Host "[3] 🖥️  Install Ultra-Minimal Luncher (194 KB)"
    Write-Host "[4] ⚡ Run AOT Machine Code Compilation (YouTube, WebView, Apps)"
    Write-Host "[5] 🧹 Debloat System (Disable PatchWall, Ads & Telemetry)"
    Write-Host "[6] 🧠 Optimize Memory & Instant Animations (0.0x)"
    Write-Host "[7] 🔄 Rollback / Restore Factory Defaults"
    Write-Host "[Q] ❌ Exit"
    Write-Host "----------------------------------------------------------"
    $choice = (Read-Host "Select an option").Trim().ToUpper()

    switch ($choice) {
        "1" {
            if (Ensure-Target) {
                Write-Host "`n>>> Running Step 1: Installing Luncher..." -ForegroundColor Cyan
                & (Join-Path $scriptsDir "2_install_launcher.ps1") -Target $script:target
                Write-Host "`n>>> Running Step 2: AOT Compiling Apps..." -ForegroundColor Cyan
                & (Join-Path $scriptsDir "3_aot_compile.ps1") -Target $script:target
                Write-Host "`n>>> Running Step 3: Debloating System..." -ForegroundColor Cyan
                & (Join-Path $scriptsDir "4_debloat.ps1") -Target $script:target
                Write-Host "`n>>> Running Step 4: Optimizing Memory..." -ForegroundColor Cyan
                & (Join-Path $scriptsDir "5_optimize_memory.ps1") -Target $script:target
                Write-Host "`n[SUCCESS] Full optimization completed!" -ForegroundColor Green
            }
            Pause
        }
        "2" {
            $ip = Read-Host "Enter TV IP address"
            $script:target = & (Join-Path $scriptsDir "1_connect.ps1") -TvIp $ip
            Pause
        }
        "3" {
            if (Ensure-Target) {
                & (Join-Path $scriptsDir "2_install_launcher.ps1") -Target $script:target
            }
            Pause
        }
        "4" {
            if (Ensure-Target) {
                & (Join-Path $scriptsDir "3_aot_compile.ps1") -Target $script:target
            }
            Pause
        }
        "5" {
            if (Ensure-Target) {
                & (Join-Path $scriptsDir "4_debloat.ps1") -Target $script:target
            }
            Pause
        }
        "6" {
            if (Ensure-Target) {
                & (Join-Path $scriptsDir "5_optimize_memory.ps1") -Target $script:target
            }
            Pause
        }
        "7" {
            if (Ensure-Target) {
                & (Join-Path $scriptsDir "6_restore_stock.ps1") -Target $script:target
            }
            Pause
        }
        "Q" {
            Write-Host "Exiting. Enjoy your snappy Android TV!" -ForegroundColor Cyan
            break
        }
    }
    Clear-Host
} while ($choice -ne "Q")
