module "vcn" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-vcn.git"

  compartment_ocid = var.compartment_ocid
  name             = "fk-fss-lb-shared-vcn"
  vcn_cidr_blocks  = ["10.90.0.0/16"]
  dns_label        = "fkfss03"

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

  route_tables = {
    public = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "internet_gateway"
        }
      ]
    }
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
    lb_public = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "0.0.0.0/0"
          tcp_options = {
            min = 80
            max = 80
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
    app_private = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "10.90.10.0/24"
          tcp_options = {
            min = 80
            max = 80
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
    filestorage = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "10.90.20.0/24"
          tcp_options = {
            min = 111
            max = 111
          }
        },
        {
          protocol = "6"
          source   = "10.90.20.0/24"
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
    fk_fss_lb_shared_lb_subnet = {
      display_name               = "fk-fss-lb-shared-lb-subnet"
      cidr_block                 = "10.90.10.0/24"
      dns_label                  = "pub03"
      route_table_key            = "public"
      security_list_keys         = ["lb_public"]
      prohibit_public_ip_on_vnic = false
    }
    fk_fss_lb_shared_app_subnet = {
      display_name               = "fk-fss-lb-shared-app-subnet"
      cidr_block                 = "10.90.20.0/24"
      dns_label                  = "app03"
      route_table_key            = "private"
      security_list_keys         = ["app_private"]
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
    fk_fss_lb_shared_filestorage_subnet = {
      display_name               = "fk-fss-lb-shared-filestorage-subnet"
      cidr_block                 = "10.90.30.0/24"
      dns_label                  = "fss03"
      route_table_key            = "private"
      security_list_keys         = ["filestorage"]
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
  }
}
