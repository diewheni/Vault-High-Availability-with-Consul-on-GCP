resource "google_compute_instance" "vault" {

  count = 3
  name = "vault-${count.index}"
  machine_type = "n1-standard-1"
  zone         = var.gcloud-zone
  depends_on = [google_compute_instance.consul]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      type = "pd-ssd"
      size = 10
    }
  }



  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
    }
  }

  allow_stopping_for_update = true

  service_account {
    email  = "${var.service_account}"
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<SCRIPT
    apt-get update -y
    apt-get install -y curl unzip jq libtool libltdl-dev
    wget https://releases.hashicorp.com/consul/1.5.3/consul_1.5.3_linux_amd64.zip
    unzip consul*
    mv consul /usr/local/bin
    rm consul*
    mkdir /usr/local/etc/consul
    useradd consul
    mkdir -p /var/consul/data
    chown -R consul:consul /var/consul/


    curl -s -L -o ~/vault.zip ${var.vault_url}
    unzip ~/vault.zip
    install -c -m 0755 vault /usr/local/bin
    useradd vault
    mkdir -p /usr/local/etc/vault



cat << EOF > /usr/local/etc/consul/client_agent.json
{
  "server": false,
  "datacenter": "us-east1",
  "node_name": "consul-client${count.index}",
  "data_dir": "/var/consul/data",
  "bind_addr": "$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")",
  "client_addr": "127.0.0.1",
  "retry_join": ["provider=gce project_name=${var.gcloud-project} tag_value=consul"],
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}

EOF


    echo -e '
[Unit]
Description=Consul client agent
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
PIDFile=/var/run/consul/consul.pid
PermissionsStartOnly=true
ExecStartPre=/bin/mkdir -p /var/run/consul
ExecStartPre=/bin/chown -R consul:consul /var/run/consul
ExecStart=/usr/local/bin/consul agent \
    -config-file=/usr/local/etc/consul/client_agent.json \
    -pid-file=/var/run/consul/consul.pid
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
        ' > /etc/systemd/system/consul.service

    chmod 0664 /etc/systemd/system/consul.service
    systemctl daemon-reload
    systemctl enable consul
    systemctl start consul
  

cat << EOF > /usr/local/etc/vault/vault_server.hcl
listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google"):8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
}


seal "gcpckms" {
    project     = "${var.gcloud-project}"
    region      = "${var.keyring_location}"
    key_ring    = "${var.key_ring}"
    crypto_key  = "${var.crypto_key}"
}

api_addr = "http://$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google"):8200"
cluster_addr = "https://$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google"):8201"
disable_mlock = true
EOF



cat << EOF > /usr/local/etc/vault/vault.sh
alias v="vault"
alias vault="vault"
export VAULT_ADDR="http://127.0.0.1:8200"
EOF

source /usr/local/etc/vault/vault.sh

cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault secret management tool
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
PIDFile=/var/run/vault/vault.pid
ExecStart=/usr/local/bin/vault server -config=/usr/local/etc/vault/vault_server.hcl -log-level=debug
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s
LimitMEMLOCK=infinity


[Install]
WantedBy=multi-user.target
EOF

chmod 0664 /etc/systemd/system/vault.service
systemctl daemon-reload
systemctl enable vault
systemctl start vault


SCRIPT

}




resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  # key_ring_id = "${google_kms_key_ring.key_ring.id}"
  key_ring_id = "${var.gcloud-project}/${var.keyring_location}/${var.key_ring}"
  role = "roles/owner"

  members = [
    "serviceAccount:${var.service_account}",
  ]
}



