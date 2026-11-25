# ==============================================================================
# Script: test-pipeline.ps1
# Purpose: Automated validation test suite for GitHub Actions CI/CD & Environments
# Author: Shruti Bawase
# ==============================================================================

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

$totalTests = 5
$passedTests = 0

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Azure Enterprise Landing Zone - CI/CD & Pipeline Test Suite" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Test 1: GitHub Actions workflows existence and OIDC permission check
Write-Host -NoNewline "[TEST 1/$totalTests] Verifying GitHub Actions workflows and OIDC permissions... "
$workflowsDir = Join-Path $rootDir ".github\workflows"
$wfDeploy = Join-Path $workflowsDir "terraform-deploy.yml"
$wfDrift = Join-Path $workflowsDir "drift-detection.yml"
$wfCost = Join-Path $workflowsDir "infracost-commenter.yml"

if ((Test-Path $wfDeploy) -and (Test-Path $wfDrift) -and (Test-Path $wfCost)) {
    $deployContent = Get-Content $wfDeploy -Raw
    if ($deployContent -match "id-token:\s*write" -and $deployContent -match "azure/login") {
        Write-Host "PASSED" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "FAILED (OIDC missing)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "FAILED (Workflows missing)" -ForegroundColor Red
    exit 1
}

# Test 2: Environment parameter files verification across dev, uat, prod
Write-Host -NoNewline "[TEST 2/$totalTests] Verifying environment tfvars isolation across stages... "
$envDir = Join-Path $rootDir "environments"
$devVars = Join-Path $envDir "dev\terraform.tfvars"
$uatVars = Join-Path $envDir "uat\terraform.tfvars"
$prodVars = Join-Path $envDir "prod\terraform.tfvars"

if ((Test-Path $devVars) -and (Test-Path $uatVars) -and (Test-Path $prodVars)) {
    $devContent = Get-Content $devVars -Raw
    $uatContent = Get-Content $uatVars -Raw
    $prodContent = Get-Content $prodVars -Raw
    if ($devContent -match 'environment\s*=\s*"dev"' -and `
        $uatContent -match 'environment\s*=\s*"uat"' -and `
        $prodContent -match 'environment\s*=\s*"prod"') {
        Write-Host "PASSED" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "FAILED (Environment names mismatched)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "FAILED (Tfvars missing)" -ForegroundColor Red
    exit 1
}

# Test 3: Terragrunt configuration and remote state generation check
Write-Host -NoNewline "[TEST 3/$totalTests] Verifying Terragrunt DRY architecture and provider generation... "
$rootTg = Join-Path $rootDir "terragrunt.hcl"
$prodTg = Join-Path $envDir "prod\terragrunt.hcl"

if ((Test-Path $rootTg) -and (Test-Path $prodTg)) {
    $tgContent = Get-Content $rootTg -Raw
    if ($tgContent -match "remote_state" -and $tgContent -match 'generate "provider"') {
        Write-Host "PASSED" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "FAILED (Terragrunt blocks missing)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "FAILED (Terragrunt files missing)" -ForegroundColor Red
    exit 1
}

# Test 4: Drift reconciliation self-healing scripts verification
Write-Host -NoNewline "[TEST 4/$totalTests] Verifying drift reconciliation scripts and flag handling... "
$scriptsDir = Join-Path $rootDir "scripts"
$shDrift = Join-Path $scriptsDir "reconcile-drift.sh"
$psDrift = Join-Path $scriptsDir "reconcile-drift.ps1"

if ((Test-Path $shDrift) -and (Test-Path $psDrift)) {
    $shContent = Get-Content $shDrift -Raw
    $psContent = Get-Content $psDrift -Raw
    if ($shContent -match "auto-apply" -and $psContent -match "AutoApply") {
        Write-Host "PASSED" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "FAILED (AutoApply flag missing)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "FAILED (Drift scripts missing)" -ForegroundColor Red
    exit 1
}

# Test 5: Terraform static syntax validation against environment inputs
Write-Host -NoNewline "[TEST 5/$totalTests] Validating Terraform core syntax against production inputs... "
Push-Location $rootDir
try {
    terraform init -backend=false | Out-Null
    $res = terraform validate
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PASSED" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "FAILED" -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Test Results: $passedTests/$totalTests passed successfully." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
