provider "google" {
  #credentials = file(var.account_file_path)
  project     = var.gcloud-project
  region      = var.gcloud-region
}


resource "google_compute_instance" "consul" {

  count = 3
  name = "consul-${count.index}"
  machine_type = "n1-standard-1"
  zone         = var.gcloud-zone
  tags = ["consul"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      type = "pd-ssd"
    }
  }

  # Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
    }
  }

  allow_stopping_for_update = true

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<SCRIPT
    apt-get update -y
    apt-get install -y curl unzip jq
    wget https://releases.hashicorp.com/consul/1.5.3/consul_1.5.3_linux_amd64.zip
    unzip consul*
    mv consul /usr/local/bin
    rm consul*
    mkdir /usr/local/etc/consul
    useradd consul
    mkdir -p /var/consul/data
    chown -R consul:consul /var/consul/


cat << EOF > /usr/local/etc/consul/server_agent.json
{
  "server": true,
  "node_name": "consul-${count.index}", 
  "datacenter": "dc1",
  "data_dir": "/var/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")",
  "bootstrap_expect": 3,
  "retry_join": ["provider=gce project_name=prime-cosmos-239513 tag_value=consul"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}

EOF


    echo -e '
[Unit]
Description=Consul server agent
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
    -config-file=/usr/local/etc/consul/server_agent.json \
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
  
SCRIPT

}




