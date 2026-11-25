#!/usr/bin/env bash
# ==============================================================================
# Script: test-pipeline.sh
# Purpose: Automated validation test suite for GitHub Actions CI/CD & Environments
# Author: Shruti Bawase
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TOTAL_TESTS=5
PASSED_TESTS=0

echo "============================================================"
echo "Azure Enterprise Landing Zone - CI/CD & Pipeline Test Suite"
echo "============================================================"

# Test 1: GitHub Actions workflows existence and OIDC permission check
echo -n "[TEST 1/${TOTAL_TESTS}] Verifying GitHub Actions workflows and OIDC permissions... "
WORKFLOWS_DIR="${ROOT_DIR}/.github/workflows"
if [ -f "${WORKFLOWS_DIR}/terraform-deploy.yml" ] && \
   [ -f "${WORKFLOWS_DIR}/drift-detection.yml" ] && \
   [ -f "${WORKFLOWS_DIR}/infracost-commenter.yml" ] && \
   grep -q "id-token: write" "${WORKFLOWS_DIR}/terraform-deploy.yml" && \
   grep -q "azure/login" "${WORKFLOWS_DIR}/terraform-deploy.yml"; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 2: Environment parameter files verification across dev, uat, prod
echo -n "[TEST 2/${TOTAL_TESTS}] Verifying environment tfvars isolation across stages... "
ENV_DIR="${ROOT_DIR}/environments"
if [ -f "${ENV_DIR}/dev/terraform.tfvars" ] && \
   [ -f "${ENV_DIR}/uat/terraform.tfvars" ] && \
   [ -f "${ENV_DIR}/prod/terraform.tfvars" ] && \
   grep -q 'environment      = "dev"' "${ENV_DIR}/dev/terraform.tfvars" && \
   grep -q 'environment      = "uat"' "${ENV_DIR}/uat/terraform.tfvars" && \
   grep -q 'environment      = "prod"' "${ENV_DIR}/prod/terraform.tfvars"; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 3: Terragrunt configuration and remote state generation check
echo -n "[TEST 3/${TOTAL_TESTS}] Verifying Terragrunt DRY architecture and provider generation... "
if [ -f "${ROOT_DIR}/terragrunt.hcl" ] && \
   grep -q "remote_state" "${ROOT_DIR}/terragrunt.hcl" && \
   grep -q "generate \"provider\"" "${ROOT_DIR}/terragrunt.hcl" && \
   [ -f "${ENV_DIR}/prod/terragrunt.hcl" ]; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 4: Drift reconciliation self-healing scripts verification
echo -n "[TEST 4/${TOTAL_TESTS}] Verifying drift reconciliation scripts and flag handling... "
SCRIPTS_DIR="${ROOT_DIR}/scripts"
if [ -f "${SCRIPTS_DIR}/reconcile-drift.sh" ] && \
   [ -f "${SCRIPTS_DIR}/reconcile-drift.ps1" ] && \
   grep -q "auto-apply" "${SCRIPTS_DIR}/reconcile-drift.sh" && \
   grep -q "AutoApply" "${SCRIPTS_DIR}/reconcile-drift.ps1"; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

# Test 5: Terraform static syntax validation against environment inputs
echo -n "[TEST 5/${TOTAL_TESTS}] Validating Terraform core syntax against production inputs... "
cd "${ROOT_DIR}"
terraform init -backend=false > /dev/null 2>&1
if terraform validate > /dev/null 2>&1; then
    echo "PASSED"
    ((PASSED_TESTS++))
else
    echo "FAILED"
    exit 1
fi

echo "============================================================"
echo "Test Results: ${PASSED_TESTS}/${TOTAL_TESTS} passed successfully."
echo "============================================================"
