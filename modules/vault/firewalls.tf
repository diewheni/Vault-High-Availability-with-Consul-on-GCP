resource "google_compute_firewall" "allow_intracluster_vault" {
  name    = "vault-rule-cluster"
  network = var.network

  allow {
    protocol = "tcp"

    ports = [
      var.cluster_port,
    ]
  }

  source_tags = [var.cluster_tag_name]
  target_tags = [var.cluster_tag_name]
}

resource "google_compute_firewall" "allow_inbound_api_vault" {
  count = length(var.allowed_inbound_cidr_blocks_api) + length(var.allowed_inbound_tags_api) > 0 ? 1 : 0

  name    = "vault-rule-external-api-access"
  network = var.network

  allow {
    protocol = "tcp"

    ports = [
      var.api_port,
    ]
  }

  source_ranges = var.allowed_inbound_cidr_blocks_api
  source_tags   = var.allowed_inbound_tags_api
  target_tags   = [var.cluster_tag_name]
}
