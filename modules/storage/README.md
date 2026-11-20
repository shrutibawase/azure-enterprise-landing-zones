# Enterprise Storage Account Module

This module deploys a fully hardened **Azure Storage Account (StorageV2)** compliant with **CIS Microsoft Azure Foundations Benchmark v2.0**.

---

## Security Invariants

- **Double Encryption (Infrastructure Encryption):** Enabled at the hardware/host level in addition to service-side encryption.
- **Customer-Managed Keys (CMK):** Seamlessly integrates with Azure Key Vault HSM keys via User-Assigned Managed Identity.
- **Zero Public Access:** `public_network_access_enabled = false` and `allow_nested_items_to_be_public = false`.
- **Soft-Delete & Versioning:** 30-day container & blob soft delete retention with continuous point-in-time change feed.
- **Modern TLS:** Strict `TLS1_2` minimum version enforcement and HTTPS-only transport.
