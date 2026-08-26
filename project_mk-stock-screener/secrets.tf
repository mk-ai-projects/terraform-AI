locals {
  secret_names = toset(["admin-key", "secret-key"])

  secret_values = {
    "admin-key"  = var.admin_key
    "secret-key" = var.secret_key
  }

  # Cloud Run's default runtime service account (no custom service_account set on the service).
  default_compute_sa = "${var.gcp_project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret" "this" {
  for_each = local.secret_names
  project  = var.gcp_project_id
  secret_id = "${var.name}-${each.value}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "this" {
  for_each    = local.secret_names
  secret      = google_secret_manager_secret.this[each.value].id
  secret_data = local.secret_values[each.value]
}

resource "google_secret_manager_secret_iam_member" "runtime_access" {
  for_each  = local.secret_names
  project   = var.gcp_project_id
  secret_id = google_secret_manager_secret.this[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.default_compute_sa}"
}
