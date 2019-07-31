resource "google_compute_firewall" "allow_intracluster_consul" {

  name    = "allow-intracluster-consul"
  network = var.network

  allow {
    protocol = "tcp"

    ports = [
      var.server_rpc_port,
      var.cli_rpc_port,
      var.serf_lan_port,
      var.serf_wan_port,
      var.http_api_port,
      var.dns_port,
    ]
  }

  allow {
    protocol = "udp"

    ports = [
      var.serf_lan_port,
      var.serf_wan_port,
      var.dns_port,
    ]
  }

  source_tags = [var.cluster_tag_name]
  target_tags = [var.cluster_tag_name]
}


resource "google_compute_firewall" "allow_inbound_http_api" {
  count = length(var.allowed_inbound_cidr_blocks_dns) + length(var.allowed_inbound_tags_dns) > 0 ? 1 : 0

  name    = "consul-rule-external-api-access"
  network = var.network

  allow {
    protocol = "tcp"

    ports = [
      var.http_api_port,
    ]
  }

  source_ranges = var.allowed_inbound_cidr_blocks_http_api
  source_tags   = var.allowed_inbound_tags_http_api
  target_tags   = [var.cluster_tag_name]
}


resource "google_compute_firewall" "allow_inbound_dns" {
  count = length(var.allowed_inbound_cidr_blocks_dns) + length(var.allowed_inbound_tags_dns) > 0 ? 1 : 0

  name    = "consul-rule-external-dns-access"
  network = var.network

  allow {
    protocol = "tcp"

    ports = [
      var.dns_port,
    ]
  }

  allow {
    protocol = "udp"

    ports = [
      var.dns_port,
    ]
  }

  source_ranges = var.allowed_inbound_cidr_blocks_dns
  source_tags   = var.allowed_inbound_tags_dns
  target_tags   = [var.cluster_tag_name]
}