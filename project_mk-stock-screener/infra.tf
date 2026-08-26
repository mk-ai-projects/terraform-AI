terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Bucket/prefix passed via -backend-config (see .github/workflows/project-infra.yml
  # and the one-time `terraform init -migrate-state` that moved this off local state).
  backend "gcs" {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

module "app" {
  source                = "../99_shared-infra/modules/gcpCloudRun"
  name                  = var.name
  project_id            = var.gcp_project_id
  region                = var.gcp_region
  image                 = var.image
  container_port        = var.container_port
  cpu                   = var.cpu
  memory                = var.memory
  min_instances         = var.min_instances
  max_instances         = var.max_instances
  allow_unauthenticated = var.allow_unauthenticated
  invoker_members       = var.invoker_members
  custom_domain         = var.custom_domain
  deletion_protection   = var.deletion_protection

  secret_env_vars = {
    ADMIN_KEY  = { secret_id = google_secret_manager_secret.this["admin-key"].secret_id }
    SECRET_KEY = { secret_id = google_secret_manager_secret.this["secret-key"].secret_id }
  }

  # secret_env_vars only references the secret *container* (secret_id), not
  # the version resource, so Terraform has no implicit dependency forcing it
  # to wait for a version to actually exist before deploying Cloud Run —
  # without this, "latest" can 404 on first apply (version still committing).
  depends_on = [google_secret_manager_secret_version.this]
}

output "uri" {
  value = module.app.uri
}

output "domain_mapping_cname_target" {
  value = module.app.domain_mapping_cname_target
}
