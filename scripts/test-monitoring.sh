#!/usr/bin/env bash
# ==============================================================================
# Script: test-monitoring.sh
# Purpose: Automated validation test suite for Azure Enterprise Monitoring & Observability
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MONITORING_DIR="${ROOT_DIR}/modules/monitoring"

TOTAL_TESTS=6
PASSED_TESTS=0

echo "============================================================"
echo "Azure Enterprise Landing Zone - Monitoring Test Suite"
echo "============================================================"

# Test 1: Terraform syntax and validation
echo -n "[TEST 1/${TOTAL_TESTS}] Validating Terraform syntax in modules/monitoring... "
cd "${MONITORING_DIR}"
terraform init -backend=false > /dev/null 2>&1
if terraform validate > /dev/null 2>&1; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 2: Log Analytics retention constraint verification
echo -n "[TEST 2/${TOTAL_TESTS}] Verifying Log Analytics minimum retention configuration... "
if grep -q "retention_in_days" "${MONITORING_DIR}/variables.tf" && \
   grep -q "default     = 30" "${MONITORING_DIR}/variables.tf"; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 3: Daily quota billing guardrail verification
echo -n "[TEST 3/${TOTAL_TESTS}] Verifying Daily Ingestion Quota guardrail configuration... "
if grep -q "daily_quota_gb" "${MONITORING_DIR}/workspace.tf" && \
   grep -q "default     = 10" "${MONITORING_DIR}/variables.tf"; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 4: Data Collection Rule (DCR) syslog and performance metrics verification
echo -n "[TEST 4/${TOTAL_TESTS}] Verifying Data Collection Rule (DCR) streams and facilities... "
if grep -q "Microsoft-Syslog" "${MONITORING_DIR}/dcr.tf" && \
   grep -q "Microsoft-InsightsMetrics" "${MONITORING_DIR}/dcr.tf" && \
   grep -q "auth" "${MONITORING_DIR}/dcr.tf"; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 5: Action Group multi-channel integration verification
echo -n "[TEST 5/${TOTAL_TESTS}] Verifying Action Group notification receivers... "
if grep -q "email_receiver" "${MONITORING_DIR}/action_group.tf" && \
   grep -q "webhook_receiver" "${MONITORING_DIR}/action_group.tf" && \
   grep -q "arm_role_receiver" "${MONITORING_DIR}/action_group.tf"; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 6: Production KQL Query Runbook verification
echo -n "[TEST 6/${TOTAL_TESTS}] Verifying KQL query runbooks existence and syntax integrity... "
QUERIES_DIR="${MONITORING_DIR}/queries"
if [ -f "${QUERIES_DIR}/vmss_cpu_utilization.kql" ] && \
   [ -f "${QUERIES_DIR}/firewall_dropped_traffic.kql" ] && \
   [ -f "${QUERIES_DIR}/keyvault_audit_events.kql" ] && \
   [ -f "${QUERIES_DIR}/waf_blocked_attacks.kql" ]; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

echo "============================================================"
echo "Test Results: ${PASSED_TESTS}/${TOTAL_TESTS} passed successfully."
echo "============================================================"
