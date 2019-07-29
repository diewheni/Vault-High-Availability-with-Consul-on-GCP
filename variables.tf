variable "vault_url" {
  default = "https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip"
}

variable "gcloud-project" {
  description = "Google project name"
}

variable "gcloud-region" {
  default = "us-east1"
}

variable "gcloud-zone" {
  default = "us-east1-b"
}



variable "key_ring" {
  description = "Cloud KMS key ring name to create"
}

variable "crypto_key" {
  description = "Crypto key name to create under the key ring"
}

variable "keyring_location" {
  default = "global"
}

variable "service_account" {
    default = ""
}