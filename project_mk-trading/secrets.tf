locals {
  # Only the truthiness of "is this set" is structural, not the secret content
  # itself — nonsensitive() strips the sensitivity Terraform otherwise
  # propagates through the comparison, which would taint for_each below.
  include_anthropic = nonsensitive(var.anthropic_api_key != "")
  include_telegram  = nonsensitive(var.telegram_bot_token != "")
  include_alert     = nonsensitive(var.alert_token != "")
  include_smartapi  = nonsensitive(var.smartapi_api_key != "")

  secret_names = toset(concat(
    ["google-client-secret"],
    local.include_anthropic ? ["anthropic-api-key"] : [],
    local.include_telegram ? ["telegram-bot-token"] : [],
    local.include_alert ? ["alert-token"] : [],
    local.include_smartapi ? ["smartapi-api-key", "smartapi-password", "smartapi-totp-secret"] : []
  ))

  # Sensitive values kept in a separate map, looked up per-resource by the
  # (non-sensitive) key — for_each itself can't accept a map with sensitive
  # values, even though only the keys matter structurally.
  secret_values = merge(
    {
      "google-client-secret" = var.google_client_secret
    },
    local.include_anthropic ? {
      "anthropic-api-key" = var.anthropic_api_key
    } : {},
    local.include_telegram ? {
      "telegram-bot-token" = var.telegram_bot_token
    } : {},
    local.include_alert ? {
      "alert-token" = var.alert_token
    } : {},
    local.include_smartapi ? {
      "smartapi-api-key"     = var.smartapi_api_key
      "smartapi-password"    = var.smartapi_password
      "smartapi-totp-secret" = var.smartapi_totp_secret
    } : {}
  )

  # Cloud Run's default runtime service account (no custom service_account set on the service).
  default_compute_sa = "${var.gcp_project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret" "this" {
  for_each = local.secret_names
  project  = var.gcp_project_id
  # Secret Manager IDs are unique per GCP project, not per Cloud Run service —
  # prefix with the project name so this doesn't collide with another
  # project_* directory's secret of the same logical name (e.g. every
  # project using Google OAuth wants a "google-client-secret").
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
