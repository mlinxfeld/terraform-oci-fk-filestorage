module "filestorage" {
  source = "../.."

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  name                = "fk-fss-lb-shared"
  subnet_id           = module.vcn.subnet_ids["private_filestorage"]

  mount_target = {
    hostname_label = "fkfsslbshared"
  }

  file_systems = {
    shared = {}
  }

  exports = {
    shared = {
      file_system_key = "shared"
      path            = "/shared"
      export_options = [
        {
          source          = "10.90.20.0/24"
          access          = "READ_WRITE"
          identity_squash = "NONE"
          allowed_auth    = ["SYS"]
        }
      ]
    }
  }
}
