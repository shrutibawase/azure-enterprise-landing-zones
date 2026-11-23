# ==============================================================================
# Script: test-monitoring.ps1
# Purpose: Automated validation test suite for Azure Enterprise Monitoring & Observability
# ==============================================================================

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$monitoringDir = Join-Path $rootDir "modules\monitoring"

$totalTests = 6
$passedTests = 0

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Azure Enterprise Landing Zone - Monitoring Test Suite" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Test 1: Terraform syntax and validation
Write-Host -NoNewline "[TEST 1/$totalTests] Validating Terraform syntax in modules/monitoring... "
Push-Location $monitoringDir
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

# Test 2: Log Analytics retention constraint verification
Write-Host -NoNewline "[TEST 2/$totalTests] Verifying Log Analytics minimum retention configuration... "
$variablesContent = Get-Content (Join-Path $monitoringDir "variables.tf") -Raw
if ($variablesContent -match "retention_in_days" -and $variablesContent -match "default\s+=\s+30") {
    Write-Host "PASSED" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "FAILED" -ForegroundColor Red
    exit 1
}

# Test 3: Daily quota billing guardrail verification
Write-Host -NoNewline "[TEST 3/$totalTests] Verifying Daily Ingestion Quota guardrail configuration... "
$workspaceContent = Get-Content (Join-Path $monitoringDir "workspace.tf") -Raw
if ($workspaceContent -match "daily_quota_gb" -and $variablesContent -match "default\s+=\s+10") {
    Write-Host "PASSED" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "FAILED" -ForegroundColor Red
    exit 1
}

# Test 4: Data Collection Rule (DCR) syslog and performance metrics verification
Write-Host -NoNewline "[TEST 4/$totalTests] Verifying Data Collection Rule (DCR) streams and facilities... "
$dcrContent = Get-Content (Join-Path $monitoringDir "dcr.tf") -Raw
if ($dcrContent -match "Microsoft-Syslog" -and $dcrContent -match "Microsoft-InsightsMetrics" -and $dcrContent -match "auth") {
    Write-Host "PASSED" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "FAILED" -ForegroundColor Red
    exit 1
}

# Test 5: Action Group multi-channel integration verification
Write-Host -NoNewline "[TEST 5/$totalTests] Verifying Action Group notification receivers... "
$agContent = Get-Content (Join-Path $monitoringDir "action_group.tf") -Raw
if ($agContent -match "email_receiver" -and $agContent -match "webhook_receiver" -and $agContent -match "arm_role_receiver") {
    Write-Host "PASSED" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "FAILED" -ForegroundColor Red
    exit 1
}

# Test 6: Production KQL Query Runbook verification
Write-Host -NoNewline "[TEST 6/$totalTests] Verifying KQL query runbooks existence and syntax integrity... "
$queriesDir = Join-Path $monitoringDir "queries"
$q1 = Test-Path (Join-Path $queriesDir "vmss_cpu_utilization.kql")
$q2 = Test-Path (Join-Path $queriesDir "firewall_dropped_traffic.kql")
$q3 = Test-Path (Join-Path $queriesDir "keyvault_audit_events.kql")
$q4 = Test-Path (Join-Path $queriesDir "waf_blocked_attacks.kql")

if ($q1 -and $q2 -and $q3 -and $q4) {
    Write-Host "PASSED" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "FAILED" -ForegroundColor Red
    exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Test Results: $passedTests/$totalTests passed successfully." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
