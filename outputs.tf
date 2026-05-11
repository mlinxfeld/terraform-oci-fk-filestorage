output "mount_target_id" {
  description = "Mount target OCID."
  value       = oci_file_storage_mount_target.this.id
}

output "mount_target_export_set_id" {
  description = "Export set OCID associated with the mount target."
  value       = oci_file_storage_mount_target.this.export_set_id
}

output "mount_target_private_ip" {
  description = "Primary private IP of the mount target, useful for NFS mount commands."
  value       = try(data.oci_core_private_ip.mount_target_primary.ip_address, null)
}

output "file_system_ids" {
  description = "Map of file system OCIDs keyed by file_systems map key."
  value       = { for key, fs in oci_file_storage_file_system.this : key => fs.id }
}

output "export_ids" {
  description = "Map of export OCIDs keyed by exports map key."
  value       = { for key, export in oci_file_storage_export.this : key => export.id }
}

output "exports" {
  description = "Computed export details including mount target IP and ready-to-use NFS target."
  value = {
    for key, export in oci_file_storage_export.this : key => {
      export_id       = export.id
      file_system_id  = export.file_system_id
      path            = export.path
      mount_target_ip = try(data.oci_core_private_ip.mount_target_primary.ip_address, null)
      mount_target    = try(data.oci_core_private_ip.mount_target_primary.ip_address, null) != null ? format("%s:%s", data.oci_core_private_ip.mount_target_primary.ip_address, export.path) : null
    }
  }
}
