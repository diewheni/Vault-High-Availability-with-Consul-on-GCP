resource "google_service_account" "consul" {
  account_id   = "consul-joiner"
  display_name = "Consul auto-joining"
}

resource "google_project_iam_member" "this" {
  role   = "projects/${var.gcloud-project}/roles/${google_project_iam_custom_role.custom-role.role_id}"
  member = "serviceAccount:${google_service_account.consul.email}"
}

resource "google_project_iam_custom_role" "custom-role" {
  role_id     = "consuljoiner"
  title       = "Consul auto-joining"
  permissions = ["compute.instances.get", "compute.instances.list", "compute.zones.list"]
}