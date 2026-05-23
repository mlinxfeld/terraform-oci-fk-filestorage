# Example 02: Multiple File Systems and Multiple Exports

This example extends the basic setup into a more realistic shared-storage layout:
one mount target serving **multiple file systems** and **multiple exports**, each with its own path and client access scope.

The goal is to show how the module behaves when File Storage becomes a shared service for different workload segments inside the same VCN.

---

## Architecture Overview

<img src="02_multiple_filesystems_multiple_exports_architecture.png" width="900"/>

This deployment creates:

- one dedicated **VCN**
- one **private subnet** for the mount target
- two additional client subnets with dedicated consumer instances
- one OCI **File Storage mount target**
- two OCI **file systems**
- two OCI **exports** with different paths and export rules
- one **app client** instance mounting `/shared`
- one **ops client** instance mounting `/apps`

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
- the private IPs of the app and ops consumer instances

---

## OCI Console And Runtime Verification

### Mount Target

<img src="02_multiple_filesystems_multiple_exports_mount_target.png" width="900"/>

This view confirms that the shared mount target is deployed in the dedicated File Storage subnet and is ready to publish multiple exports.

### File Systems

<img src="02_multiple_filesystems_multiple_exports_file_systems.png" width="900"/>

This view confirms that the example created two separate OCI File Storage file systems: one for the shared export and one for the apps export.

### Export `/shared`

<img src="02_multiple_filesystems_multiple_exports_export1.png" width="900"/>

This view confirms that the `/shared` export exists and is scoped for the client subnet modeled by the app consumer instance.

### Export `/apps`

<img src="02_multiple_filesystems_multiple_exports_export2.png" width="900"/>

This view confirms that the `/apps` export exists and is scoped for the client subnet modeled by the ops consumer instance.

---

## What This Example Demonstrates

- how to create multiple file systems with one module invocation
- how to publish multiple exports from a shared mount target
- how to scope export access to different client subnets
- how to attach real compute consumers to different exports with `terraform-oci-fk-compute`

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

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
