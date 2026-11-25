# Enterprise Multi-Environment CI/CD, OIDC & Drift Remediation Guide

This guide establishes the production GitOps deployment lifecycle, passwordless OpenID Connect (OIDC) federated credentials, automated configuration drift detection, and self-healing state reconciliation within the Azure Enterprise Landing Zone.

---

## 1. GitOps Delivery Pipeline Architecture

```
                       [Developer / SRE Git Commit]
                                     │
                                     ▼
                      +-----------------------------+
                      |   Pull Request Automation   |
                      |  - terraform fmt & validate |
                      |  - Checkov & Trivy Scanners |
                      |  - Infracost Diff Commenter |
                      +-----------------------------+
                                     │
                             (Merge to main)
                                     ▼
                      +-----------------------------+
                      |     Dev Stage Deployment    |
                      |  - OIDC Azure Authentication|
                      |  - Remote state: dev.tfstate|
                      |  - Automated Apply          |
                      +-----------------------------+
                                     │
                                     ▼
                      +-----------------------------+
                      |     UAT Staging Promotion   |
                      |  - Concurrency Lock Guard   |
                      |  - Integration Validation   |
                      +-----------------------------+
                                     │
                        (Manual Approval Gate)
                                     ▼
                      +-----------------------------+
                      |     Production Protected    |
                      |  - Strict Concurrency Lock  |
                      |  - Remote state: prod.tfstate|
                      |  - Verified Plan Artifact   |
                      +-----------------------------+
```

---

## 2. Passwordless OIDC Authentication

In compliance with zero-trust security standards, this landing zone eliminates static service principal client secrets. GitHub Actions authenticates directly to Microsoft Entra ID via OpenID Connect (OIDC) federated subject identifiers.

### Required GitHub Secrets
- `AZURE_CLIENT_ID`: Application (client) ID of the Entra ID Managed Identity / Service Principal.
- `AZURE_TENANT_ID`: Directory (tenant) ID of the corporate tenant.
- `AZURE_SUBSCRIPTION_ID`: Target Azure Subscription ID.
- `TF_STATE_RG`: Resource group hosting remote state (`rg-enterprise-tfstate`).
- `TF_STATE_STORAGE_ACCOUNT`: Storage account hosting state containers (`stenterprisetfstate`).

### Federated Credential Subject Filter
```
repo:shrutibawase/azure-enterprise-landing-zones:environment:prod
```

---

## 3. Multi-Environment Promotion Matrix

| Stage | Trigger | Var-File | State Blob Key | Approval Gate |
|:---|:---|:---|:---|:---:|
| **Development (`dev`)** | `push` or `workflow_dispatch` | `environments/dev/terraform.tfvars` | `dev.terraform.tfstate` | Automatic |
| **Staging (`uat`)** | Post-dev verification | `environments/uat/terraform.tfvars` | `uat.terraform.tfstate` | Automated E2E |
| **Production (`prod`)** | Release promotion | `environments/prod/terraform.tfvars` | `prod.terraform.tfstate` | **Manual Review** |

---

## 4. Automated Nightly Drift Detection & Issue Triage

The workflow `.github/workflows/drift-detection.yml` runs daily at **00:00 UTC** via cron:
1. Authenticates securely via OIDC.
2. Executes `terraform plan -detailed-exitcode` against each environment.
3. If an out-of-band change occurred (exit code `2`):
   - Automatically opens a prioritized GitHub Issue (`drift-alert`, `security`).
   - Embeds truncated diffs and directs engineers to the remediation runbook.

---

## 5. Self-Healing Drift Remediation Playbook

To reconcile state divergence between live Azure resources and the version-controlled IaC repository:

### Option A: Dry-Run Assessment
```bash
# Bash
./scripts/reconcile-drift.sh --env prod

# PowerShell
.\scripts\reconcile-drift.ps1 -Environment prod
```

### Option B: Automated Self-Healing (Re-apply Desired State)
```bash
# Bash
./scripts/reconcile-drift.sh --env prod --auto-apply

# PowerShell
.\scripts\reconcile-drift.ps1 -Environment prod -AutoApply
```

### Option C: State Refresh Only (Incorporate Out-of-Band State)
```bash
# Bash
./scripts/reconcile-drift.sh --env prod --refresh-only

# PowerShell
.\scripts\reconcile-drift.ps1 -Environment prod -RefreshOnly
```

---

## 6. FinOps Cost Guardrails

The `.github/workflows/infracost-commenter.yml` action compares the pull request against `main`:
- Generates visual line-item cost deltas.
- Flags unexpected monthly billing increases.
- Enforces cloud cost transparency before pull request merging.

---

## 7. Automated Test Suite Verification

Run the pipeline and environment validation suite locally:

```bash
# Bash
./scripts/test-pipeline.sh

# PowerShell
powershell -ExecutionPolicy Bypass -File ./scripts/test-pipeline.ps1
```

**Verification Invariants:**
- All 5 automated pipeline tests passing (OIDC permissions, multi-stage tfvars, Terragrunt DRY blocks, self-healing script flags, core Terraform syntax).
