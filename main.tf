provider "google" {
  #credentials = file(var.account_file_path)
  project = var.project
  region  = var.region
}
g

b

terraform {
  required_version = ">= 0.12"
}
 
module "consul" {
  source     = "./modules/consul"
  region     = var.region
  network    = var.network
  subnetwork = var.subnetwork
  project    = var.project
  depends    = [module.nat]
}

module "vault" {
  source           = "./modules/vault"
  region           = var.region
  network          = var.network
  subnetwork       = null
  project          = var.project
  keyring_location = var.keyring_location
  key_ring         = var.key_ring
  crypto_key       = var.crypto_key
  depends          = [module.nat]
}

module "nat" {
  source  = "./modules/nat"
  network = var.network
  region  = var.region
}
