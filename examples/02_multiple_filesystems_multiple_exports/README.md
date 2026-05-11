# Example 02: Multiple File Systems and Multiple Exports

This example extends the basic setup into a more realistic shared-storage layout:
one mount target serving **multiple file systems** and **multiple exports**, each with its own path and client access scope.

The goal is to show how the module behaves when File Storage becomes a shared service for different workload segments inside the same VCN.

---

## Architecture Overview

This deployment creates:

- one dedicated **VCN**
- one **private subnet** for the mount target
- two additional client subnets used to model separate workload groups
- one OCI **File Storage mount target**
- two OCI **file systems**
- two OCI **exports** with different paths and export rules

This is a good reference pattern when you want a single mount target but need more than one logical NFS share and clearer segmentation between consumers.

---

## Deployment Steps

Initialize and apply the Terraform/OpenTofu configuration:

```bash
tofu init
tofu plan
tofu apply
```

If you prefer Terraform:

```bash
terraform init
terraform plan
terraform apply
```

After a successful deployment, Terraform will output:

- the mount target private IP
- the file system IDs
- each export in `ip:/path` format
- the subnet IDs used by the example

---

## What This Example Demonstrates

- how to create multiple file systems with one module invocation
- how to publish multiple exports from a shared mount target
- how to scope export access to different client subnets
- how to keep the storage layer separate from compute while still modeling real consumers

---

## Cleanup

To remove all resources created by this example:

```bash
tofu destroy
```

Or with Terraform:

```bash
terraform destroy
```

---

## Learn More

Visit [FoggyKitchen.com](https://foggykitchen.com/) for OCI, multicloud, and Terraform/OpenTofu learning resources.

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../../LICENSE) for more details.
