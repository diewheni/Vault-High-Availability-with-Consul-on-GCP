resource "google_project_iam_custom_role" "consul" {
  role_id     = "consuljoiner"
  title       = "Consul auto-joining"
  permissions = ["compute.instances.get", "compute.instances.list", "compute.zones.list"]
}

resource "google_service_account" "consul" {
  account_id   = "consul-joiner"
  display_name = "Consul server"
}

resource "google_project_iam_member" "consul" {
  role   = "projects/${var.project}/roles/${google_project_iam_custom_role.consul.role_id}"
  member = "serviceAccount:${google_service_account.consul.email}"
}

