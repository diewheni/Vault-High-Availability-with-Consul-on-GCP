{
  "server": true,
  "node_name": "${node_name}",
  "datacenter": "dc1",
  "data_dir": "var/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$adv_addr",
  "bootstrap_expect": 3,
  "retry_join": ["provider=gce project_name='prime-cosmos-239513' tag_value=consul"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}



{
  "server": true,
  "node_name": "consul_s1",
  "datacenter": "dc1",
  "data_dir": "/var/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "10.1.42.101",
  "bootstrap_expect": 3,
  "retry_join": ["10.1.42.101", "10.1.42.102", "10.1.42.103"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}


cat << EOF > test
{
  "server": true,
  "node_name": "consul", 
  "datacenter": "dc1",
  "data_dir": "var/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": `ip addr list eth0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1`,
  "bootstrap_expect": 3,
  "retry_join": ["provider=gce project_name='prime-cosmos-239513' tag_value=consul"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}

EOF




root@instance-1:/var# cat /usr/local/etc/consul/server_agent.json 
{
  "server": true,
  "node_name": "consul", 
  "datacenter": "dc1",
  "data_dir": "var/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "10.164.0.22",
  "bootstrap_expect": 3,
  "retry_join": ["provider=gce project_name='prime-cosmos-239513' tag_value=consul"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false
}



root@instance-1:/var# cat /etc/systemd/system/consul.service 
[Unit]
Description=Consul server agent
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
PIDFile=/var/run/consul/consul.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/consul
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