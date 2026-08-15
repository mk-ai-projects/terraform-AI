locals {
  # Cloud Run's default runtime service account (no custom service_account set on the service).
  default_compute_sa = "${var.gcp_project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret" "this" {
  project = var.gcp_project_id
  # Secret Manager IDs are unique per GCP project, not per Cloud Run service —
  # prefix with the project name so this doesn't collide with another
  # project_* directory's secret of the same logical name.
  secret_id = "${var.name}-openweather-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "this" {
  secret      = google_secret_manager_secret.this.id
  secret_data = var.openweather_api_key
}

resource "google_secret_manager_secret_iam_member" "runtime_access" {
  project   = var.gcp_project_id
  secret_id = google_secret_manager_secret.this.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.default_compute_sa}"
}
