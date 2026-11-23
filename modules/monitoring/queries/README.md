# Enterprise KQL Query Runbooks

This directory contains production-ready Kusto Query Language (KQL) runbooks for operational telemetry analysis, threat intelligence, and compliance auditing in the Azure Enterprise Landing Zone.

---

## Runbook Catalog

| Query File | Log Table / Source | Purpose | Severity / Action |
|:---|:---|:---|:---|
| [`vmss_cpu_utilization.kql`](./vmss_cpu_utilization.kql) | `InsightsMetrics` | Evaluates average, P95, and maximum CPU across VMSS instances in 5m windows | Capacity planning & autoscale threshold tuning |
| [`firewall_dropped_traffic.kql`](./firewall_dropped_traffic.kql) | `AzureDiagnostics` (`AzureFirewall*`) | Aggregates denied packets by source, destination, protocol, and port | SecOps perimeter threat triage |
| [`keyvault_audit_events.kql`](./keyvault_audit_events.kql) | `AzureDiagnostics` (`AuditEvent`) | Detects HTTP 401/403 authorization failures and unusual key/secret access | Security & compliance audit (ISO 27001 / CIS 8.1) |
| [`waf_blocked_attacks.kql`](./waf_blocked_attacks.kql) | `AzureDiagnostics` (`ApplicationGatewayFirewallLog`) | Identifies blocked OWASP CRS attacks (SQLi, XSS, RCE, Bad Bots) | Real-time application security incident response |

---

## Executing in Azure Portal / Azure CLI

To run any query against the central Log Analytics Workspace using Azure CLI:

```bash
az monitor log-analytics query \
  --workspace-id "<CUSTOMER_WORKSPACE_ID>" \
  --analytics-query "$(cat modules/monitoring/queries/waf_blocked_attacks.kql)" \
  --timespan P1D
```
