variable "compartment_ocid" {
  description = "Compartment OCID where the File Storage resources will be created."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain used for the file systems and mount target."
  type        = string
}

variable "name" {
  description = "Base name used for the mount target and default file system display names."
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID where the mount target will be created."
  type        = string
}

variable "defined_tags" {
  description = "Defined tags applied to top-level resources created by the module."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to top-level resources created by the module."
  type        = map(string)
  default     = {}
}

variable "mount_target" {
  description = "Optional mount target settings."
  type = object({
    display_name         = optional(string)
    hostname_label       = optional(string)
    ip_address           = optional(string)
    nsg_ids              = optional(list(string), [])
    requested_throughput = optional(number)
  })
  default = {}
}

variable "file_systems" {
  description = "Map of OCI File Storage file systems to create."
  type = map(object({
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
  default = {}
}

variable "exports" {
  description = "Map of exports to create on the mount target."
  type = map(object({
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
  default = {}

  validation {
    condition = alltrue([
      for export in values(var.exports) : startswith(export.path, "/")
    ])
    error_message = "Each export path must start with '/'."
  }

  validation {
    condition = alltrue([
      for export in values(var.exports) : contains(keys(var.file_systems), export.file_system_key)
    ])
    error_message = "Each export.file_system_key must reference a key from var.file_systems."
  }
}
