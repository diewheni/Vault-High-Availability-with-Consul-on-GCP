resource "google_compute_router" "this" {
  name    = "testme"
  network = var.network

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "this" {
  name                               = "test"
  router                             = google_compute_router.this.name
  region                             = var.gcloud-region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.this.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_address" "this" {
  name   = "myipaddress"
  region = var.gcloud-region
}