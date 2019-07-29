apt install -y unzip
wget https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
unzip consul_${consul_version}_linux_amd64.zip
rm consul_${consul_version}_linux_amd64.zip
mv consul /usr/local/bin


useradd consul
mkdir -p /usr/local/etc/consul
mkdir -p /var/consul/data
chown -R consul:consul /var/consul/



#####################
##  CONSUL CONFIG   ##
#####################

cat << EOF > /usr/local/etc/consul/config.json
{
  "server": true,
  "node_name": "$(hostname)", 
  "datacenter": "us-east1",
  "data_dir": "/var/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")",
  "bootstrap_expect": 2,
  "retry_join": ["provider=gce project_name=${gcloud-project} tag_value=consul"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}

EOF


###############
##  SYSTEMD   ##
###############

cat << EOF > /etc/systemd/system/consul.service
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
    -config-file=/usr/local/etc/consul/config.json \
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
chmod 0444 /usr/local/etc/consul/config.json
systemctl daemon-reload
systemctl enable consul
systemctl start consul
  