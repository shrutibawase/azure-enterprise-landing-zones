# Azure Bastion Host Module

This module provisions an **Azure Bastion** service within the Hub Virtual Network to enforce **Zero-Trust Administrative Access**.

---

## Zero-Trust Architecture

- **No Public IPs on Workloads:** Workload VMs in Spoke VNets do not require public IP addresses.
- **TLS Wire Encryption:** Administrative sessions (RDP/SSH) are brokered directly through the browser over port 443 TLS.
- **Native Tunneling:** Standard SKU supports native CLI tunneling via `az network bastion ssh` / `az network bastion rdp` without exposing management ports to the public internet.
- **Subnet Requirements:** Deployed to a dedicated subnet named `AzureBastionSubnet` with a minimum size of `/26`.
