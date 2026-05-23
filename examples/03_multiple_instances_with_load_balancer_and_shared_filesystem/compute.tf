module "compute" {
  count  = var.instance_count
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-compute.git"

  name             = "fk-fss-shared-node-${count.index + 1}"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.vcn.subnet_ids["fk_fss_lb_shared_app_subnet"]

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
      - path: /opt/fk-demo/start-http.sh
        owner: root:root
        permissions: "0755"
        content: |
          #!/bin/bash
          set -euo pipefail

          SHARED_MOUNT="/srv/fk-shared"
          SHARED_TARGET="${module.filestorage.exports["shared"].mount_target}"
          HOSTNAME_VALUE=$(hostname -f 2>/dev/null || hostname)
          PRIVATE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
          TIMESTAMP=$(date -Is)

          mkdir -p "$${SHARED_MOUNT}"
          grep -q "$${SHARED_TARGET} $${SHARED_MOUNT} nfs" /etc/fstab 2>/dev/null || \
            echo "$${SHARED_TARGET} $${SHARED_MOUNT} nfs defaults,_netdev,nofail 0 0" >> /etc/fstab
          mountpoint -q "$${SHARED_MOUNT}" || mount -t nfs "$${SHARED_TARGET}" "$${SHARED_MOUNT}"

          mkdir -p "$${SHARED_MOUNT}/www" "$${SHARED_MOUNT}/nodes"

          if [ ! -f "$${SHARED_MOUNT}/www/shared-message.txt" ]; then
            cat > "$${SHARED_MOUNT}/www/shared-message.txt" <<MSG
          Shared content served from OCI File Storage.
          This file is common to every backend instance.
          MSG
          fi

          cat > "$${SHARED_MOUNT}/nodes/$${HOSTNAME_VALUE}.txt" <<NODE
          hostname=$${HOSTNAME_VALUE}
          private_ip=$${PRIVATE_IP}
          boot_timestamp=$${TIMESTAMP}
          NODE

          SHARED_MESSAGE=$(cat "$${SHARED_MOUNT}/www/shared-message.txt")
          mkdir -p /opt/fk-demo/www
          cat > /opt/fk-demo/www/index.html <<HTML
          <html>
          <head><title>FoggyKitchen OCI Shared FSS Demo</title></head>
          <body>
            <h1>It works</h1>
            <p>Served by: <b>$${HOSTNAME_VALUE}</b></p>
            <p>Private IP: <b>$${PRIVATE_IP}</b></p>
            <p>Generated at: <b>$${TIMESTAMP}</b></p>
            <p>Shared export: <b>$${SHARED_TARGET}</b></p>
            <pre>$${SHARED_MESSAGE}</pre>
          </body>
          </html>
          HTML

          if command -v python3 >/dev/null 2>&1; then
            PYTHON_BIN=$(command -v python3)
          elif [ -x /usr/libexec/platform-python ]; then
            PYTHON_BIN=/usr/libexec/platform-python
          elif command -v python >/dev/null 2>&1; then
            PYTHON_BIN=$(command -v python)
          else
            echo "No Python interpreter available for demo HTTP server" > /var/log/fk-demo-http.log
            exit 1
          fi

          nohup "$${PYTHON_BIN}" -m http.server 80 --directory /opt/fk-demo/www >/var/log/fk-demo-http.log 2>&1 &

    runcmd:
      - [ bash, -lc, "dnf install -y nfs-utils python3 || yum install -y nfs-utils python3 || true" ]
      - [ bash, -lc, "systemctl disable --now firewalld || true" ]
      - [ bash, -lc, "pkill -f 'http.server 80' || true" ]
      - [ bash, -lc, "/opt/fk-demo/start-http.sh" ]
  EOF
  )
}
