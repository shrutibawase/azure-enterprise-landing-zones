# Changelog

All notable changes to the **Azure Enterprise Cloud Landing Zone (CAF Framework)** project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-26

### Added
- **Cross-Region Backup Module (`modules/backup`)**:
  - Central Recovery Services Vault configured with Geo-Redundant Storage (GRS).
  - Cross-Region Restore (CRR) to paired secondary region (`centralus`).
  - Immutable soft delete protection safeguarding backups against ransomware.
  - Daily, weekly (12-week), and monthly (12-month) ISO 27001 compliant retention policies.
- **Disaster Recovery & Failover Architecture (`modules/dr`)**:
  - Region pairing validation and active-passive failover configuration between `eastus2` and `centralus`.
  - Target SLA enforcement for 15-minute RPO and 60-minute RTO.
  - Operational failover playbook and step-by-step paired region migration runbook.
- **Enterprise Compliance Matrix (`docs/compliance-matrix-nist-cis.md`)**:
  - Complete control mapping against NIST SP 800-207 (Zero Trust), CIS Azure Benchmark v2.0, ISO/IEC 27001:2022, and PCI-DSS v4.0.
- **Security Operations & Incident Response Runbook (`docs/incident-response-runbook.md`)**:
  - Severity classification SLA framework (P1 through P4).
  - Production incident triage playbooks for WAF attacks, Key Vault unauthorized access, and compute saturation.
- **Master End-to-End Architectural Test Runner (`scripts/test-e2e.sh`, `scripts/test-e2e.ps1`)**:
  - Unified test suite executing 35+ validation checks across all 7 architectural domains with 100% pass rate.

---

## [0.6.0] - 2026-11-25

### Added
- **Multi-Environment Delivery Pipeline (`.github/workflows/terraform-deploy.yml`)**:
  - Passwordless Microsoft Entra ID OpenID Connect (OIDC) authentication (`azure/login@v2`).
  - Staged environment promotion (`dev` -> `uat` -> `prod`) with manual review gates for production.
- **Environment Isolation Configurations (`environments/`)**:
  - Isolated parameter configurations (`terraform.tfvars`) across `dev`, `uat`, and `prod`.
  - Segregated remote state blob keys (`<env>.terraform.tfstate`) in Azure Storage.
- **Automated Nightly Drift Detection (`.github/workflows/drift-detection.yml`)**:
  - Scheduled daily drift detection at 00:00 UTC running `terraform plan -detailed-exitcode`.
  - Automated GitHub Issue creation and SecOps triage alerting upon state divergence.
- **FinOps Infracost Commenter (`.github/workflows/infracost-commenter.yml`)**:
  - Automated PR cost diff analysis and budget guardrail enforcement.
- **Automated Drift Reconciliation CLI (`scripts/reconcile-drift.sh`, `scripts/reconcile-drift.ps1`)**:
  - Self-healing state synchronization engine with `--auto-apply` and `--refresh-only` capabilities.
- **DRY Terragrunt Architecture (`terragrunt.hcl`, `environments/*/terragrunt.hcl`)**:
  - Dynamic AzureRM provider generation and automated remote backend state generation.

---

## [0.5.0] - 2026-11-24

### Added
- **Central Log Analytics Workspace (`modules/monitoring/workspace.tf`)**:
  - Dedicated workspace with 30-day minimum retention and 10 GB/day FinOps ingestion cap.
- **Workspace-Based Application Insights (`modules/monitoring/app_insights.tf`)**:
  - Distributed tracing and APM directly integrated with the central workspace data plane.
- **Azure Monitor Data Collection Rules (`modules/monitoring/dcr.tf`)**:
  - AMA streaming for Linux Syslog (`auth`, `cron`, `daemon`) and host performance metrics.
- **Metric Alerting & Incident Dispatch (`modules/monitoring/alerts.tf`, `action_group.tf`)**:
  - Sev 1 & Sev 2 metric alerts (Failed requests, latency degradation, VMSS CPU > 85%).
  - Multi-channel notification routing (SecOps email, PagerDuty/ServiceNow webhooks, ARM roles).
- **Production KQL Runbooks (`modules/monitoring/queries/`)**:
  - Pre-compiled queries for VMSS performance trends, Firewall drops, Key Vault audits, and WAF blocks.

---

## [0.4.0] - 2026-11-23

### Added
- **CIS Microsoft Azure Foundations Benchmark v2.0 Initiative (`modules/governance/cis_benchmark.tf`)**:
  - Subscription-wide automated compliance enforcement.
- **Custom Deny Policies (`modules/governance/custom_policies.tf`)**:
  - Mandatory enterprise tag enforcement (`require_tags.json`).
  - Data sovereignty geo-fencing policy (`allowed_locations.json`).
- **Audited Policy Exemptions (`modules/governance/exemptions.tf`)**:
  - Time-bound waiver tracking with expiration timestamps.
- **Static Analysis & Shift-Left DevSecOps**:
  - `.tflint.hcl` with AzureRM ruleset.
  - `.checkov.yml` security baseline suppressions.
  - `infracost.yml` cost anomaly detection baselines.

---

## [0.3.0] - 2026-11-22

### Added
- **Zone-Redundant Application Gateway v2 (`modules/app_gateway`)**:
  - Deployed across Availability Zones 1, 2, 3 with autoscale capacity.
  - WAF Policy in Prevention Mode with OWASP CRS 3.2, Bot Manager, and `/api/*` rate-limiting.
- **Multi-AZ Linux Virtual Machine Scale Set (`modules/compute`)**:
  - Distributed instances across Zones 1, 2, and 3 with Premium ZRS managed disks.
  - Cloud-init provisioning with kernel-level hardening (`sysctl`) and `/healthz` systemd readiness probes.
  - Dynamic CPU autoscaling rules (Scale out at CPU > 75%, Scale in at CPU < 25%).
  - Zero-downtime rolling upgrades (`max_batch_instance_percent = 20`).

---

## [0.2.0] - 2026-11-21

### Added
- **Passwordless Managed Identity (`modules/identity`)**:
  - User-Assigned Managed Identity for compute, storage, and Key Vault authentication.
- **Azure Key Vault HSM & CMK (`modules/security`)**:
  - Premium Key Vault with automated 30-day pre-expiry key rotation.
  - Azure RBAC fine-grained role assignments (`Key Vault Crypto Service Encryption User`).
  - Diagnostic audit settings streaming `AuditEvent` to Log Analytics.
- **Hardened Azure Storage Account (`modules/storage`)**:
  - Customer-Managed Key double infrastructure encryption (AES-256 at host and service layers).
  - Private blob containers, lifecycle management policies, and private endpoints.

---

## [0.1.0] - 2026-11-20

### Added
- **Enterprise Transit Networking (`modules/networking`, `modules/peering`)**:
  - Bidirectional Hub-to-Spoke and Spoke-to-Hub VNet peering with gateway transit.
  - Forced-tunneling route table directing `0.0.0.0/0` outbound traffic to Azure Firewall.
- **Centralized Firewall Inspection (`modules/firewall`)**:
  - Zone-redundant Azure Firewall Standard/Premium with DNS proxy and egress rules.
- **Zero-Trust Administrative Bastion (`modules/bastion`)**:
  - Azure Bastion Standard host for passwordless, browser-based RDP/SSH access.
- **Private DNS Infrastructure (`modules/dns`)**:
  - Central Private DNS Zones dynamically linked to all VNets for private endpoints.
