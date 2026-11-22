# Azure Application Gateway v2 (WAF_v2) Module

This module provisions an enterprise-grade **Application Gateway v2** deployed with the **WAF_v2** SKU across Availability Zones (1, 2, 3).

---

## Architectural Features

- **Zone Redundancy:** Dispersed across Azure Availability Zones `["1", "2", "3"]` for 99.99% high-availability SLA.
- **Autoscaling:** Dynamic autoscaling from min 2 to max 10 capacity units, handling traffic bursts without manual intervention.
- **Microservice Health Probing:** Custom health probe validating backend application readiness via `/healthz` on status codes `200-399`.
- **Zero-Downtime VMSS Integration:** Exports `backend_address_pool_id` for direct binding to VM Scale Set network interface configurations.
