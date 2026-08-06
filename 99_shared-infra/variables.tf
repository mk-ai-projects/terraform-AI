variable "zone_id" {
  description = "Cloudflare zone ID for mayankkoli.com"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project all shared infra and project_* Cloud Run services deploy into"
  type        = string
  default     = "mk-ai-projects"
}

variable "gcp_project_number" {
  description = "GCP project number for mk-ai-projects. Not consumed by any resource yet — kept for reference (e.g. default compute SA emails are <number>-compute@developer.gserviceaccount.com)"
  type        = string
  default     = "655315820279"
}

variable "gcp_region" {
  type    = string
  default = "us-central1"
}

variable "tf_state_bucket" {
  description = "GCS bucket holding every project_*'s Terraform state — used to read each project's domain-mapping CNAME target via terraform_remote_state."
  type        = string
  default     = "mk-ai-projects-tfstate"
}

# One entry per project. Key must match the project_<key> directory name —
# its Cloud Run domain-mapping CNAME target is read from that directory's own
# state (see data.terraform_remote_state.projects in main.tf), not hardcoded
# here. proxied defaults to false: these records point at a Cloud Run domain
# mapping (ghs.googlehosted.com), which needs DNS-only to verify/issue certs.
variable "projects" {
  type = map(object({
    proxied = optional(bool, false)
  }))
  default = {
    mk-stock-screener = {}
    mealplan          = {}
    mk-trading        = {}
    video-downloader  = {}
  }
}
