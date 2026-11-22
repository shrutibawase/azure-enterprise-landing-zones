# Multi-AZ Compute, Application Gateway WAF & Auto-Scaling Architecture

## 1. Architecture Overview

This module delivers a resilient, high-availability compute tier engineered for mission-critical enterprise workloads across **three Availability Zones** (`zones = ["1", "2", "3"]`). Ingress traffic is inspected and load-balanced by **Azure Application Gateway v2 (WAF_v2)** with **OWASP 3.2 Core Rule Set (CRS)** operating in strict **Prevention Mode**.

```mermaid
flowchart TD
    subgraph INGRESS["ðŸŒ  Perimeter Ingress & L7 Inspection"]
        CLIENT["Internet Client Traffic"] --> APPGW["Azure Application Gateway v2\n(SKU: WAF_v2, Zones 1, 2, 3)"]
        APPGW --> WAF["WAF Policy (Prevention Mode)\n- OWASP 3.2 Core Rules\n- Microsoft Bot Manager\n- Custom Rate-Limiting (/api/*)"]
    end

    subgraph WORKLOADS["☸️ Resilient Multi-AZ Compute (VMSS)"]
        direction TB
        BEPOOL["Application Gateway Backend Address Pool"]
        VM1["VMSS Instance 01\n(Zone 1, Premium ZRS)"]
        VM2["VMSS Instance 02\n(Zone 2, Premium ZRS)"]
        VM3["VMSS Instance 03\n(Zone 3, Premium ZRS)"]
        SCALE["Azure Monitor Autoscale\n(CPU > 75% Scale Out, CPU < 25% Scale In)"]
    end

    WAF -->|Filtered Traffic (HTTP 80)| BEPOOL
    BEPOOL --> VM1
    BEPOOL --> VM2
    BEPOOL --> VM3
    SCALE -.->|Dynamic Provisioning| WORKLOADS
```

---

## 2. Core Engineering Invariants

### 2.1 Web Application Firewall (WAF) Prevention Mode
- **Zero-Tolerance Enforcement:** Operates in `Prevention` mode rather than `Detection`. Malicious payloads (SQLi, XSS, RCE, LFI) are blocked immediately at the edge with HTTP 403.
- **OWASP 3.2 CRS:** Protects against the OWASP Top 10 web application vulnerabilities.
- **Bot Mitigation:** Integrated `Microsoft_BotManagerRuleSet` identifies and drops malicious scrapers and search bots.
- **Rate-Limiting:** Enforces a strict threshold of **100 requests per 1 minute** on sensitive API endpoints (`/api/*`), mitigating denial-of-service and brute-force attempts.

### 2.2 Multi-AZ High Availability & Premium ZRS Storage
- Scale set instances are evenly distributed across Availability Zones `1`, `2`, and `3`.
- The OS disk is backed by **Premium Zone-Redundant Storage (`Premium_ZRS`)**, guaranteeing storage durability even during an entire datacenter outage.

### 2.3 Cloud-Init System Hardening
Upon initial boot, instances execute a declarative `cloud-init.yaml`:
- **Kernel Security:** Enforces `tcp_syncookies = 1`, `rp_filter = 1` (reverse path filtering), and disables ICMP redirects.
- **SSH Hardening:** Enforces `PasswordAuthentication no` to require key-based authentication exclusively.
- **Readiness Probing:** Spawns a dedicated systemd service responding to `/healthz` on status codes `200-399`.

### 2.4 Dynamic Autoscaling & Rolling Upgrades
- **Autoscale Triggers:**
  - **Scale-Out:** When average CPU utilization exceeds **75%** over a 5-minute rolling window, an additional instance is provisioned (`+1`).
  - **Scale-In:** When average CPU drops below **25%** over a 5-minute window, capacity is safely decommissioned (`-1`).
- **Rolling Maintenance:** Zero-downtime updates are guaranteed via `upgrade_mode = "Rolling"` with `max_batch_instance_percent = 20`.

---

## 3. Verification Commands

Run the automated compute and WAF test suite:

```bash
# Linux / macOS
./scripts/test-compute.sh

# Windows PowerShell
.\scripts\test-compute.ps1
```
