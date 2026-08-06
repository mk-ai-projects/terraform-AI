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
}

output "uri" {
  value = module.app.uri
}

output "domain_mapping_cname_target" {
  value = module.app.domain_mapping_cname_target
}
