# Azure Private DNS Zones & Resolution Module

This module manages centralized **Azure Private DNS Zones** and links them across Hub and Spoke Virtual Networks to support **Azure Private Endpoints**.

---

## Architecture Highlights

- **Dynamic Linking:** Uses a flattened cartesian product to link every configured DNS zone to every connected Hub/Spoke VNet automatically.
- **PaaS Integration:** Pre-configured for `privatelink.vaultcore.azure.net` (Key Vault), `privatelink.blob.core.windows.net` (Storage), and `privatelink.database.windows.net` (Azure SQL).
- **Auto-Registration:** Supports optional dynamic DNS registration for VMs in specific spokes.
