# User-Assigned Managed Identity Module

This module manages enterprise **User-Assigned Managed Identities (UAMI)** adhering to Microsoft Entra ID passwordless best practices.

---

## Architectural Purpose

- **Passwordless Authentication:** Completely eliminates hardcoded client secrets, API tokens, and credentials in application configuration.
- **Granular Least Privilege:** Generates dedicated security principals for discrete responsibilities (Compute Runtime, Storage CMK, Disk Encryption).
- **Audit Traceability:** All token requests via Azure Instance Metadata Service (IMDS) are auditable in Microsoft Entra ID Sign-in logs.
