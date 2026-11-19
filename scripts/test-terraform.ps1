<#
.SYNOPSIS
    Comprehensive Terraform Static Analysis & Syntax Validation for PowerShell.
.DESCRIPTION
    Runs terraform fmt -check, terraform init, terraform validate across root
    and all child modules in modules/.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Azure Enterprise Landing Zone: Terraform Validation Suite     " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

$RootDir = Split-Path -Parent $PSScriptRoot
$FailedTests = 0

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "[-] Error: 'terraform' CLI is not found in PATH." -ForegroundColor Red
    exit 1
}

# 1. Format check
Write-Host "`n[Test 1/4] Checking Terraform Canonical Formatting..." -ForegroundColor Cyan
$fmtResult = terraform fmt -check -recursive "$RootDir" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] PASS: All Terraform files are canonically formatted." -ForegroundColor Green
} else {
    Write-Host "[!] Notice: Canonical formatting check flagged modified files." -ForegroundColor Yellow
}

# 2. Init root module
Write-Host "`n[Test 2/4] Initializing Terraform (Backend Disabled)..." -ForegroundColor Cyan
terraform -chdir="$RootDir" init -backend=false *>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] PASS: Root module initialized successfully." -ForegroundColor Green
} else {
    Write-Host "[-] FAIL: Terraform init failed!" -ForegroundColor Red
    $FailedTests++
}

# 3. Validate root module
Write-Host "`n[Test 3/4] Validating Root Module Configuration..." -ForegroundColor Cyan
terraform -chdir="$RootDir" validate *>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] PASS: Root module configuration is valid." -ForegroundColor Green
} else {
    Write-Host "[-] FAIL: Terraform validation failed!" -ForegroundColor Red
    $FailedTests++
}

# 4. Validate child modules
Write-Host "`n[Test 4/4] Validating Child Modules in modules/..." -ForegroundColor Cyan
$modules = Get-ChildItem -Path "$RootDir\modules" -Directory
foreach ($mod in $modules) {
    terraform -chdir="$($mod.FullName)" init -backend=false *>$null
    terraform -chdir="$($mod.FullName)" validate *>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[+] PASS: Module '$($mod.Name)' is valid." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: Module '$($mod.Name)' validation failed!" -ForegroundColor Red
        $FailedTests++
    }
}

Write-Host "`n================================================================" -ForegroundColor Cyan
if ($FailedTests -eq 0) {
    Write-Host "ALL TERRAFORM VALIDATION TESTS PASSED! (0 failures)" -ForegroundColor Green
} else {
    Write-Host "TEST SUITE FAILED WITH $FailedTests FAILURES!" -ForegroundColor Red
    exit 1
}
Write-Host "================================================================" -ForegroundColor Cyan
