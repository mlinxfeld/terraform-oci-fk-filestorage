module "app_client" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-compute.git"

  name             = "fk-fss-demo-02-app-client"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.vcn.subnet_ids["app_clients"]

  deployment_mode          = "instance"
  shape                    = "VM.Standard.E4.Flex"
  operating_system_version = "9"
  shape_config = {
    ocpus         = 1
    memory_in_gbs = 8
  }

  user_data = base64encode(<<-EOF
    #cloud-config
    write_files:
      - path: /opt/fk-demo/mount-export.sh
        owner: root:root
        permissions: "0755"
        content: |
          #!/bin/bash
          set -euo pipefail

          EXPORT_TARGET="${module.filestorage.exports["shared"].mount_target}"
          MOUNT_POINT="/srv/fk-shared"
          CLIENT_ROLE="app-client"
          HOSTNAME_VALUE=$(hostname -f 2>/dev/null || hostname)
          PRIVATE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
          TIMESTAMP=$(date -Is)

          mkdir -p "$${MOUNT_POINT}"
          grep -q "$${EXPORT_TARGET} $${MOUNT_POINT} nfs" /etc/fstab 2>/dev/null || \
            echo "$${EXPORT_TARGET} $${MOUNT_POINT} nfs defaults,_netdev,nofail 0 0" >> /etc/fstab
          mountpoint -q "$${MOUNT_POINT}" || mount -t nfs "$${EXPORT_TARGET}" "$${MOUNT_POINT}"

          mkdir -p "$${MOUNT_POINT}/clients"
          cat > "$${MOUNT_POINT}/clients/$${HOSTNAME_VALUE}.txt" <<INFO
          role=$${CLIENT_ROLE}
          hostname=$${HOSTNAME_VALUE}
          private_ip=$${PRIVATE_IP}
          mounted_export=$${EXPORT_TARGET}
          mounted_at=$${TIMESTAMP}
          INFO
    runcmd:
      - [ bash, -lc, "dnf install -y nfs-utils || yum install -y nfs-utils || true" ]
      - [ bash, -lc, "/opt/fk-demo/mount-export.sh" ]
  EOF
  )
}

module "ops_client" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-compute.git"

  name             = "fk-fss-demo-02-ops-client"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.vcn.subnet_ids["ops_clients"]

  deployment_mode          = "instance"
  shape                    = "VM.Standard.E4.Flex"
  operating_system_version = "9"
  shape_config = {
    ocpus         = 1
    memory_in_gbs = 8
  }

  user_data = base64encode(<<-EOF
    #cloud-config
    write_files:
      - path: /opt/fk-demo/mount-export.sh
        owner: root:root
        permissions: "0755"
        content: |
          #!/bin/bash
          set -euo pipefail

          EXPORT_TARGET="${module.filestorage.exports["apps"].mount_target}"
          MOUNT_POINT="/srv/fk-apps"
          CLIENT_ROLE="ops-client"
          HOSTNAME_VALUE=$(hostname -f 2>/dev/null || hostname)
          PRIVATE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
          TIMESTAMP=$(date -Is)

          mkdir -p "$${MOUNT_POINT}"
          grep -q "$${EXPORT_TARGET} $${MOUNT_POINT} nfs" /etc/fstab 2>/dev/null || \
            echo "$${EXPORT_TARGET} $${MOUNT_POINT} nfs defaults,_netdev,nofail 0 0" >> /etc/fstab
          mountpoint -q "$${MOUNT_POINT}" || mount -t nfs "$${EXPORT_TARGET}" "$${MOUNT_POINT}"

          mkdir -p "$${MOUNT_POINT}/clients"
          cat > "$${MOUNT_POINT}/clients/$${HOSTNAME_VALUE}.txt" <<INFO
          role=$${CLIENT_ROLE}
          hostname=$${HOSTNAME_VALUE}
          private_ip=$${PRIVATE_IP}
          mounted_export=$${EXPORT_TARGET}
          mounted_at=$${TIMESTAMP}
          INFO
    runcmd:
      - [ bash, -lc, "dnf install -y nfs-utils || yum install -y nfs-utils || true" ]
      - [ bash, -lc, "/opt/fk-demo/mount-export.sh" ]
  EOF
  )
}
