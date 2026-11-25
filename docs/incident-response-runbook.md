# Enterprise Security Operations & Incident Response Runbook

This runbook defines the standard operating procedures (SOPs) for triage, containment, eradication, and recovery from critical infrastructure incidents within the Azure Enterprise Landing Zone.

---

## 1. Severity Classification Matrix

| Severity Level | Definition | Response SLA | Notification Channels |
|:---:|:---|:---:|:---|
| **P1 - Critical** | Catastrophic outage, perimeter compromise, Key Vault breach | **15 Minutes** | PagerDuty webhook, SecOps SMS & Email, Executive Escalation |
| **P2 - High** | Degraded performance, single AZ failure, OWASP attack spike | **30 Minutes** | PagerDuty webhook, DevOps & SecOps Email |
| **P3 - Medium** | Non-impacting hardware warning, minor policy non-compliance | **2 Hours** | Jira / ServiceNow Ticket |
| **P4 - Low** | Informational drift alert, scheduled certificate/key rotation | **8 Hours** | Daily Digest / Slack Channel |

---

## 2. Operational Playbooks

### Playbook 1: Application Gateway WAF Attack Mitigation (SQLi / XSS / Bot Flood)
1. **Detection**: Metric alert `alert-appi-failed-requests` or WAF KQL query alerts SecOps.
2. **Investigation**:
   ```kusto
   // Run in Log Analytics Workspace
   AzureDiagnostics
   | where Category == "ApplicationGatewayFirewallLog" and action_s == "Blocked"
   | summarize BlockedCount = count() by clientIp_s, ruleId_s, bin(TimeGenerated, 5m)
   | order by BlockedCount desc
   ```
3. **Containment**:
   - Update `modules/app_gateway/waf_policy.tf` to add temporary IP deny rule.
   - Alternatively, inject NSG block rule via emergency PR.
4. **Recovery**: Verify attack drop and validate genuine client traffic flow.

---

### Playbook 2: Key Vault Unauthorized Access / Secret Compromise
1. **Detection**: Metric alert or KQL runbook `keyvault_audit_events.kql` reports HTTP 401/403 anomalies.
2. **Investigation**:
   ```kusto
   AzureDiagnostics
   | where ResourceType == "VAULTS" and Category == "AuditEvent"
   | where httpStatusCode_d in (401, 403)
   | project TimeGenerated, CallerIPAddress, identity_claim_upn_s, OperationName
   ```
3. **Containment**:
   - Revoke compromised Entra ID service principal role assignments:
     ```bash
     az role assignment delete --assignee "<PRINCIPAL_ID>" --role "Key Vault Crypto Service Encryption User"
     ```
   - Trigger immediate CMK cryptographic key rotation in `modules/security/cmk.tf`.
4. **Recovery**: Rotate dependent workload secrets; audit Key Vault diagnostic logs.

---

### Playbook 3: VMSS Host Compute Failure & Autoscale Saturation
1. **Detection**: `alert-vmss-high-cpu` triggers via Action Group.
2. **Investigation**: Check CPU trend via `vmss_cpu_utilization.kql` and VMSS instance health in Azure Portal.
3. **Remediation**:
   - Manually trigger scale-out burst:
     ```bash
     az vmss scale --resource-group "rg-enterprise-workloads-prod" --name "vmss-app-prod" --new-capacity 6
     ```
   - Re-image unhealthy instances:
     ```bash
     az vmss reimage --resource-group "rg-enterprise-workloads-prod" --name "vmss-app-prod" --instance-id "*"
     ```
4. **Post-Mortem**: Document root cause in Post-Incident Review (PIR) template within 48 hours.
