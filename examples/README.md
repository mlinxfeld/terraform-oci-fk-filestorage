# OCI File Storage with Terraform/OpenTofu - Training Examples

This directory contains runnable examples for the **terraform-oci-fk-filestorage** module.
The examples focus on practical OCI File Storage deployment patterns, starting with a single export and then expanding to multiple file systems and exports on one mount target.

These examples are part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and are designed to show how OCI File Storage fits into private networking and shared-storage patterns.

---

## Published Examples

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Single File System with Single Export** | basic mount target, private subnet, one file system, one export |
| 02 | **Multiple File Systems and Multiple Exports** | shared mount target, multiple file systems, export segmentation, subnet-specific access |
| 03 | **Multiple Instances with Load Balancer and Shared File System** | compute plus LB plus File Storage, shared NFS export, multi-VM mount pattern |

---

## How to Use

To run the single export example:

```bash
cd examples/01_single_filesystem_single_export
tofu init
tofu plan
tofu apply
```

To run the multi-export example:

```bash
cd examples/02_multiple_filesystems_multiple_exports
tofu init
tofu plan
tofu apply
```

To run the shared-filesystem architecture example:

```bash
cd examples/03_multiple_instances_with_load_balancer_and_shared_filesystem
tofu init
tofu plan
tofu apply
```

If you prefer Terraform, replace `tofu` with `terraform`.

---

## Design Principles

- One example = one storage architecture goal
- Networking is explicit, because OCI File Storage access is a subnet and policy concern
- Examples stay focused on File Storage and use `terraform-oci-fk-vcn` only for the surrounding network
- Each example is runnable without requiring compute instances in the same stack

---

## Related Resources

- [FoggyKitchen OCI File Storage Module (terraform-oci-fk-filestorage)](../)
- [FoggyKitchen OCI VCN Module (terraform-oci-fk-vcn)](https://github.com/mlinxfeld/terraform-oci-fk-vcn)
- [FoggyKitchen OCI Compute Module (terraform-oci-fk-compute)](https://github.com/mlinxfeld/terraform-oci-fk-compute)
- [FoggyKitchen Azure Storage Module (terraform-az-fk-storage)](https://github.com/mlinxfeld/terraform-az-fk-storage)

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.

---

© 2026 FoggyKitchen.com - Cloud. Code. Clarity.
