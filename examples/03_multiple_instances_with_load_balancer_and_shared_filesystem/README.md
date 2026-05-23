# Example 03: Multiple Instances with Load Balancer and Shared File System

This example combines **OCI Compute**, **OCI Load Balancer**, and **OCI File Storage** into one practical architecture:
multiple private backend instances sit behind a public load balancer and mount the same **shared File Storage export**.

It is intentionally modeled after the multiple-instance load balancer pattern, but extends it with a shared NFS layer that all instances consume at runtime.

---

## Architecture Overview

<img src="03_multiple_instances_with_load_balancer_and_shared_filesystem_architecture.png" width="900"/>

This deployment creates:

- one dedicated **VCN**
- one **public subnet** for the load balancer
- one **private subnet** for backend instances
- one separate **private subnet** for the File Storage mount target
- one public OCI **Load Balancer**
- multiple OCI **compute instances**
- one OCI **mount target**
- one OCI **file system**
- one OCI **export** mounted by all backend instances

Traffic and storage flow:

- clients connect to the public OCI Load Balancer on port `80`
- the load balancer forwards HTTP traffic to private backend instances
- every backend instance mounts the same OCI File Storage export
- the demo HTTP page is generated per node, but reads a shared message from the mounted file system

This gives a simple but concrete example of a shared-content or shared-state layer across multiple VMs.

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

To scale the number of backend instances, set `instance_count` to `2` or more, for example:

```hcl
instance_count = 3
```

After a successful deployment, Terraform will output:

- the load balancer public IPs
- the backend instance private IPs
- the File Storage mount target private IP
- the shared export target in `ip:/path` format

---

## OCI Console And Runtime Verification

### Load Balancer

<img src="03_multiple_instances_with_load_balancer_and_shared_filesystem_load_balancer.png" width="900"/>

This view confirms that the public load balancer is deployed and fronting the shared-filesystem application tier.

### Backend Health

<img src="03_multiple_instances_with_load_balancer_and_shared_filesystem_backends_healthy.png" width="900"/>

This view confirms that the backend set sees the compute nodes as healthy on port `80`.

### Compute Instances

<img src="03_multiple_instances_with_load_balancer_and_shared_filesystem_instances.png" width="900"/>

This view confirms that multiple backend instances are running in the application subnet and are available as load balancer targets.

### Mount Target

<img src="03_multiple_instances_with_load_balancer_and_shared_filesystem_mount_target.png" width="900"/>

This view confirms that the File Storage mount target is deployed in the dedicated filestorage subnet and exposes the expected hostname and private IP.

### Shared Export

<img src="03_multiple_instances_with_load_balancer_and_shared_filesystem_export.png" width="900"/>

This view confirms that the `/shared` export exists and is attached to the shared file system used by all backend nodes.

### HTTP Access Via Load Balancer

<img src="03_multiple_instances_with_load_balancer_and_shared_filesystem_check_http_via_lb.png" width="900"/>

This runtime verification confirms that:

- the public load balancer is reachable
- traffic is reaching one of the backend nodes
- the page shows the shared export target mounted from OCI File Storage

---

## What This Example Demonstrates

- how to combine `terraform-oci-fk-compute`, `terraform-oci-fk-loadbalancer`, and `terraform-oci-fk-filestorage`
- how to mount one OCI File Storage export on multiple backend VMs
- how to keep instances private while exposing the service through a public load balancer
- how shared storage can provide common application content across several compute nodes

---

## Runtime Notes

Each instance boots with a cloud-init script that:

- mounts the shared OCI File Storage export under `/srv/fk-shared`
- creates a shared message file if it does not already exist
- writes a node-specific marker into the shared file system
- starts a small HTTP service on port `80`

When you refresh the load balancer URL, you should see responses from different backend hosts while the shared message remains the same across all nodes.

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
