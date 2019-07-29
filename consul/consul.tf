resource "google_compute_instance" "consul" {

  count        = var.server_quantity
  name         = "consul-${count.index}"
  machine_type = var.machine_type
  zone         = var.gcloud-zone
  tags         = ["consul"]

  boot_disk {
    initialize_params {
      image = var.image
      type  = "pd-ssd"
      size  = var.disk_size
    }
  }


  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    network_ip = var.network_ip

  }

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.consul.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = data.template_file.startup.rendered

}

data "template_file" "startup" {
  template = file("./startup.sh")

  vars = {
    consul_version = "1.5.3"
    gcloud-project = var.gcloud-project

  }
}


provider "google" {
  #credentials = file(var.account_file_path)
  project = var.gcloud-project
  region  = var.gcloud-region
}
