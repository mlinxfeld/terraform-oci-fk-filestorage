module "filestorage" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-filestorage.git?ref=v0.1.0"

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  name                = "fk-fss-demo-02"
  subnet_id           = module.vcn.subnet_ids["filestorage"]

  mount_target = {
    hostname_label = "fkfssdemo02"
  }

  file_systems = {
    shared = {}
    apps   = {}
  }

  exports = {
    shared = {
      file_system_key = "shared"
      path            = "/shared"
      export_options = [
        {
          source          = "10.60.20.0/24"
          access          = "READ_WRITE"
          identity_squash = "NONE"
          allowed_auth    = ["SYS"]
        }
      ]
    }
    apps = {
      file_system_key = "apps"
      path            = "/apps"
      export_options = [
        {
          source          = "10.60.30.0/24"
          access          = "READ_ONLY"
          identity_squash = "ROOT"
        }
      ]
    }
  }
}
