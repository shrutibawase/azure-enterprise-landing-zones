# ==============================================================================
# Script: reconcile-drift.ps1
# Purpose: Enterprise Terraform Drift Detection, Refresh, and Self-Healing
# Author: Shruti Bawase
# ==============================================================================

[CmdletBinding()]
param(
    [ValidateSet("dev", "uat", "prod")]
    [string]$Environment = "dev",

    [switch]$AutoApply,

    [switch]$RefreshOnly
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$tfvarsFile = Join-Path $rootDir "environments\$Environment\terraform.tfvars"

if (-not (Test-Path $tfvarsFile)) {
    Write-Error "Configuration file not found at $tfvarsFile"
    exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Terraform Drift Reconciliation Engine" -ForegroundColor Cyan
Write-Host "Target Environment: $Environment" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

Push-Location $rootDir
try {
    Write-Host "Step 1: Refreshing state from live Azure resources..." -ForegroundColor Gray
    terraform refresh -var-file="$tfvarsFile"

    if ($RefreshOnly) {
        Write-Host "State refreshed successfully. Exiting per -RefreshOnly switch." -ForegroundColor Green
        return
    }

    Write-Host "Step 2: Calculating delta between refreshed state and code..." -ForegroundColor Gray
    $planOutput = "$Environment-drift.tfplan"
    
    # Run terraform plan with detailed-exitcode
    $process = Start-Process -FilePath "terraform" `
                             -ArgumentList "plan -detailed-exitcode -no-color -var-file=`"$tfvarsFile`" -out=`"$planOutput`"" `
                             -NoNewWindow -PassThru -Wait

    $planExit = $process.ExitCode

    if ($planExit -eq 0) {
        Write-Host "✅ [SUCCESS] Zero drift detected. Live infrastructure matches code perfectly." -ForegroundColor Green
        if (Test-Path $planOutput) { Remove-Item $planOutput -Force }
    }
    elseif ($planExit -eq 2) {
        Write-Host "⚠️ [ALERT] Infrastructure drift detected in $Environment environment!" -ForegroundColor Yellow
        
        if ($AutoApply) {
            Write-Host "Step 3: Self-healing enabled (-AutoApply). Reconciling live infrastructure..." -ForegroundColor Magenta
            terraform apply -auto-approve "$planOutput"
            Write-Host "✅ [RECONCILED] Desired state restored. Drift resolved." -ForegroundColor Green
            if (Test-Path $planOutput) { Remove-Item $planOutput -Force }
        } else {
            Write-Host "Notice: Run with -AutoApply to automatically reconcile live infrastructure." -ForegroundColor DarkYellow
            Write-Host "Preserving drift plan artifact at: $planOutput" -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "❌ [ERROR] Terraform plan failed with exit code $planExit." -ForegroundColor Red
        exit $planExit
    }
}
finally {
    Pop-Location
}
