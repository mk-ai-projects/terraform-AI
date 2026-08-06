## Template: project_<name>/infra.tf — copy as-is, no placeholders to fill here.
## Actual values come from project_<name>/app.tfvars (see project-app.tfvars.tmpl).
##
## Every project_* directory deploys its Cloud Run service into the shared
## GCP project/region (mk-ai-projects / us-central1 by default — see
## var.gcp_project_id / var.gcp_region in variables.tf).
##
## Do NOT read these from 99_shared-infra's terraform_remote_state: shared-infra
## itself reads THIS project's state (for the Cloudflare CNAME target), so a
## reverse read here creates a circular "no stored state found" deadlock on
## first apply. project_id/region are static config, not something generated
## by applying shared-infra, so each project just declares its own copy.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
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

  env_vars = {
    NODE_ENV            = "production"
    GOOGLE_REDIRECT_URI = "https://${var.custom_domain}/api/google/callback"
    CORS_ORIGIN         = "https://${var.custom_domain}"
    ADMIN_EMAILS        = var.admin_emails
    GOOGLE_CLIENT_ID    = var.google_client_id
    SUPABASE_URL        = var.supabase_url
  }

  secret_env_vars = merge(
    {
      GOOGLE_CLIENT_SECRET = { secret_id = google_secret_manager_secret.this["google-client-secret"].secret_id }
      SUPABASE_SECRET_KEY  = { secret_id = google_secret_manager_secret.this["supabase-secret-key"].secret_id }
    },
    var.anthropic_api_key == "" ? {} : {
      ANTHROPIC_API_KEY = { secret_id = google_secret_manager_secret.this["anthropic-api-key"].secret_id }
    }
  )

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
