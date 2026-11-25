#!/usr/bin/env bash
# ==============================================================================
# Script: reconcile-drift.sh
# Purpose: Enterprise Terraform Drift Detection, Refresh, and Self-Healing
# Author: Shruti Bawase
# ==============================================================================

set -euo pipefail

ENV="dev"
ACTION="plan"
AUTO_APPLY=false
REFRESH_ONLY=false

usage() {
    echo "Usage: $0 [-e <dev|uat|prod>] [-a] [-r] [-h]"
    echo "  -e, --env          Target environment (default: dev)"
    echo "  -a, --auto-apply   Automatically reapply desired state to self-heal drift"
    echo "  -r, --refresh-only Only refresh state without planning changes"
    echo "  -h, --help         Show this usage guide"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--env)
            ENV="$2"
            shift 2
            ;;
        -a|--auto-apply)
            AUTO_APPLY=true
            shift
            ;;
        -r|--refresh-only)
            REFRESH_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TFVARS_FILE="${ROOT_DIR}/environments/${ENV}/terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "Error: Configuration file not found at ${TFVARS_FILE}"
    exit 1
fi

echo "============================================================"
echo "Terraform Drift Reconciliation Engine"
echo "Target Environment: ${ENV}"
echo "============================================================"

cd "${ROOT_DIR}"

echo "Step 1: Refreshing state from live Azure resources..."
terraform refresh -var-file="${TFVARS_FILE}"

if [ "$REFRESH_ONLY" = true ]; then
    echo "State refreshed successfully. Exiting per --refresh-only flag."
    exit 0
fi

echo "Step 2: Calculating delta between refreshed state and code..."
set +e
terraform plan -detailed-exitcode -no-color -var-file="${TFVARS_FILE}" -out="${ENV}-drift.tfplan"
PLAN_EXIT=$?
set -e

if [ $PLAN_EXIT -eq 0 ]; then
    echo "✅ [SUCCESS] Zero drift detected. Live infrastructure matches code perfectly."
    rm -f "${ENV}-drift.tfplan"
    exit 0
elif [ $PLAN_EXIT -eq 2 ]; then
    echo "⚠️ [ALERT] Infrastructure drift detected in ${ENV} environment!"
    
    if [ "$AUTO_APPLY" = true ]; then
        echo "Step 3: Self-healing enabled (--auto-apply). Reconciling live infrastructure..."
        terraform apply -auto-approve "${ENV}-drift.tfplan"
        echo "✅ [RECONCILED] Desired state restored. Drift resolved."
        rm -f "${ENV}-drift.tfplan"
    else
        echo "Notice: Run with -a/--auto-apply to automatically reconcile live infrastructure."
        echo "Preserving drift plan artifact at: ${ENV}-drift.tfplan"
    fi
else
    echo "❌ [ERROR] Terraform plan failed with exit code ${PLAN_EXIT}."
    exit $PLAN_EXIT
fi
