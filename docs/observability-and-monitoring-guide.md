# Enterprise Observability, Metric Alerting & KQL Runbooks

This guide details the architectural design, implementation patterns, and incident response playbooks for the central observability framework deployed within the Azure Enterprise Landing Zone.

---

## 1. Architectural Overview

```
                                  +------------------------------------+
                                  |     Enterprise Workloads & VNets   |
                                  +------------------------------------+
                                    |                |               |
             Syslog / Perf Metrics  |   APM Traces   |   Audit Logs  |
             (via Azure Monitor DCR)|  (App Insights)|  (Firewall/KV)|
                                    v                v               v
               +-------------------------------------------------------------+
               |     Central Log Analytics Workspace (law-enterprise-prod)   |
               |       - 30-day Retention Window                             |
               |       - 10 GB/day Billing Guardrail Quota                   |
               +-------------------------------------------------------------+
                                      |
                     +----------------+----------------+
                     |                                 |
                     v                                 v
   +------------------------------------+   +------------------------------------+
   |     Azure Monitor Metric Alerts    |   |     SecOps & KQL Runbook Engine    |
   |   - Failed Requests Spike (> 10)   |   |   - VMSS CPU & P95 Trends          |
   |   - App Latency Degradation (>2s)  |   |   - Firewall Dropped Traffic       |
   |   - VMSS Host CPU (> 85%)          |   |   - Key Vault Unauthorized Access  |
   +------------------------------------+   |   - WAF Blocked OWASP Attacks      |
                     |                      +------------------------------------+
                     v
   +------------------------------------+
   |   Action Group (Multi-Channel)     |
   |   - SecOps Email Notifications     |
   |   - PagerDuty / ITSM Webhook       |
   |   - Monitoring Contributor Roles   |
   +------------------------------------+
```

---

## 2. Core Telemetry Components

### Central Log Analytics Workspace
- **Workspace Name:** `law-enterprise-${var.environment}`
- **Ingestion Mode:** PerGB2018 (Workspace-based)
- **Retention:** Minimum 30 days enforced via CIS Azure Foundations Benchmark.
- **FinOps Daily Cap:** 10 GB/day ingestion limit configured to eliminate runaway costs caused by telemetry loops or log floods.

### Workspace-Based Application Insights
- **Component Name:** `appi-${var.workspace_name}`
- **Application Type:** `web`
- **Telemetry Ingestion:** Directly mapped to the central Log Analytics workspace ID, unifying application metrics and infrastructure logs into a single queryable data plane.

### Data Collection Rules (DCR)
The Azure Monitor Linux Agent (AMA) uses centralized Data Collection Rules to stream operating system telemetry:
- **Syslog Facilities:** `auth`, `authpriv`, `cron`, `daemon`, `mark`, `syslog`
- **Log Levels:** `Warning`, `Error`, `Critical`, `Alert`, `Emergency`
- **Performance Counters (60s frequency):**
  - `\Processor Information(_Total)\% Processor Time`
  - `\Memory\% Available Memory`
  - `\LogicalDisk(_Total)\% Free Space`
  - `\Network Interface(*)\Bytes Total/sec`

---

## 3. Metric Alerting & Incident Response

| Alert Name | Scope | Severity | Condition | Window / Frequency | Action Target |
|:---|:---|:---:|:---|:---:|:---|
| `alert-appi-failed-requests` | Application Insights | Sev 1 | `requests/failed > 10` | 5m / 1m | Critical Action Group |
| `alert-appi-high-response-time` | Application Insights | Sev 2 | `requests/duration > 2000 ms` | 5m / 1m | Critical Action Group |
| `alert-vmss-high-cpu` | VMSS | Sev 1 | `Percentage CPU > 85%` | 5m / 1m | Critical Action Group |

### Action Group Dispatch Channels
- **Email Receivers:** `secops@enterprise-domain.internal` with Common Alert Schema enabled.
- **Webhook Integration:** Automated JSON payload dispatch to PagerDuty or ServiceNow incident management endpoints.
- **RBAC Role Notification:** Immediate notification pushed to users with the built-in `Monitoring Contributor` role (`749f88d5-cbae-40b8-bcfc-f573eddca430`).

---

## 4. Production KQL Runbooks

Pre-compiled KQL queries are stored in `modules/monitoring/queries/`:

1. **VMSS CPU Utilization & P95 Trends** (`vmss_cpu_utilization.kql`)
   - Analyzes compute pressure across instances to evaluate if autoscale scaling rules need adjustments.
2. **Azure Firewall Denied Traffic** (`firewall_dropped_traffic.kql`)
   - Aggregates blocked egress/ingress flows by protocol, destination IP, and target port.
3. **Key Vault Audit & Access Failures** (`keyvault_audit_events.kql`)
   - Highlights HTTP 401/403 authorization rejections and cryptographic key access patterns.
4. **WAF Blocked Threats** (`waf_blocked_attacks.kql`)
   - Aggregates real-time OWASP ModSecurity rule matches (SQLi, XSS, malicious bots) grouped by attacker IP.

---

## 5. Automated Verification Test Suite

Run the monitoring validation test suite:

```bash
# Bash
./scripts/test-monitoring.sh

# PowerShell
powershell -ExecutionPolicy Bypass -File ./scripts/test-monitoring.ps1
```

**Verification Results:**
- 6/6 tests passing (Terraform syntax, retention policies, billing quota, DCR streams, action group channels, KQL runbook integrity).
