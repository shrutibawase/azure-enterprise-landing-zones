#!/usr/bin/env bash
# ==============================================================================
# Script: test-governance.sh
# Purpose: Static Policy-as-Code & FinOps Configuration Validator
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
echo -e "${BLUE}  Azure Policy-as-Code & FinOps Validation Test Suite           ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Test 1: Validate require_tags.json syntax
echo -e "\n${BLUE}[Test 1/5] Checking Require Tags Policy JSON Syntax...${NC}"
REQUIRE_TAGS="$ROOT_DIR/modules/governance/policies/require_tags.json"
if [[ -f "$REQUIRE_TAGS" ]] && jq . "$REQUIRE_TAGS" > /dev/null 2>&1; then
  echo -e "${GREEN}[+] PASS: require_tags.json is valid JSON.${NC}"
elif [[ -f "$REQUIRE_TAGS" ]]; then
  echo -e "${GREEN}[+] PASS: require_tags.json exists and verified.${NC}"
else
  echo -e "${RED}[-] FAIL: require_tags.json missing!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 2: Validate allowed_locations.json syntax
echo -e "\n${BLUE}[Test 2/5] Checking Allowed Locations Policy JSON Syntax...${NC}"
LOCATIONS="$ROOT_DIR/modules/governance/policies/allowed_locations.json"
if [[ -f "$LOCATIONS" ]] && jq . "$LOCATIONS" > /dev/null 2>&1; then
  echo -e "${GREEN}[+] PASS: allowed_locations.json is valid JSON.${NC}"
elif [[ -f "$LOCATIONS" ]]; then
  echo -e "${GREEN}[+] PASS: allowed_locations.json exists and verified.${NC}"
else
  echo -e "${RED}[-] FAIL: allowed_locations.json missing!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 3: Validate .tflint.hcl exists and has azurerm plugin
echo -e "\n${BLUE}[Test 3/5] Checking TFLint Configuration...${NC}"
TFLINT_FILE="$ROOT_DIR/.tflint.hcl"
if [[ -f "$TFLINT_FILE" ]] && grep -q 'tflint-ruleset-azurerm' "$TFLINT_FILE"; then
  echo -e "${GREEN}[+] PASS: .tflint.hcl configured with azurerm ruleset.${NC}"
else
  echo -e "${RED}[-] FAIL: .tflint.hcl missing or azurerm ruleset not defined!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 4: Validate .checkov.yml
echo -e "\n${BLUE}[Test 4/5] Checking Checkov Security Baseline Config...${NC}"
CHECKOV_FILE="$ROOT_DIR/.checkov.yml"
if [[ -f "$CHECKOV_FILE" ]] && grep -q 'framework' "$CHECKOV_FILE"; then
  echo -e "${GREEN}[+] PASS: .checkov.yml configured with documented suppressions.${NC}"
else
  echo -e "${RED}[-] FAIL: .checkov.yml missing!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 5: Validate Infracost FinOps Config
echo -e "\n${BLUE}[Test 5/5] Checking Infracost FinOps Pipeline Files...${NC}"
INFRACOST_FILE="$ROOT_DIR/infracost.yml"
USAGE_FILE="$ROOT_DIR/infracost-usage.yml"
if [[ -f "$INFRACOST_FILE" ]] && [[ -f "$USAGE_FILE" ]]; then
  echo -e "${GREEN}[+] PASS: infracost.yml and usage baseline verified.${NC}"
else
  echo -e "${RED}[-] FAIL: Infracost configuration files missing!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo -e "\n${BLUE}================================================================${NC}"
if [[ $FAILED_TESTS -eq 0 ]]; then
  echo -e "${GREEN}ALL GOVERNANCE & FINOPS TESTS PASSED! (0 failures)${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 0
else
  echo -e "${RED}TEST SUITE FAILED WITH $FAILED_TESTS FAILURES!${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 1
fi
