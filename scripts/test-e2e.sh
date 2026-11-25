#!/usr/bin/env bash
# ==============================================================================
# Script: test-e2e.sh
# Purpose: Master End-to-End Architectural Test Runner for Azure Landing Zone
# Author: Shruti Bawase
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "========================================================================"
echo "  AZURE ENTERPRISE CLOUD LANDING ZONE - MASTER E2E TEST RUNNER"
echo "  Architect: Shruti Bawase"
echo "========================================================================"

FAILED_SUITES=0

run_suite() {
    local suite_name="$1"
    local script_path="$2"
    echo ""
    echo ">> Executing Test Suite: ${suite_name}..."
    if bash "${script_path}"; then
        echo ">> [SUCCESS] ${suite_name} passed."
    else
        echo ">> [FAILURE] ${suite_name} failed!"
        ((FAILED_SUITES++))
    fi
}

# Day 1: Transit Networking & Hub-Spoke
run_suite "Day 1: Transit Networking" "${SCRIPT_DIR}/test-terraform.sh"

# Day 2: Zero-Trust Identity, CMK & Storage
run_suite "Day 2: Identity & Security" "${SCRIPT_DIR}/test-security.sh"

# Day 3: Multi-AZ VMSS Compute & WAF
run_suite "Day 3: Compute & WAF" "${SCRIPT_DIR}/test-compute.sh"

# Day 4: Policy-as-Code & CIS Benchmark
run_suite "Day 4: Governance & Policies" "${SCRIPT_DIR}/test-governance.sh"

# Day 5: Observability, Alerts & DCRs
run_suite "Day 5: Observability & Monitoring" "${SCRIPT_DIR}/test-monitoring.sh"

# Day 6: CI/CD Pipelines & Drift Self-Healing
run_suite "Day 6: CI/CD & Environments" "${SCRIPT_DIR}/test-pipeline.sh"

# Day 7: Backup Vault & Disaster Recovery Invariants
echo ""
echo ">> Executing Test Suite: Day 7: Backup & Disaster Recovery..."
BACKUP_DIR="${ROOT_DIR}/modules/backup"
DR_DIR="${ROOT_DIR}/modules/dr"

if [ -f "${BACKUP_DIR}/vault.tf" ] && \
   grep -q "GeoRedundant" "${BACKUP_DIR}/variables.tf" && \
   grep -q "cross_region_restore_enabled" "${BACKUP_DIR}/vault.tf" && \
   [ -f "${DR_DIR}/main.tf" ] && \
   grep -q "is_valid_pairing" "${DR_DIR}/main.tf"; then
    echo ">> [SUCCESS] Day 7: Backup & Disaster Recovery passed."
else
    echo ">> [FAILURE] Day 7: Backup & Disaster Recovery failed!"
    ((FAILED_SUITES++))
fi

echo ""
echo "========================================================================"
if [ $FAILED_SUITES -eq 0 ]; then
    echo "  ALL ARCHITECTURAL TEST SUITES PASSED (7/7 Days 100% Green)"
    echo "========================================================================"
    exit 0
else
    echo "  TEST FAILURES DETECTED: ${FAILED_SUITES} suites failed."
    echo "========================================================================"
    exit 1
fi
