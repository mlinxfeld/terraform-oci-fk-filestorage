# terraform-oci-fk-filestorage

This repository contains a reusable **Terraform/OpenTofu module** and progressive examples for deploying **Oracle Cloud Infrastructure (OCI) File Storage** resources as a shared storage layer for compute workloads.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and is designed to work cleanly with reusable infrastructure modules such as **`terraform-oci-fk-vcn`**, **`terraform-oci-fk-compute`**, and **`terraform-oci-fk-loadbalancer`**.

---

## Purpose

The goal of this module is to provide a **clean, composable, and educational reference implementation** for OCI shared storage:

- Focused on OCI-native File Storage primitives
- Suitable for private-subnet shared storage patterns and multi-VM consumption
- Designed for hands-on learning, module composition, and multicloud comparisons

This is **not** a full storage landing zone. It is a **learning-first, architecture-aware module**.

---

## What the module does

The module creates:

- OCI File Storage mount target
- One or more OCI file systems
- Zero or more OCI exports on the mount target

The module intentionally does **not** create:

- Block volumes
- Object Storage buckets
- VCNs or subnets
- NSGs or security lists
- Compute instances
- Backup orchestration outside direct file system attachment

Each of those concerns belongs in its own dedicated module.

---

## Repository Structure

```bash
terraform-oci-fk-filestorage/
├── examples/
│   ├── 01_single_filesystem_single_export/
│   ├── 02_multiple_filesystems_multiple_exports/
│   ├── 03_multiple_instances_with_load_balancer_and_shared_filesystem/
│   └── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── LICENSE
└── README.md
```

All examples are runnable and demonstrate **incremental File Storage patterns**, starting from a minimal single export and progressing to multi-export and compute-integrated shared-filesystem scenarios.

---

## Example Usage

### Single file system with single export

```hcl
module "filestorage" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-filestorage.git?ref=v0.1.0"

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  name                = "fk-fss"
  subnet_id           = var.private_subnet_id

  file_systems = {
    shared = {}
  }

  exports = {
    shared = {
      file_system_key = "shared"
      path            = "/shared"
      export_options = [
        {
          source          = "10.20.0.0/16"
          access          = "READ_WRITE"
          identity_squash = "NONE"
          allowed_auth    = ["SYS"]
        }
      ]
    }
  }
}
```

### Multiple file systems and exports

```hcl
module "filestorage" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-filestorage.git?ref=v0.1.0"

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  name                = "fk-fss"
  subnet_id           = var.private_subnet_id

  mount_target = {
    nsg_ids = [var.fss_nsg_id]
  }

  file_systems = {
    shared = {}
    apps = {
      kms_key_id = var.kms_key_ocid
    }
  }

  exports = {
    shared = {
      file_system_key = "shared"
      path            = "/shared"
      export_options = [
        {
          source          = "10.20.0.0/16"
          access          = "READ_WRITE"
          identity_squash = "NONE"
          allowed_auth    = ["SYS"]
        }
      ]
    }
    apps = {
      file_system_key = "apps"
      path            = "/apps"
      export_options = [
        {
          source          = "10.20.20.0/24"
          access          = "READ_WRITE"
          identity_squash = "ROOT"
        }
      ]
    }
  }
}
```

---

## Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `compartment_ocid` | `string` | yes | OCI compartment OCID where File Storage resources will be created |
| `availability_domain` | `string` | yes | Availability domain used for the mount target and file systems |
| `name` | `string` | yes | Base name used for default display names |
| `subnet_id` | `string` | yes | Subnet OCID where the mount target will be created |
| `defined_tags` | `map(string)` | no | Defined tags applied to top-level resources |
| `freeform_tags` | `map(string)` | no | Freeform tags applied to top-level resources |

### Mount target settings

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `mount_target` | `object` | no | Optional mount target settings such as display name, hostname label, NSGs, private IP, and requested throughput |

### File system settings

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `file_systems` | `map(object)` | no | Map of OCI file systems to create |

### Export settings

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `exports` | `map(object)` | no | Map of exports to create on the mount target |

### `mount_target` object schema

```hcl
mount_target = object({
  display_name         = optional(string)
  hostname_label       = optional(string)
  ip_address           = optional(string)
  nsg_ids              = optional(list(string), [])
  requested_throughput = optional(number)
})
```

### `file_systems` object schema

```hcl
file_systems = map(object({
  display_name                  = optional(string)
  kms_key_id                    = optional(string)
  filesystem_snapshot_policy_id = optional(string)
  are_quota_rules_enabled       = optional(bool)
  source_snapshot_id            = optional(string)
  clone_attach_status           = optional(string)
  detach_clone_trigger          = optional(number)
  defined_tags                  = optional(map(string), {})
  freeform_tags                 = optional(map(string), {})
}))
```

### `exports` object schema

```hcl
exports = map(object({
  file_system_key              = string
  path                         = string
  is_idmap_groups_for_sys_auth = optional(bool)
  export_options = optional(list(object({
    source                         = string
    access                         = optional(string)
    allowed_auth                   = optional(list(string))
    anonymous_gid                  = optional(number)
    anonymous_uid                  = optional(number)
    identity_squash                = optional(string)
    is_anonymous_access_allowed    = optional(bool)
    require_privileged_source_port = optional(bool)
  })), [])
}))
```

---

## Outputs

| Output | Description |
|------|-------------|
| `mount_target_id` | Mount target OCID |
| `mount_target_export_set_id` | Export set OCID associated with the mount target |
| `mount_target_private_ip` | Primary private IP of the mount target |
| `file_system_ids` | Map of file system OCIDs keyed by file system key |
| `export_ids` | Map of export OCIDs keyed by export key |
| `exports` | Computed export metadata including ready-to-use NFS targets in `ip:/path` format |

---

## Examples Overview

| Example | Description |
|-------|-------------|
| `01_single_filesystem_single_export` | Minimal private-subnet File Storage deployment with one mount target, one file system, and one export |
| `02_multiple_filesystems_multiple_exports` | Shared mount target with multiple file systems, multiple exports, and subnet-scoped access |
| `03_multiple_instances_with_load_balancer_and_shared_filesystem` | Full architecture with multiple OCI instances behind a load balancer mounting the same shared export |

See [`examples/`](examples) for details.

---

## Design Notes

This module mirrors the **intent** of the Azure storage module, but not its exact shape.

In OCI:

- `Azure File Share` maps conceptually to `OCI File Storage export`
- the actual resource chain is `mount_target -> export_set -> export -> file_system`
- access control is a combination of:
  - export client options
  - subnet routing
  - NSGs / security lists

That means storage access in OCI is even more explicitly a **networking concern** than in Azure.

---

## Design Philosophy

- Explicit over implicit
- Small modules over monoliths
- Shared storage as infrastructure, not application glue
- Optimized for **learning, reuse, and composition**

This makes the module useful for:

- OCI shared storage foundations
- multi-VM shared filesystem designs
- compute and load balancer integration scenarios
- training material
- architecture workshops
- multicloud comparisons (Azure ↔ OCI)

---

## Object Storage Decision

Recommended direction:

- keep this module focused on **File Storage**
- build `Object Storage` as a separate module, for example `terraform-oci-fk-object-storage`

Reason:

- different service boundary
- different access pattern
- different outputs and examples
- avoids mixing NFS semantics with bucket semantics in one API

---

## Related Modules & Training

- [terraform-oci-fk-vcn](https://github.com/foggykitchen/terraform-oci-fk-vcn)
- [terraform-oci-fk-compute](https://github.com/foggykitchen/terraform-oci-fk-compute)
- [terraform-oci-fk-loadbalancer](https://github.com/foggykitchen/terraform-oci-fk-loadbalancer)
- [terraform-az-fk-storage](https://github.com/mlinxfeld/terraform-az-fk-storage)

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com/courses-2/) - *Cloud. Code. Clarity.*
