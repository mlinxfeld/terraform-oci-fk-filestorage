module "vcn" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-vcn.git"

  compartment_ocid = var.compartment_ocid
  name             = "fk-fss-demo-01-vcn"
  vcn_cidr_blocks  = ["10.50.0.0/16"]
  dns_label        = "fkfss01"

  security_lists = {
    filestorage = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "10.50.0.0/16"
          tcp_options = {
            min = 111
            max = 111
          }
        },
        {
          protocol = "6"
          source   = "10.50.0.0/16"
          tcp_options = {
            min = 2048
            max = 2050
          }
        }
      ]
      egress_rules = [
        {
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }

  subnets = {
    private = {
      display_name               = "fk-fss-demo-01-private-subnet"
      cidr_block                 = "10.50.10.0/24"
      dns_label                  = "priv01"
      security_list_keys         = ["filestorage"]
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
  }
}
