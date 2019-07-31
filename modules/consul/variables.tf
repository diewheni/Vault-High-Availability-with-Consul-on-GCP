variable "region" {}
variable "network" {}
variable "subnetwork" {}
variable "project" {}


variable "target_size" {
  default = 3
}
variable "machine_type" {
  default = "n1-standard-1"
}
variable "source_image" {
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}
variable "boot_auto_delete" {
  type    = bool
  default = true
}
variable "disk_type" {
  default = "pd-ssd"
}
variable "disk_size_gb" {
  default = 10
}

variable "automatic_restart" {
  type    = bool
  default = true
}
variable "on_host_maintenance" {
  default = "MIGRATE"
}
variable "consul_version" {
  default = "1.5.3"
}

variable "depends" { 
    default = []
    type = list
}

variable "cluster_tag_name" {
  description = "The tag name the Compute Instances will look for to automatically discover each other and form a cluster. TIP: If running more than one Consul Server cluster, each cluster should have its own unique tag name."
  type        = string
  default = "consul"
}

variable "custom_tags" {
  description = "A list of tags that will be added to the Compute Instance Template in addition to the tags automatically added by this module."
  type        = list(string)
  default     = []
}

variable "server_rpc_port" {
  description = "The port used by servers to handle incoming requests from other agents."
  type        = number
  default     = 8300
}

variable "cli_rpc_port" {
  description = "The port used by all agents to handle RPC from the CLI."
  type        = number
  default     = 8400
}

variable "serf_lan_port" {
  description = "The port used to handle gossip in the LAN. Required by all agents."
  type        = number
  default     = 8301
}

variable "serf_wan_port" {
  description = "The port used by servers to gossip over the WAN to other servers."
  type        = number
  default     = 8302
}

variable "http_api_port" {
  description = "The port used by clients to talk to the HTTP API"
  type        = number
  default     = 8500
}

variable "dns_port" {
  description = "The port used to resolve DNS queries."
  type        = number
  default     = 8600
}

variable "allowed_inbound_cidr_blocks_http_api" {
  description = "A list of CIDR-formatted IP address ranges from which the Compute Instances will allow API connections to Consul."
  type        = list(string)
  default     = []
}

variable "allowed_inbound_tags_http_api" {
  description = "A list of tags from which the Compute Instances will allow API connections to Consul."
  type        = list(string)
  default     = []
}

variable "allowed_inbound_cidr_blocks_dns" {
  description = "A list of CIDR-formatted IP address ranges from which the Compute Instances will allow TCP DNS and UDP DNS connections to Consul."
  type        = list(string)
  default     = []
}

variable "allowed_inbound_tags_dns" {
  description = "A list of tags from which the Compute Instances will allow TCP DNS and UDP DNS connections to Consul."
  type        = list(string)
  default     = []
}