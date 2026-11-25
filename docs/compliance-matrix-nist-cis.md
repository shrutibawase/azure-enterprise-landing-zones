# Enterprise Compliance & Zero-Trust Control Matrix

This document maps the architectural controls implemented across the Azure Enterprise Landing Zone against international compliance standards:
- **NIST Special Publication 800-207** (Zero Trust Architecture)
- **CIS Microsoft Azure Foundations Benchmark v2.0**
- **ISO/IEC 27001:2022** (Information Security Management)
- **PCI-DSS v4.0** (Payment Card Industry Data Security Standard)

---

## 1. Compliance Control Mapping

| Standard & Section | Control Requirement | Landing Zone Implementation | Validating Component / Test |
|:---|:---|:---|:---|
| **NIST SP 800-207 §3.1** | Continuous verification of all resource access requests | Private Endpoints, strict RBAC, no public IPs on workloads | `modules/security/rbac.tf`, `scripts/test-security.sh` |
| **NIST SP 800-207 §3.2** | All communication is secured regardless of network location | TLS 1.2+ mandatory, forced tunneling `0.0.0.0/0` via Azure Firewall | `modules/firewall/`, `scripts/test-terraform.sh` |
| **CIS Azure v2.0 §1.1** | Multi-factor authentication & passwordless identities | User-Assigned Managed Identity, zero static credentials | `modules/identity/`, `scripts/test-security.sh` |
| **CIS Azure v2.0 §3.1** | Storage accounts require secure transfer & private access | `https_traffic_only_enabled = true`, CMK double encryption | `modules/storage/`, `scripts/test-security.sh` |
| **CIS Azure v2.0 §5.1** | Centralized diagnostic logging for all services | Diagnostic settings routed to central Log Analytics Workspace | `modules/monitoring/`, `scripts/test-monitoring.sh` |
| **CIS Azure v2.0 §6.1** | Restrict perimeter network access | NSG default deny (`priority = 4096`), WAF OWASP 3.2 in Prevention | `modules/app_gateway/`, `scripts/test-compute.sh` |
| **ISO 27001:2022 A.8.24** | Use of cryptography & key lifecycle management | Key Vault HSM RSA 4096-bit CMK with automated rotation | `modules/security/cmk.tf`, `scripts/test-security.sh` |
| **ISO 27001:2022 A.8.14** | Redundancy of information processing facilities | Multi-AZ VMSS (Zones 1, 2, 3), GRS Recovery Services Vault | `modules/compute/`, `modules/backup/` |
| **PCI-DSS v4.0 Req 1.2** | Network security controls restrict connections | Hub-Spoke VNet peering with Azure Firewall next-hop routing | `modules/peering/`, `modules/firewall/` |
| **PCI-DSS v4.0 Req 10.2** | Audit logs record all administrative actions | Syslog & host metrics via AMA DCR (`auth`, `cron`, `daemon`) | `modules/monitoring/dcr.tf`, `test-monitoring.sh` |

---

## 2. Shift-Left Continuous Assurance

Compliance verification is automated across every phase of the delivery lifecycle:

```
[Developer Git Commit]
          │
          ▼
   1. Static Code Analysis (TFLint, terraform fmt)
          │
          ▼
   2. Policy-as-Code Evaluation (Checkov CIS Benchmark v2.0)
          │
          ▼
   3. Architectural Invariant Suites (test-terraform, test-security, test-compute, test-monitoring, test-pipeline)
          │
          ▼
   4. Azure Policy Guardrails (Subscription CIS Initiative & Custom Deny Defs)
          │
          ▼
[Continuous 100% Compliance Maintained]
```
