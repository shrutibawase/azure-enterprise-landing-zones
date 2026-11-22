#!/usr/bin/env bash
# ==============================================================================
# Script: test-compute.sh
# Purpose: Static Security & Invariant Asserter for WAF and Compute Scaling
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
echo -e "${BLUE}  WAF & Resilient Multi-AZ Compute Invariant Test Suite         ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Test 1: WAF_v2 Mode is Prevention
echo -e "\n${BLUE}[Test 1/6] Checking Application Gateway WAF Prevention Mode...${NC}"
WAF_FILE="$ROOT_DIR/modules/app_gateway/waf_policy.tf"
if grep -q 'mode\s*=\s*"Prevention"' "$WAF_FILE" && \
   grep -q 'version\s*=\s*"3.2"' "$WAF_FILE"; then
  echo -e "${GREEN}[+] PASS: WAF Policy enforces OWASP 3.2 in strict Prevention mode.${NC}"
else
  echo -e "${RED}[-] FAIL: WAF Policy not configured in Prevention mode!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 2: WAF Rate Limiting Rule
echo -e "\n${BLUE}[Test 2/6] Checking Custom Rate-Limiting Rules...${NC}"
if grep -q 'rule_type\s*=\s*"RateLimitRule"' "$WAF_FILE" && \
   grep -q 'rate_limit_duration\s*=\s*"OneMin"' "$WAF_FILE"; then
  echo -e "${GREEN}[+] PASS: WAF Rate-Limiting rule verified.${NC}"
else
  echo -e "${RED}[-] FAIL: WAF Rate-Limiting rule missing!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 3: VMSS Multi-AZ and ZRS Storage
echo -e "\n${BLUE}[Test 3/6] Checking VMSS Multi-AZ & ZRS Storage...${NC}"
VMSS_FILE="$ROOT_DIR/modules/compute/main.tf"
if grep -q 'zones\s*=\s*\["1", "2", "3"\]' "$VMSS_FILE" && \
   grep -q 'storage_account_type\s*=\s*"Premium_ZRS"' "$VMSS_FILE"; then
  echo -e "${GREEN}[+] PASS: VMSS configured for Availability Zones 1,2,3 with Premium ZRS.${NC}"
else
  echo -e "${RED}[-] FAIL: VMSS missing Multi-AZ or ZRS storage!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 4: Cloud-Init Hardening & Healthz Probe
echo -e "\n${BLUE}[Test 4/6] Checking Cloud-Init Bootstrap Invariants...${NC}"
CLOUD_INIT="$ROOT_DIR/modules/compute/cloud-init.yaml"
if [[ -f "$CLOUD_INIT" ]] && \
   grep -q 'net.ipv4.tcp_syncookies = 1' "$CLOUD_INIT" && \
   grep -q 'healthz-probe.service' "$CLOUD_INIT"; then
  echo -e "${GREEN}[+] PASS: Cloud-Init includes kernel hardening and health probe service.${NC}"
else
  echo -e "${RED}[-] FAIL: Cloud-Init script missing security hardening!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 5: Dynamic Autoscaling Settings
echo -e "\n${BLUE}[Test 5/6] Checking Dynamic Auto-Scaling Triggers...${NC}"
AUTOSCALE_FILE="$ROOT_DIR/modules/compute/autoscale.tf"
if grep -q 'threshold\s*=\s*75' "$AUTOSCALE_FILE" && \
   grep -q 'threshold\s*=\s*25' "$AUTOSCALE_FILE"; then
  echo -e "${GREEN}[+] PASS: CPU threshold scale-out (75%) and scale-in (25%) verified.${NC}"
else
  echo -e "${RED}[-] FAIL: Autoscale thresholds not configured properly!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 6: Rolling Upgrade Policy
echo -e "\n${BLUE}[Test 6/6] Checking Rolling Upgrade Maintenance Policy...${NC}"
if grep -q 'upgrade_mode\s*=\s*"Rolling"' "$VMSS_FILE" && \
   grep -q 'rolling_upgrade_policy' "$VMSS_FILE"; then
  echo -e "${GREEN}[+] PASS: VMSS enforces zero-downtime Rolling Upgrades.${NC}"
else
  echo -e "${RED}[-] FAIL: Rolling upgrade policy missing from VMSS!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo -e "\n${BLUE}================================================================${NC}"
if [[ $FAILED_TESTS -eq 0 ]]; then
  echo -e "${GREEN}ALL WAF & COMPUTE INVARIANT TESTS PASSED! (0 failures)${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 0
else
  echo -e "${RED}TEST SUITE FAILED WITH $FAILED_TESTS FAILURES!${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 1
fi
