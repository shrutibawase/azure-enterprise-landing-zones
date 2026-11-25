# Enterprise Multi-Environment Configuration Architecture

This directory contains environment-specific Terraform variable definitions (`.tfvars`) structured for strict stage isolation, compliance segregation, and progressive deployment promotion across the Azure Enterprise Landing Zone.

---

## 🌐 Environment Matrix

| Parameter / Resource | Development (`dev`) | Staging / UAT (`uat`) | Production (`prod`) |
|:---|:---|:---|:---|
| **VNet CIDR Block** | `10.10.0.0/16` | `10.50.0.0/16` | `10.100.0.0/16` |
| **Azure Firewall Subnet** | `10.10.1.0/24` | `10.50.1.0/24` | `10.100.1.0/24` |
| **App Workload Subnet** | `10.10.10.0/24` | `10.50.10.0/24` | `10.100.10.0/24` |
| **Private Endpoint Subnet** | `10.10.20.0/24` | `10.50.20.0/24` | `10.100.20.0/24` |
| **Firewall Next-Hop IP** | `10.10.1.4` | `10.50.1.4` | `10.100.1.4` |
| **Compliance Scope Tag** | `Internal-Testing` | `Staging-PreProd` | `Mission-Critical-PCI-DSS` |
| **State Storage Key** | `dev.terraform.tfstate` | `uat.terraform.tfstate` | `prod.terraform.tfstate` |

---

## 🔒 State Isolation & Promotion Pipeline

1. **State Isolation**:
   Each environment targets a segregated remote state blob (`<env>.terraform.tfstate`) within the Azure Storage Account container `tfstate`. No cross-environment state locking or contamination can occur.

2. **Progressive Promotion**:
   ```
   [Feature Branch / PR]
            │
            ▼
     Static Lint & Tests
            │
            ▼
     Dev Deployment (Auto)
            │
            ▼
     UAT Validation (E2E)
            │
            ▼
   Prod Manual Approval Gate
            │
            ▼
    Prod Deployment (Protected)
   ```

3. **Deploying Locally / via CLI**:
   ```bash
   terraform plan -var-file="environments/dev/terraform.tfvars"
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```
