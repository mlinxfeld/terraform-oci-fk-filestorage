locals {
  mount_target_display_name = try(var.mount_target.display_name, null) != null ? var.mount_target.display_name : "${var.name}-mt"
}

resource "oci_file_storage_mount_target" "this" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  subnet_id           = var.subnet_id
  display_name        = local.mount_target_display_name

  hostname_label       = try(var.mount_target.hostname_label, null)
  ip_address           = try(var.mount_target.ip_address, null)
  nsg_ids              = try(var.mount_target.nsg_ids, [])
  requested_throughput = try(var.mount_target.requested_throughput, null)

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_file_storage_file_system" "this" {
  for_each = var.file_systems

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = coalesce(try(each.value.display_name, null), "${var.name}-${each.key}")

  kms_key_id                    = try(each.value.kms_key_id, null)
  filesystem_snapshot_policy_id = try(each.value.filesystem_snapshot_policy_id, null)
  are_quota_rules_enabled       = try(each.value.are_quota_rules_enabled, null)
  source_snapshot_id            = try(each.value.source_snapshot_id, null)
  clone_attach_status           = try(each.value.clone_attach_status, null)
  detach_clone_trigger          = try(each.value.detach_clone_trigger, null)

  defined_tags  = merge(var.defined_tags, try(each.value.defined_tags, {}))
  freeform_tags = merge(var.freeform_tags, try(each.value.freeform_tags, {}))
}

resource "oci_file_storage_export" "this" {
  for_each = var.exports

  export_set_id  = oci_file_storage_mount_target.this.export_set_id
  file_system_id = oci_file_storage_file_system.this[each.value.file_system_key].id
  path           = each.value.path

  is_idmap_groups_for_sys_auth = try(each.value.is_idmap_groups_for_sys_auth, null)

  dynamic "export_options" {
    for_each = try(each.value.export_options, [])
    content {
      source                         = export_options.value.source
      access                         = try(export_options.value.access, null)
      allowed_auth                   = try(export_options.value.allowed_auth, null)
      anonymous_gid                  = try(export_options.value.anonymous_gid, null)
      anonymous_uid                  = try(export_options.value.anonymous_uid, null)
      identity_squash                = try(export_options.value.identity_squash, null)
      is_anonymous_access_allowed    = try(export_options.value.is_anonymous_access_allowed, null)
      require_privileged_source_port = try(export_options.value.require_privileged_source_port, null)
    }
  }
}

data "oci_core_private_ip" "mount_target_primary" {
  count = length(oci_file_storage_mount_target.this.private_ip_ids) > 0 ? 1 : 0

  private_ip_id = oci_file_storage_mount_target.this.private_ip_ids[0]
}
