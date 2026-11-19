#!/usr/bin/env bash
# ==============================================================================
# Script: test-terraform.sh
# Purpose: Comprehensive Terraform Static Analysis, Formatting & Syntax Validation
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED_TESTS=0

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}  Azure Enterprise Landing Zone: Terraform Validation Suite     ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Check terraform command
if ! command -v terraform &>/dev/null; then
  echo -e "${RED}[-] Error: 'terraform' CLI is not found in PATH.${NC}"
  exit 1
fi

# 1. Format Check
echo -e "\n${BLUE}[Test 1/4] Checking Terraform Canonical Formatting...${NC}"
if terraform fmt -check -recursive "$ROOT_DIR" > /dev/null 2>&1; then
  echo -e "${GREEN}[+] PASS: All Terraform files are canonically formatted.${NC}"
else
  echo -e "${YELLOW}[!] WARNING: Files need formatting. Run: terraform fmt -recursive${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# 2. Init Root Module
echo -e "\n${BLUE}[Test 2/4] Initializing Terraform (Backend Disabled)...${NC}"
if terraform -chdir="$ROOT_DIR" init -backend=false > /dev/null 2>&1; then
  echo -e "${GREEN}[+] PASS: Root module initialized successfully.${NC}"
else
  echo -e "${RED}[-] FAIL: Terraform init failed!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# 3. Validate Root Module
echo -e "\n${BLUE}[Test 3/4] Validating Root Module Configuration...${NC}"
if terraform -chdir="$ROOT_DIR" validate > /dev/null 2>&1; then
  echo -e "${GREEN}[+] PASS: Root module configuration is valid.${NC}"
else
  echo -e "${RED}[-] FAIL: Terraform validation failed!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# 4. Validate Child Modules
echo -e "\n${BLUE}[Test 4/4] Validating Child Modules in modules/...${NC}"
for module_dir in "$ROOT_DIR"/modules/*/; do
  module_name=$(basename "$module_dir")
  echo "Checking module: $module_name"
  if terraform -chdir="$module_dir" init -backend=false > /dev/null 2>&1 && \
     terraform -chdir="$module_dir" validate > /dev/null 2>&1; then
    echo -e "${GREEN}[+] PASS: Module '$module_name' is valid.${NC}"
  else
    echo -e "${RED}[-] FAIL: Module '$module_name' validation failed!${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
done

echo -e "\n${BLUE}================================================================${NC}"
if [[ $FAILED_TESTS -eq 0 ]]; then
  echo -e "${GREEN}ALL TERRAFORM VALIDATION TESTS PASSED! (0 failures)${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 0
else
  echo -e "${RED}TEST SUITE FAILED WITH $FAILED_TESTS FAILURES!${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 1
fi
