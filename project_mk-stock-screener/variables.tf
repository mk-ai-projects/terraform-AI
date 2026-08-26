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

variable "gcp_project_number" {
  description = "Used to build the default Cloud Run runtime service account email for Secret Manager IAM grants."
  type        = string
  default     = "655315820279"
}

variable "admin_key" {
  description = "Login key for the app. Set via secrets.auto.tfvars (gitignored), never in app.tfvars."
  type        = string
  sensitive   = true
  default     = ""
}

variable "secret_key" {
  description = "Flask session signing key. Set via secrets.auto.tfvars (gitignored), never in app.tfvars."
  type        = string
  sensitive   = true
  default     = ""
}
