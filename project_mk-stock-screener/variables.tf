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
