<#
.SYNOPSIS
    Static Security Invariant Asserter for Identity, CMK & Storage Modules (PowerShell).
.DESCRIPTION
    Validates Key Vault purge protection, RBAC, CMK rotation policies, Storage double encryption,
    and passwordless Managed Identity definitions.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Zero-Trust Identity, CMK & Storage Security Verification      " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

$RootDir = Split-Path -Parent $PSScriptRoot
$FailedTests = 0

# Test 1: Key Vault Purge Protection & RBAC
Write-Host "`n[Test 1/5] Checking Key Vault Security Invariants..." -ForegroundColor Cyan
$KvFile = "$RootDir\modules\security\main.tf"
if (Test-Path $KvFile) {
    $content = Get-Content $KvFile -Raw
    if ($content -match "purge_protection_enabled\s*=\s*true" -and $content -match "enable_rbac_authorization\s*=\s*true") {
        Write-Host "[+] PASS: Key Vault enforces purge protection and RBAC authorization." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: Key Vault missing purge protection or RBAC authorization!" -ForegroundColor Red
        $FailedTests++
    }
} else {
    Write-Host "[-] FAIL: Key Vault file missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 2: CMK Automated Rotation Policy
Write-Host "`n[Test 2/5] Checking CMK Key Automated Rotation Policy..." -ForegroundColor Cyan
$CmkFile = "$RootDir\modules\security\cmk.tf"
if (Test-Path $CmkFile) {
    $content = Get-Content $CmkFile -Raw
    if ($content -match "rotation_policy" -and $content -match "time_before_expiry") {
        Write-Host "[+] PASS: CMK keys enforce ISO/IEC 27001 automated rotation." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: CMK rotation policy missing or incomplete!" -ForegroundColor Red
        $FailedTests++
    }
} else {
    Write-Host "[-] FAIL: CMK file missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 3: Storage Double Encryption
Write-Host "`n[Test 3/5] Checking Storage Infrastructure Double Encryption..." -ForegroundColor Cyan
$StorageFile = "$RootDir\modules\storage\main.tf"
if (Test-Path $StorageFile) {
    $content = Get-Content $StorageFile -Raw
    if ($content -match "infrastructure_encryption_enabled\s*=\s*true") {
        Write-Host "[+] PASS: Storage account enforces hardware-level double encryption." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: Storage infrastructure encryption not enabled!" -ForegroundColor Red
        $FailedTests++
    }
} else {
    Write-Host "[-] FAIL: Storage file missing!" -ForegroundColor Red
    $FailedTests++
}

# Test 4: Storage Zero Public Access & Minimum TLS
Write-Host "`n[Test 4/5] Checking Storage Network Exposure & TLS Configuration..." -ForegroundColor Cyan
if (Test-Path $StorageFile) {
    $content = Get-Content $StorageFile -Raw
    if ($content -match "public_network_access_enabled\s*=\s*false" -and $content -match "min_tls_version\s*=\s*`"TLS1_2`"") {
        Write-Host "[+] PASS: Storage public access is disabled and TLS 1.2+ is enforced." -ForegroundColor Green
    } else {
        Write-Host "[-] FAIL: Storage public access not disabled or weak TLS allowed!" -ForegroundColor Red
        $FailedTests++
    }
}

# Test 5: Managed Identity Module Exists
Write-Host "`n[Test 5/5] Checking Passwordless Managed Identity Architecture..." -ForegroundColor Cyan
$IdentityFile = "$RootDir\modules\identity\main.tf"
if ((Test-Path $IdentityFile) -and ((Get-Content $IdentityFile -Raw) -match "azurerm_user_assigned_identity")) {
    Write-Host "[+] PASS: Passwordless User-Assigned Managed Identity module verified." -ForegroundColor Green
} else {
    Write-Host "[-] FAIL: Managed Identity module missing!" -ForegroundColor Red
    $FailedTests++
}

Write-Host "`n================================================================" -ForegroundColor Cyan
if ($FailedTests -eq 0) {
    Write-Host "ALL SECURITY INVARIANT TESTS PASSED! (0 failures)" -ForegroundColor Green
} else {
    Write-Host "TEST SUITE FAILED WITH $FailedTests FAILURES!" -ForegroundColor Red
    exit 1
}
Write-Host "================================================================" -ForegroundColor Cyan
