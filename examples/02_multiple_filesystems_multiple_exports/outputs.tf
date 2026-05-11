output "vcn_id" {
  value = module.vcn.vcn_id
}

output "subnet_ids" {
  value = module.vcn.subnet_ids
}

output "mount_target_private_ip" {
  value = module.filestorage.mount_target_private_ip
}

output "file_system_ids" {
  value = module.filestorage.file_system_ids
}

output "exports" {
  value = module.filestorage.exports
}
