module "vcn" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-vcn.git"

  compartment_ocid = var.compartment_ocid
  name             = "fk-fss-demo-02-vcn"
  vcn_cidr_blocks  = ["10.60.0.0/16"]
  dns_label        = "fkfss02"

  create_nat_gateway     = true
  create_service_gateway = true

  route_tables = {
    private = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "nat_gateway"
        },
        {
          destination        = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "service_gateway"
        }
      ]
    }
  }

  security_lists = {
    filestorage = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "10.60.20.0/24"
          tcp_options = {
            min = 111
            max = 111
          }
        },
        {
          protocol = "6"
          source   = "10.60.20.0/24"
          tcp_options = {
            min = 2048
            max = 2050
          }
        },
        {
          protocol = "6"
          source   = "10.60.30.0/24"
          tcp_options = {
            min = 111
            max = 111
          }
        },
        {
          protocol = "6"
          source   = "10.60.30.0/24"
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
    filestorage = {
      display_name               = "fk-fss-demo-02-filestorage-subnet"
      cidr_block                 = "10.60.10.0/24"
      dns_label                  = "fss02"
      route_table_key            = "private"
      security_list_keys         = ["filestorage"]
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
    app_clients = {
      display_name               = "fk-fss-demo-02-app-subnet"
      cidr_block                 = "10.60.20.0/24"
      dns_label                  = "app02"
      route_table_key            = "private"
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
    ops_clients = {
      display_name               = "fk-fss-demo-02-ops-subnet"
      cidr_block                 = "10.60.30.0/24"
      dns_label                  = "ops02"
      route_table_key            = "private"
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
  }
}
