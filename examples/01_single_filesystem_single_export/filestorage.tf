module "filestorage" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-filestorage.git?ref=v0.1.0"

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  name                = "fk-fss-demo-01"
  subnet_id           = module.vcn.subnet_ids["private"]

  mount_target = {
    hostname_label = "fkfssdemo01"
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
          source          = "10.50.0.0/16"
          access          = "READ_WRITE"
          identity_squash = "NONE"
          allowed_auth    = ["SYS"]
        }
      ]
    }
  }
}
