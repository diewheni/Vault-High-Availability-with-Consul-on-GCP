variable "gcloud-project" {}
variable "gcloud-region" {}
variable "server_quantity" {}
variable "machine_type" {
  default = "n1-standard-1"
}

variable "gcloud-zone" {}

variable "image" {
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}

variable "disk_size" {
  default = 10
}

variable "network" {}
variable "subnetwork" {}

variable "network_ip" {
  type    = string
  default = null
}