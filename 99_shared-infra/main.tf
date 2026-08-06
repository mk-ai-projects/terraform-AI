terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Bucket/prefix passed via -backend-config (see .github/workflows/shared-infra.yml
  # and the one-time `terraform init -migrate-state` that moved this off local state).
  backend "gcs" {}
}

provider "cloudflare" {
  # api_token read from CLOUDFLARE_API_TOKEN env var — do not hardcode it here
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  # auth via Application Default Credentials — run `gcloud auth application-default login`,
  # or set GOOGLE_APPLICATION_CREDENTIALS. Do not hardcode a key file path here.
}

# One shared GCP environment (Cloud Run API enabled on the project). Every
# project_* app deploys into this project/region instead of standing up
# anything per-project.
module "shared_environment" {
  source     = "./modules/gcpEnvironment"
  project_id = var.gcp_project_id
  region     = var.gcp_region
}

# One project_<key> directory per map entry — its Cloud Run domain-mapping
# CNAME target is read straight from that project's own state, never
# hand-typed here.
data "terraform_remote_state" "projects" {
  for_each = var.projects
  backend  = "gcs"

  config = {
    bucket = var.tf_state_bucket
    prefix = "project_${each.key}"
  }
}

module "subdomains" {
  source   = "./modules/cloudflare-cdn-web"
  for_each = var.projects

  zone_id   = var.zone_id
  subdomain = each.key
  # target must come from the Cloud Run domain-mapping CNAME (ghs.googlehosted.com),
  # not the raw *.run.app host — Google's edge only recognizes the mapped host once
  # this record points at the mapping's rrdata.
  target = data.terraform_remote_state.projects[each.key].outputs.domain_mapping_cname_target
  # must stay DNS-only: Cloudflare's proxy would hide the real CNAME target from
  # Google, breaking the domain mapping's host/cert verification.
  proxied = each.value.proxied
}

output "hostnames" {
  value = { for k, m in module.subdomains : k => m.hostname }
}

output "gcp_project_id" {
  value = module.shared_environment.project_id
}

output "gcp_region" {
  value = module.shared_environment.region
}

output "gcp_run_api_id" {
  value = module.shared_environment.run_api_id
}
