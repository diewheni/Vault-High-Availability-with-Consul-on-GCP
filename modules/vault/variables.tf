variable "region" {}
variable "network" {}
variable "subnetwork" {}
variable "project" {}
variable "keyring_location" {}
variable "key_ring" {}
variable "crypto_key" {}


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

variable "vault_version" {
    default = "1.2.0"
}

variable "depends" { 
    default = []
    type = list
}

variable "custom_tags" {
  description = "A list of tags that will be added to the Compute Instance Template in addition to the tags automatically added by this module."
  type        = list(string)
  default     = ["consul"]
}

variable "cluster_tag_name" {
  description = "The tag name the Compute Instances will look for to automatically discover each other and form a cluster. TIP: If running more than one Vault cluster, each cluster should have its own unique tag name."
  type        = string
  default = "vault"
}

variable "api_port" {
  description = "The port used by Vault to handle incoming API requests."
  type        = number
  default     = 8200
}

variable "cluster_port" {
  description = "The port used by Vault for server-to-server communication."
  type        = number
  default     = 8201
}

variable "allowed_inbound_cidr_blocks_api" {
  description = "A list of CIDR-formatted IP address ranges from which the Compute Instances will allow connections to Vault on the configured TCP Listener (see https://goo.gl/Equ4xP)"
  type        = list(string)
  default     = []
}

variable "allowed_inbound_tags_api" {
  description = "A list of tags from which the Compute Instances will allow connections to Vault on the configured TCP Listener (see https://goo.gl/Equ4xP)"
  type        = list(string)
  default     = []
}