module "loadbalancer" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-loadbalancer.git"

  name             = "fk-fss-shared-lb"
  compartment_ocid = var.compartment_ocid
  subnet_ids       = [module.vcn.subnet_ids["fk_fss_lb_shared_lb_subnet"]]

  health_checker = {
    protocol = "HTTP"
    port     = 80
    url_path = "/"
  }

  listener = {
    name     = "http"
    port     = 80
    protocol = "HTTP"
  }

  backends = {
    for index, instance in module.compute :
    "app${index + 1}" => {
      ip_address = instance.instance_private_ip
      port       = 80
    }
  }
}
