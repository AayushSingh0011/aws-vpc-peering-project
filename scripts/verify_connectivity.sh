#!/usr/bin/env bash
# ==============================================================================
# EWB Cloud Labs - AWS VPC Peering Connectivity & Verification Script
# Page 11 of Student Workbook: "Prove the project works"
# ==============================================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}         EWB CLOUD LABS: AWS VPC PEERING AUTOMATED TEST SUITE                 ${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# Check SSH config presence
if ! grep -q "ewb-bastion" ~/.ssh/config 2>/dev/null; then
    echo -e "${RED}[ERROR] ~/.ssh/config is missing ewb-bastion configuration.${NC}"
    echo "Please copy config/ssh_config into ~/.ssh/config and update BASTION_PUBLIC_IP."
    exit 1
fi

echo -e "\n${YELLOW}[Test 01 / Baseline Failure (Page 8 & 11)]${NC}"
echo "Executing: Inside App-A, ping -c 4 10.20.1.10 before peering"
echo "Expected: 100% packet loss (No replies)"
echo "------------------------------------------------------------------------------"
ssh -q ewb-app-a "hostname; hostname -I; ping -c 4 -W 2 10.20.1.10" || {
    echo -e "${GREEN}--> [PASS] Baseline failure confirmed as expected (destination unreachable).${NC}"
}

echo -e "\n${YELLOW}[Test 02 / Forward Path Verification (Page 11)]${NC}"
echo "Executing: Inside App-A, ping -c 4 10.20.1.10 (App-B)"
echo "Expected: 4 replies, 0% packet loss"
echo "------------------------------------------------------------------------------"
ssh -q ewb-app-a "echo 'Host: \$(hostname) (\$(hostname -I))'; ping -c 4 10.20.1.10"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}--> [PASS] Forward path ping succeeded (0% packet loss).${NC}"
else
    echo -e "${RED}--> [FAIL] Forward path ping failed.${NC}"
fi

echo -e "\n${YELLOW}[Test 03 / Reverse Path Verification (Page 11)]${NC}"
echo "Executing: Inside App-B, ping -c 4 10.10.2.10 (App-A)"
echo "Expected: 4 replies, 0% packet loss"
echo "------------------------------------------------------------------------------"
ssh -q ewb-app-b "echo 'Host: \$(hostname) (\$(hostname -I))'; ping -c 4 10.10.2.10"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}--> [PASS] Reverse path ping succeeded (0% packet loss).${NC}"
else
    echo -e "${RED}--> [FAIL] Reverse path ping failed.${NC}"
fi

echo -e "\n${YELLOW}[Test 04 / Private SSH Access (Page 11)]${NC}"
echo "Executing: Laptop -> Bastion -> App-B (via ProxyJump)"
echo "Expected: Successful shell execution on App-B"
echo "------------------------------------------------------------------------------"
ssh -q ewb-app-b "echo 'Connected successfully to: '\$(hostname)' | Private IP: '\$(hostname -I)"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}--> [PASS] SSH ProxyJump to App-B succeeded.${NC}"
else
    echo -e "${RED}--> [FAIL] SSH ProxyJump to App-B failed.${NC}"
fi

echo -e "\n${YELLOW}[Test 05 / Controlled Failure Demo (Page 11)]${NC}"
echo "Instructions:"
echo "1. In AWS Console -> Security Groups -> ewb-sg-app-b -> Edit inbound rules."
echo "2. Temporarily remove the ICMP rule (Echo request from 10.10.2.10/32)."
echo "3. Run: ssh ewb-app-a 'ping -c 4 10.20.1.10' -> Should fail (100% loss)."
echo "4. Restore the ICMP rule in ewb-sg-app-b."
echo "5. Run: ssh ewb-app-a 'ping -c 4 10.20.1.10' -> Should immediately recover (0% loss)."
echo -e "${BLUE}==============================================================================${NC}"
