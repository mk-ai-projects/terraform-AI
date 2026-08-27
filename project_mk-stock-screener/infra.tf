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

  env_vars = {
    TELEGRAM_CHAT_ID = "762833990"
  }

  # Flask login + alerts. These secrets already exist in the GCP project;
  # listing them here stops a terraform apply from wiping gcloud-set env.
  secret_env_vars = {
    ADMIN_KEY          = { secret_id = "mk-stock-screener-admin-key" }
    SECRET_KEY         = { secret_id = "mk-stock-screener-secret-key" }
    TELEGRAM_BOT_TOKEN = { secret_id = "mk-trading-telegram-bot-token" }
    ALERT_TOKEN        = { secret_id = "mk-trading-alert-token" }
  }
}

output "uri" {
  value = module.app.uri
}

output "domain_mapping_cname_target" {
  value = module.app.domain_mapping_cname_target
}
