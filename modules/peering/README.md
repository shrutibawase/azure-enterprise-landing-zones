# Azure Virtual Network Peering Module

This module manages automated, bidirectional VNet peering relationships between Hub and Spoke networks in accordance with the Microsoft Cloud Adoption Framework (CAF).

---

## Features

- **Bi-Directional Configuration:** Automatically configures both Hub-to-Spoke and Spoke-to-Hub peering links in a single declarative block.
- **Gateway Transit Controls:** Configurable flags for `allow_gateway_transit` and `use_remote_gateways` for hybrid ExpressRoute/VPN connectivity.
- **Forwarded Traffic:** Enables `allow_forwarded_traffic` to support centralized NVA / Azure Firewall routing between spokes.
