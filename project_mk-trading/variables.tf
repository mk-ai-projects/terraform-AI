## Template: project_<name>/variables.tf — copy as-is, no placeholders to fill here.
## Defaults match modules/gcpCloudRun/variables.tf; override per-project in app.tfvars.

variable "name" {
  type = string
}

variable "gcp_project_id" {
  type    = string
  default = "mk-ai-projects"
}

variable "gcp_region" {
  type    = string
  default = "us-central1"
}

variable "image" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "512Mi"
}

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 1
}

variable "allow_unauthenticated" {
  type    = bool
  default = true
}

variable "invoker_members" {
  type    = list(string)
  default = []
}

variable "custom_domain" {
  type    = string
  default = null
}

variable "deletion_protection" {
  type    = bool
  default = false
}

## mk-trading-specific: env/secrets. Not part of the shared template — this
## project diverges from the generic three-file pattern intentionally.

variable "gcp_project_number" {
  description = "Used to build the default Cloud Run runtime service account email for Secret Manager IAM grants."
  type        = string
  default     = "655315820279"
}

variable "admin_emails" {
  type = string
}

variable "google_client_id" {
  type = string
}

variable "telegram_chat_id" {
  description = "Telegram chat for the 09:10 pre-open alert. Not a secret — only an identifier."
  type        = string
  default     = ""
}

variable "telegram_bot_token" {
  description = "Set via secrets.auto.tfvars (gitignored), never in app.tfvars. Empty = alerts disabled."
  type        = string
  sensitive   = true
  default     = ""
}

variable "alert_token" {
  description = "Shared secret Cloud Scheduler presents to POST /api/alerts/*. Set via secrets.auto.tfvars. Empty = the alert endpoints refuse every request."
  type        = string
  sensitive   = true
  default     = ""
}

variable "gcs_bucket" {
  description = "GCS bucket the dashboard persists its cache to. Cloud Run's filesystem is ephemeral, so with this empty the app falls back to local files and every cache write is lost on the next cold start."
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Set via secrets.auto.tfvars (gitignored), never in app.tfvars."
  type        = string
  sensitive   = true
  default     = ""
}

variable "anthropic_api_key" {
  description = "Set via secrets.auto.tfvars (gitignored), never in app.tfvars. Empty = ANTHROPIC_API_KEY env var and its secret are omitted entirely."
  type        = string
  sensitive   = true
  default     = ""
}
