resource "google_project_iam_custom_role" "vault" {
  role_id     = "vaultconsulclient"
  title       = "Vault/Consul viewer"
  permissions = ["compute.instances.get", "compute.instances.list", "compute.zones.list"]
}

resource "google_service_account" "vault" {
  account_id   = "vault-consul-client"
  display_name = "Vault/Consul"
}

resource "google_project_iam_member" "vault_compute" {
  role   = "projects/${var.project}/roles/${google_project_iam_custom_role.vault.role_id}"
  member = "serviceAccount:${google_service_account.vault.email}"
}

resource "google_project_iam_member" "vault_kms" {
  role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:${google_service_account.vault.email}"
}

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = "${var.project}/${var.keyring_location}/${var.key_ring}"
  role = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.vault.email}",
  ]
}