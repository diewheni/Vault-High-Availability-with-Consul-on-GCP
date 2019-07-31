apt-get install -y unzip libtool libltdl-dev


wget https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
unzip consul_${consul_version}_linux_amd64.zip && rm !$
install -c --mode 0755 --owner root --group root consul /usr/local/bin

wget https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip
unzip vault_${vault_version}_linux_amd64.zip && rm !$
install -c --mode 0755 --owner root --group root vault /usr/local/bin


for user in vault consul
do
    addgroup --system $user >/dev/null
    useradd \
    --system \
    --shell /bin/false \
    --no-create-home \
    --gid $user \
    $user >/dev/null
done

mkdir -p /usr/local/etc/consul
mkdir -p /usr/local/etc/vault
mkdir -p /var/consul/data
chown -R consul:consul /var/consul/


##############
##  CONSUL  ##
##############



cat << EOF > /usr/local/etc/consul/client.json
{
  "server": false,
  "datacenter": "us-east1",
  "node_name": "$(hostname)",
  "data_dir": "/var/consul/data",
  "bind_addr": "$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")",
  "client_addr": "127.0.0.1",
  "retry_join": ["provider=gce project_name=${project} tag_value=consul"],
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}
EOF


cat << EOF > /etc/systemd/system/consul.service
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
    -config-file=/usr/local/etc/consul/client.json \
    -pid-file=/var/run/consul/consul.pid
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

chmod 0444 /etc/systemd/system/consul.service
systemctl daemon-reload
systemctl enable consul
systemctl start consul
  

#############
##  VAULT  ##
#############


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
    project     = "${project}"
    region      = "${keyring_location}"
    key_ring    = "${key_ring}"
    crypto_key  = "${crypto_key}"
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