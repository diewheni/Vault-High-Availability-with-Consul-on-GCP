resource "google_compute_router" "this" {
  name    = "this"
  network = var.network

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "this" {
  name                               = "test"
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}