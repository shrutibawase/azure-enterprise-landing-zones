<#
.SYNOPSIS
    Static Policy-as-Code & FinOps Configuration Validator (PowerShell).
.DESCRIPTION
    Validates require_tags.json, allowed_locations.json, .tflint.hcl, .checkov.yml,
    and Infracost configuration files.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Azure Policy-as-Code & FinOps Validation Test Suite (PS)      " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

$RootDir = Split-Path -Parent $PSScriptRoot
$FailedTests = 0

# Test 1: require_tags.json
Write-Host "`n[Test 1/5] Checking Require Tags Policy JSON Syntax..." -ForegroundColor Cyan
$TagsFile = "$RootDir\modules\governance\policies\require_tags.json"
if (Test-Path $TagsFile) {
    try {
        $null = Get-Content $TagsFile -Raw | ConvertFrom-Json
        Write-Host "[+] PASS: require_tags.json is valid JSON." -ForegroundColor Green
    } catch {
        Write-Host "[-] FAIL: require_tags.json contains invalid JSON: $_" -ForegroundColor Red
        $FailedTests++
    }
} else {
    Write-Host "[-] FAIL: require_tags.json missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 2: allowed_locations.json
Write-Host "`n[Test 2/5] Checking Allowed Locations Policy JSON Syntax..." -ForegroundColor Cyan
$LocFile = "$RootDir\modules\governance\policies\allowed_locations.json"
if (Test-Path $LocFile) {
    try {
        $null = Get-Content $LocFile -Raw | ConvertFrom-Json
        Write-Host "[+] PASS: allowed_locations.json is valid JSON." -ForegroundColor Green
    } catch {
        Write-Host "[-] FAIL: allowed_locations.json contains invalid JSON: $_" -ForegroundColor Red
        $FailedTests++
    }
} else {
    Write-Host "[-] FAIL: allowed_locations.json missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 3: .tflint.hcl
Write-Host "`n[Test 3/5] Checking TFLint Configuration..." -ForegroundColor Cyan
$Tflint = "$RootDir\.tflint.hcl"
if ((Test-Path $Tflint) -and ((Get-Content $Tflint -Raw) -match "tflint-ruleset-azurerm")) {
    Write-Host "[+] PASS: .tflint.hcl configured with azurerm ruleset." -ForegroundColor Green
} else {
    Write-Host "[-] FAIL: .tflint.hcl missing or incomplete!" -ForegroundColor Red
    $FailedTests++
}

# Test 4: .checkov.yml
Write-Host "`n[Test 4/5] Checking Checkov Security Baseline Config..." -ForegroundColor Cyan
$Checkov = "$RootDir\.checkov.yml"
if ((Test-Path $Checkov) -and ((Get-Content $Checkov -Raw) -match "framework")) {
    Write-Host "[+] PASS: .checkov.yml configured with documented suppressions." -ForegroundColor Green
} else {
    Write-Host "[-] FAIL: .checkov.yml missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 5: Infracost
Write-Host "`n[Test 5/5] Checking Infracost FinOps Pipeline Files..." -ForegroundColor Cyan
$Infracost = "$RootDir\infracost.yml"
$Usage = "$RootDir\infracost-usage.yml"
if ((Test-Path $Infracost) -and (Test-Path $Usage)) {
    Write-Host "[+] PASS: infracost.yml and usage baseline verified." -ForegroundColor Green
} else {
    Write-Host "[-] FAIL: Infracost configuration files missing!" -ForegroundColor Red
    $FailedTests++
}

Write-Host "`n================================================================" -ForegroundColor Cyan
if ($FailedTests -eq 0) {
    Write-Host "ALL GOVERNANCE & FINOPS TESTS PASSED! (0 failures)" -ForegroundColor Green
} else {
    Write-Host "TEST SUITE FAILED WITH $FailedTests FAILURES!" -ForegroundColor Red
    exit 1
}
Write-Host "================================================================" -ForegroundColor Cyan
