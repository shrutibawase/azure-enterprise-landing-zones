# Central Observability & Monitoring Module

This module manages the centralized **Azure Monitor** and **Log Analytics Workspace** infrastructure for all enterprise landing zones.

---

## Architectural Highlights

- **Centralized Log Aggregation:** Ingests telemetry, audit logs, and performance counters from Hub and Spoke VNets, Key Vaults, and VMSS compute instances.
- **Cost Protection (FinOps):** Enforces a daily ingestion cap (`daily_quota_gb = 10`) to safeguard against cost anomalies from runaway logging loops.
- **Retention Policies:** Configurable 30-day retention baseline complying with CIS Microsoft Azure Foundations Benchmark.
