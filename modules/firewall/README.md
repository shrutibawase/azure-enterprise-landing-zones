# Azure Firewall & Central Policy Module

This module provisions an enterprise **Azure Firewall** deployed across Availability Zones (1, 2, 3) with an attached **Azure Firewall Policy** and hierarchical rule collection groups.

---

## Capabilities

- **Zone Redundancy:** Deploys across Availability Zones (1, 2, 3) with a zone-redundant Public IP.
- **Application Rule Collections:** Restricts egress HTTPS/HTTP traffic to approved FQDNs (`*.azure.com`, `ghcr.io`, `*.ubuntu.com`).
- **Network Rule Collections:** Regulates transport layer protocols (DNS 53, NTP 123).
- **DNS Proxy:** Built-in DNS proxy enabling centralized resolution across Spoke VNets.
- **Next-Hop Address Export:** Exports `firewall_private_ip` for user-defined route (UDR) tables.
