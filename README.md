# terraform-oci-fk-filestorage

This repository contains a reusable **Terraform/OpenTofu module** for deploying **Oracle Cloud Infrastructure (OCI) File Storage** as a dedicated shared storage layer for compute workloads.

It is designed as an OCI-native counterpart to `terraform-az-fk-storage`, but adapted to the OCI service model:

- **Azure** groups blobs and file shares under a Storage Account
- **OCI** separates **File Storage**, **Object Storage**, and **Block Volumes** into distinct services

Because of that, this module focuses on **File Storage only**:

- `oci_file_storage_mount_target`
- `oci_file_storage_file_system`
- `oci_file_storage_export`

`Block Volumes` should live in `terraform-oci-fk-disk`.

`Object Storage` is intentionally **not included** in this first version, because it has a different lifecycle, API surface, access model, and networking pattern than NFS-based File Storage.

## Purpose

The goal of this module is to provide a **clean, composable, and educational reference implementation** for OCI shared storage:

- focused on OCI File Storage primitives
- designed for VM and private subnet consumption
- suitable for multicloud comparison with the Azure storage module

This is **not** an umbrella module for every OCI storage service.

## What the module does

The module creates:

- one OCI File Storage mount target
- one or more file systems
- zero or more exports on that mount target

The module intentionally does **not** create:

- block volumes
- object storage buckets
- VCNs or subnets
- NSGs or security lists
- compute instances
- backup policies outside direct file system attachment

Each of those concerns belongs in its own dedicated module.

## Repository Structure

```bash
terraform-oci-fk-filestorage/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

## Example Usage

```hcl
module "storage" {
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
          source            = "10.20.0.0/16"
          access            = "READ_WRITE"
          identity_squash   = "NONE"
          allowed_auth      = ["SYS"]
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

## Key Inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `compartment_ocid` | `string` | yes | OCI compartment OCID |
| `availability_domain` | `string` | yes | AD for mount target and file systems |
| `name` | `string` | yes | Base display name |
| `subnet_id` | `string` | yes | Subnet for the mount target |
| `mount_target` | `object` | no | Optional mount target settings |
| `file_systems` | `map(object)` | no | File systems to create |
| `exports` | `map(object)` | no | Exports to create |

## Outputs

| Output | Description |
|------|-------------|
| `mount_target_id` | Mount target OCID |
| `mount_target_export_set_id` | Export set OCID |
| `mount_target_private_ip` | Mount target primary private IP |
| `file_system_ids` | Map of file system OCIDs |
| `export_ids` | Map of export OCIDs |
| `exports` | Export metadata with ready NFS target (`ip:/path`) |

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

## Object Storage Decision

Recommended direction:

- keep this module focused on **File Storage**
- build `Object Storage` as a separate module, for example `terraform-oci-fk-object-storage`

Reason:

- different service boundary
- different access pattern
- different outputs and examples
- avoids mixing NFS semantics with bucket semantics in one API
