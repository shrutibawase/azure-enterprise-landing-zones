# Disaster Recovery & Cross-Region Failover Runbook

This runbook outlines the operational procedures for initiating, verifying, and recovering from cross-region failover between Azure primary region (`eastus2`) and paired secondary region (`centralus`).

---

## 1. Disaster Recovery Specifications

| Metric | Target SLA | Implementation Mechanism |
|:---|:---:|:---|
| **Recovery Point Objective (RPO)** | 15 Minutes | GRS Storage replication & automated 15-minute transactional sync |
| **Recovery Time Objective (RTO)** | 60 Minutes | Infrastructure as Code (Terraform) automated secondary apply & DNS shift |
| **Data Immutability** | 30 Days | Recovery Services Vault Soft Delete & Multi-User Authorization (MUA) |

---

## 2. Failover Execution Workflow

```
[Primary Region Outage Declared]
               │
               ▼
   1. Confirm Data Replication Status (az storage account show)
               │
               ▼
   2. Initiate Azure Storage GRS Account Failover (az storage account failover)
               │
               ▼
   3. Trigger Terraform Secondary Landing Zone Deployment
      `terraform apply -var="primary_location=centralus"`
               │
               ▼
   4. Update Application Gateway Public DNS CNAME to Secondary Ingress
               │
               ▼
   5. Verify Application Health via `/healthz` Systemd Probes
               │
               ▼
[Traffic Serving in Paired Region]
```
