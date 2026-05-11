output "load_balancer_id" {
  value = module.loadbalancer.load_balancer_id
}

output "load_balancer_public_ips" {
  value = module.loadbalancer.load_balancer_public_ips
}

output "instance_private_ips" {
  value = [for instance in module.compute : instance.instance_private_ip]
}

output "mount_target_private_ip" {
  value = module.filestorage.mount_target_private_ip
}

output "shared_export_target" {
  value = module.filestorage.exports["shared"].mount_target
}

output "vcn_id" {
  value = module.vcn.vcn_id
}
