# ==============================================================================
# Script: test-e2e.ps1
# Purpose: Master End-to-End Architectural Test Runner for Azure Landing Zone
# Author: Shruti Bawase
# ==============================================================================

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  AZURE ENTERPRISE CLOUD LANDING ZONE - MASTER E2E TEST RUNNER" -ForegroundColor Cyan
Write-Host "  Architect: Shruti Bawase" -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan

$failedSuites = 0

function Run-Suite {
    param(
        [string]$SuiteName,
        [string]$ScriptPath
    )
    Write-Host "`n>> Executing Test Suite: $SuiteName..." -ForegroundColor White
    try {
        & powershell -ExecutionPolicy Bypass -File $ScriptPath
        if ($LASTEXITCODE -eq 0) {
            Write-Host ">> [SUCCESS] $SuiteName passed." -ForegroundColor Green
        } else {
            Write-Host ">> [FAILURE] $SuiteName failed!" -ForegroundColor Red
            $script:failedSuites++
        }
    } catch {
        Write-Host ">> [ERROR] Failed running $SuiteName : $_" -ForegroundColor Red
        $script:failedSuites++
    }
}

# Day 1: Transit Networking & Hub-Spoke
Run-Suite "Day 1: Transit Networking" (Join-Path $scriptDir "test-terraform.ps1")

# Day 2: Zero-Trust Identity, CMK & Storage
Run-Suite "Day 2: Identity & Security" (Join-Path $scriptDir "test-security.ps1")

# Day 3: Multi-AZ VMSS Compute & WAF
Run-Suite "Day 3: Compute & WAF" (Join-Path $scriptDir "test-compute.ps1")

# Day 4: Policy-as-Code & CIS Benchmark
Run-Suite "Day 4: Governance & Policies" (Join-Path $scriptDir "test-governance.ps1")

# Day 5: Observability, Alerts & DCRs
Run-Suite "Day 5: Observability & Monitoring" (Join-Path $scriptDir "test-monitoring.ps1")

# Day 6: CI/CD Pipelines & Drift Self-Healing
Run-Suite "Day 6: CI/CD & Environments" (Join-Path $scriptDir "test-pipeline.ps1")

# Day 7: Backup Vault & Disaster Recovery Invariants
Write-Host "`n>> Executing Test Suite: Day 7: Backup & Disaster Recovery..." -ForegroundColor White
$backupDir = Join-Path $rootDir "modules\backup"
$drDir = Join-Path $rootDir "modules\dr"

$bVault = Join-Path $backupDir "vault.tf"
$bVars = Join-Path $backupDir "variables.tf"
$drMain = Join-Path $drDir "main.tf"

if ((Test-Path $bVault) -and (Test-Path $bVars) -and (Test-Path $drMain)) {
    $bContent = Get-Content $bVault -Raw
    $bVarsContent = Get-Content $bVars -Raw
    $drContent = Get-Content $drMain -Raw
    if ($bVarsContent -match "GeoRedundant" -and $bContent -match "cross_region_restore_enabled" -and $drContent -match "is_valid_pairing") {
        Write-Host ">> [SUCCESS] Day 7: Backup & Disaster Recovery passed." -ForegroundColor Green
    } else {
        Write-Host ">> [FAILURE] Day 7 invariants failed!" -ForegroundColor Red
        $failedSuites++
    }
} else {
    Write-Host ">> [FAILURE] Day 7 files missing!" -ForegroundColor Red
    $failedSuites++
}

Write-Host "`n========================================================================" -ForegroundColor Cyan
if ($failedSuites -eq 0) {
    Write-Host "  ALL ARCHITECTURAL TEST SUITES PASSED (7/7 Days 100% Green)" -ForegroundColor Green
    Write-Host "========================================================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  TEST FAILURES DETECTED: $failedSuites suites failed." -ForegroundColor Red
    Write-Host "========================================================================" -ForegroundColor Cyan
    exit 1
}
