resource "google_compute_region_instance_group_manager" "vault" {
  name = "vault1"

  base_instance_name = "vault"
  instance_template  = google_compute_instance_template.vault.self_link
  region             = var.region

  target_size = var.target_size


  lifecycle {
    create_before_destroy = true
  }

}

#####################################################
resource "google_compute_instance_template" "vault" {
  name        = "vault-server-template1"
  description = "This template is used to create Vault server instances with Consul as the backend."

  machine_type = var.machine_type
  tags  = concat([var.cluster_tag_name], var.custom_tags)

  
  disk {
    source_image = var.source_image
    auto_delete  = var.boot_auto_delete
    boot         = true
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size_gb
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  scheduling {
    automatic_restart   = var.automatic_restart
    on_host_maintenance = var.on_host_maintenance
  }

  metadata_startup_script = data.template_file.vault.rendered

  service_account {
    email  = google_service_account.vault.email
    scopes = ["cloud-platform"]
  }



}

###############################
data "template_file" "vault" {
  template = file("./vault_startup.sh")

  vars = {
    consul_version = var.consul_version
    vault_version = var.vault_version
    project = var.project
    keyring_location = var.keyring_location
    key_ring = var.key_ring
    crypto_key = var.crypto_key
  }
}