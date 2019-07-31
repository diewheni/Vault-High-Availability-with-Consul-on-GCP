resource "google_compute_region_instance_group_manager" "consul" {
  name = "consul"

  base_instance_name = "consul"
  instance_template  = google_compute_instance_template.consul.self_link
  region             = var.region

  target_size = var.target_size  
}

######################################################
resource "google_compute_instance_template" "consul" {
  name        = "consul-server-template1"
  description = "This template is used to create Consul server instances."

  tags                    = concat([var.cluster_tag_name], var.custom_tags)

  machine_type = var.machine_type

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

  metadata_startup_script = data.template_file.consul.rendered

  service_account {
    email  = google_service_account.consul.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################
data "template_file" "consul" {
  template = file("./consul_startup.sh")

  vars = {
    consul_version = var.consul_version
    project        = var.project
  }
}