variable "name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "image" {
  description = "Full image reference, e.g. docker.io/<user>/<project-name>:latest"
  type        = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  description = "vCPU limit, as a string per Cloud Run's resources.limits format, e.g. \"1\""
  type        = string
  default     = "1"
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
  description = "Grant roles/run.invoker to allUsers, i.e. make the service publicly reachable"
  type        = bool
  default     = true
}

variable "invoker_members" {
  description = "Principals granted roles/run.invoker when allow_unauthenticated is false, e.g. [\"user:you@example.com\"]. Ignored when allow_unauthenticated is true."
  type        = list(string)
  default     = []
}

variable "custom_domain" {
  description = "Custom hostname to map onto this Cloud Run service, e.g. \"mk-stock-screener.mayankkoli.com\". Domain must already be verified for this GCP project in Search Console. null = no domain mapping created."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Cloud Run v2's own guard against accidental `terraform destroy`. Defaults false since these are single-owner prototype projects iterated on frequently; set true for anything that shouldn't be destroyable without an explicit apply first."
  type        = bool
  default     = false
}

variable "env_vars" {
  description = "Plain (non-secret) environment variables for the container, name => value."
  type        = map(string)
  default     = {}
}

variable "secret_env_vars" {
  description = "Environment variables sourced from Secret Manager, name => { secret_id, version }. secret_id is the Secret Manager secret's short name/id (not full resource path); version defaults to \"latest\"."
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {}
}
