<#
.SYNOPSIS
    Static Security & Invariant Asserter for WAF and Compute Scaling (PowerShell).
.DESCRIPTION
    Validates Application Gateway WAF_v2 Prevention mode, OWASP 3.2, Rate-limiting,
    VMSS Multi-AZ deployment, ZRS storage, Cloud-Init hardening, and Autoscaling rules.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  WAF & Resilient Multi-AZ Compute Invariant Test Suite (PS)    " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

$RootDir = Split-Path -Parent $PSScriptRoot
$FailedTests = 0

# Test 1: WAF Prevention mode
Write-Host "`n[Test 1/6] Checking Application Gateway WAF Prevention Mode..." -ForegroundColor Cyan
$WafFile = "$RootDir\modules\app_gateway\waf_policy.tf"
if (Test-Path $WafFile) {
    $content = Get-Content $WafFile -Raw
    if ($content -match 'mode\s*=\s*"Prevention"' -and $content -match 'version\s*=\s*"3.2"') {
        Write-Host "[+] PASS: WAF Policy enforces OWASP 3.2 in strict Prevention mode." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: WAF Policy not configured in Prevention mode!" -ForegroundColor Red
        $FailedTests++
    }
} else {
    Write-Host "[-] FAIL: WAF file missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 2: WAF Rate Limiting
Write-Host "`n[Test 2/6] Checking Custom Rate-Limiting Rules..." -ForegroundColor Cyan
if (Test-Path $WafFile) {
    $content = Get-Content $WafFile -Raw
    if ($content -match 'rule_type\s*=\s*"RateLimitRule"' -and $content -match 'rate_limit_duration\s*=\s*"OneMin"') {
        Write-Host "[+] PASS: WAF Rate-Limiting rule verified." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: WAF Rate-Limiting rule missing!" -ForegroundColor Red
        $FailedTests++
    }
}

# Test 3: VMSS Multi-AZ and ZRS Storage
Write-Host "`n[Test 3/6] Checking VMSS Multi-AZ & ZRS Storage..." -ForegroundColor Cyan
$VmssFile = "$RootDir\modules\compute\main.tf"
if (Test-Path $VmssFile) {
    $content = Get-Content $VmssFile -Raw
    if ($content -match 'zones\s*=\s*\["1", "2", "3"\]' -and $content -match 'storage_account_type\s*=\s*"Premium_ZRS"') {
        Write-Host "[+] PASS: VMSS configured for Availability Zones 1,2,3 with Premium ZRS." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: VMSS missing Multi-AZ or ZRS storage!" -ForegroundColor Red
        $FailedTests++
    }
}

# Test 4: Cloud-Init Hardening & Healthz Probe
Write-Host "`n[Test 4/6] Checking Cloud-Init Bootstrap Invariants..." -ForegroundColor Cyan
$CloudInit = "$RootDir\modules\compute\cloud-init.yaml"
if (Test-Path $CloudInit) {
    $content = Get-Content $CloudInit -Raw
    if ($content -match 'net.ipv4.tcp_syncookies = 1' -and $content -match 'healthz-probe.service') {
        Write-Host "[+] PASS: Cloud-Init includes kernel hardening and health probe service." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: Cloud-Init script missing security hardening!" -ForegroundColor Red
        $FailedTests++
    }
} else {
    Write-Host "[-] FAIL: Cloud-Init file missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 5: Dynamic Autoscaling Settings
Write-Host "`n[Test 5/6] Checking Dynamic Auto-Scaling Triggers..." -ForegroundColor Cyan
$AutoscaleFile = "$RootDir\modules\compute\autoscale.tf"
if (Test-Path $AutoscaleFile) {
    $content = Get-Content $AutoscaleFile -Raw
    if ($content -match 'threshold\s*=\s*75' -and $content -match 'threshold\s*=\s*25') {
        Write-Host "[+] PASS: CPU threshold scale-out (75%) and scale-in (25%) verified." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: Autoscale thresholds not configured properly!" -ForegroundColor Red
        $FailedTests++
    }
}

# Test 6: Rolling Upgrade Policy
Write-Host "`n[Test 6/6] Checking Rolling Upgrade Maintenance Policy..." -ForegroundColor Cyan
if (Test-Path $VmssFile) {
    $content = Get-Content $VmssFile -Raw
    if ($content -match 'upgrade_mode\s*=\s*"Rolling"' -and $content -match 'rolling_upgrade_policy') {
        Write-Host "[+] PASS: VMSS enforces zero-downtime Rolling Upgrades." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: Rolling upgrade policy missing from VMSS!" -ForegroundColor Red
        $FailedTests++
    }
}

Write-Host "`n================================================================" -ForegroundColor Cyan
if ($FailedTests -eq 0) {
    Write-Host "ALL WAF & COMPUTE INVARIANT TESTS PASSED! (0 failures)" -ForegroundColor Green
} else {
    Write-Host "TEST SUITE FAILED WITH $FailedTests FAILURES!" -ForegroundColor Red
    exit 1
}
Write-Host "================================================================" -ForegroundColor Cyan
