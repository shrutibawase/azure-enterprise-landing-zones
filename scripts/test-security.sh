#!/usr/bin/env bash
# ==============================================================================
# Script: test-security.sh
# Purpose: Static Security Invariant Asserter for Identity, CMK & Storage Modules
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
echo -e "${BLUE}  Zero-Trust Identity, CMK & Storage Security Verification      ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Test 1: Key Vault Purge Protection & RBAC
echo -e "\n${BLUE}[Test 1/5] Checking Key Vault Security Invariants...${NC}"
KV_FILE="$ROOT_DIR/modules/security/main.tf"
if grep -q "purge_protection_enabled\s*=\s*true" "$KV_FILE" && \
   grep -q "enable_rbac_authorization\s*=\s*true" "$KV_FILE"; then
  echo -e "${GREEN}[+] PASS: Key Vault enforces purge protection and RBAC authorization.${NC}"
else
  echo -e "${RED}[-] FAIL: Key Vault missing purge protection or RBAC authorization!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 2: CMK Automated Rotation Policy
echo -e "\n${BLUE}[Test 2/5] Checking CMK Key Automated Rotation Policy...${NC}"
CMK_FILE="$ROOT_DIR/modules/security/cmk.tf"
if grep -q "rotation_policy" "$CMK_FILE" && \
   grep -q "time_before_expiry" "$CMK_FILE"; then
  echo -e "${GREEN}[+] PASS: CMK keys enforce ISO/IEC 27001 automated rotation.${NC}"
else
  echo -e "${RED}[-] FAIL: CMK rotation policy missing or incomplete!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 3: Storage Double Encryption (Infrastructure Encryption)
echo -e "\n${BLUE}[Test 3/5] Checking Storage Infrastructure Double Encryption...${NC}"
STORAGE_FILE="$ROOT_DIR/modules/storage/main.tf"
if grep -q "infrastructure_encryption_enabled\s*=\s*true" "$STORAGE_FILE"; then
  echo -e "${GREEN}[+] PASS: Storage account enforces hardware-level double encryption.${NC}"
else
  echo -e "${RED}[-] FAIL: Storage infrastructure encryption not enabled!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 4: Storage Zero Public Access & Minimum TLS
echo -e "\n${BLUE}[Test 4/5] Checking Storage Network Exposure & TLS Configuration...${NC}"
if grep -q "public_network_access_enabled\s*=\s*false" "$STORAGE_FILE" && \
   grep -q "min_tls_version\s*=\s*\"TLS1_2\"" "$STORAGE_FILE"; then
  echo -e "${GREEN}[+] PASS: Storage public access is disabled and TLS 1.2+ is enforced.${NC}"
else
  echo -e "${RED}[-] FAIL: Storage public access not disabled or weak TLS allowed!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 5: Managed Identity Module Exists
echo -e "\n${BLUE}[Test 5/5] Checking Passwordless Managed Identity Architecture...${NC}"
IDENTITY_FILE="$ROOT_DIR/modules/identity/main.tf"
if [[ -f "$IDENTITY_FILE" ]] && grep -q "azurerm_user_assigned_identity" "$IDENTITY_FILE"; then
  echo -e "${GREEN}[+] PASS: Passwordless User-Assigned Managed Identity module verified.${NC}"
else
  echo -e "${RED}[-] FAIL: Managed Identity module missing!${NC}"
  FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo -e "\n${BLUE}================================================================${NC}"
if [[ $FAILED_TESTS -eq 0 ]]; then
  echo -e "${GREEN}ALL SECURITY INVARIANT TESTS PASSED! (0 failures)${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 0
else
  echo -e "${RED}TEST SUITE FAILED WITH $FAILED_TESTS FAILURES!${NC}"
  echo -e "${BLUE}================================================================${NC}"
  exit 1
fi
