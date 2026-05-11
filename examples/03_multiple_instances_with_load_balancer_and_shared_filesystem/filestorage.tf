module "filestorage" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-filestorage.git?ref=v0.1.0"

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  name                = "fk-fss-lb-shared"
  subnet_id           = module.vcn.subnet_ids["fk_fss_lb_shared_filestorage_subnet"]

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
