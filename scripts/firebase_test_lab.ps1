#!/usr/bin/env pwsh
# =============================================================================
# scripts/firebase_test_lab.ps1
#
# Builds the debug APK + instrumentation test APK for Shortly and uploads
# them to Firebase Test Lab.
#
# Prerequisites:
#   1. Flutter SDK on PATH
#   2. Google Cloud SDK (gcloud) installed and authenticated:
#        gcloud auth login
#        gcloud config set project YOUR_PROJECT_ID
#   3. Firebase Test Lab API enabled for your project
#
# Usage:
#   .\scripts\firebase_test_lab.ps1 -ProjectId "my-firebase-project"
#   .\scripts\firebase_test_lab.ps1 -ProjectId "my-firebase-project" -Devices "model=Pixel2,version=28"
# =============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,

    # Comma-separated device specs (gcloud format: model=X,version=Y,locale=Z,orientation=W)
    [string]$Devices = "model=MediumPhone.arm,version=34,locale=en,orientation=portrait",

    # Timeout per test (gcloud format, e.g. 5m)
    [string]$Timeout = "10m",

    # Run a quick sanity check without uploading to FTL
    [switch]$LocalOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BuildDir    = Join-Path $ProjectRoot "build\app\outputs\apk"

function Write-Step([string]$msg) {
    Write-Host "`n==> $msg" -ForegroundColor Cyan
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. Flutter pub get
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Fetching Flutter dependencies"
Set-Location $ProjectRoot
flutter pub get

# ─────────────────────────────────────────────────────────────────────────────
# 2. Build the debug APK (app under test)
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Building debug APK"
flutter build apk --debug
$AppApk = Join-Path $BuildDir "debug\app-debug.apk"

if (-not (Test-Path $AppApk)) {
    Write-Error "Debug APK not found at: $AppApk"
    exit 1
}
Write-Host "  App APK : $AppApk" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────────────────────
# 3. Build the instrumentation test APK
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Building instrumentation test APK"
# Flutter wraps the integration_test package into a standard Android
# instrumentation test runner APK automatically.
Push-Location (Join-Path $ProjectRoot "android")
try {
    .\gradlew.bat app:assembleAndroidTest
} finally {
    Pop-Location
}

$TestApk = Join-Path $BuildDir "androidTest\debug\app-debug-androidTest.apk"
if (-not (Test-Path $TestApk)) {
    Write-Error "Test APK not found at: $TestApk"
    exit 1
}
Write-Host "  Test APK: $TestApk" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────────────────────
# 4. (Optional) local-only mode – stop here
# ─────────────────────────────────────────────────────────────────────────────
if ($LocalOnly) {
    Write-Host "`n[LocalOnly] Skipping Firebase Test Lab upload." -ForegroundColor Yellow
    exit 0
}

# ─────────────────────────────────────────────────────────────────────────────
# 5. Upload and run on Firebase Test Lab
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Uploading to Firebase Test Lab (project: $ProjectId)"

# Split device specs so we can pass multiple --device flags
$DeviceArgs = $Devices -split ";" | ForEach-Object { "--device", $_ }

$GcloudArgs = @(
    "firebase", "test", "android", "run",
    "--type",              "instrumentation",
    "--app",              $AppApk,
    "--test",             $TestApk,
    "--project",          $ProjectId,
    "--timeout",          $Timeout,
    "--results-dir",      "shortly-integration-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
    "--environment-variables", "clearPackageData=true"
) + $DeviceArgs

Write-Host "  Running: gcloud $($GcloudArgs -join ' ')" -ForegroundColor DarkGray
gcloud @GcloudArgs

Write-Step "Done! Check results at https://console.firebase.google.com/project/$ProjectId/testlab"
