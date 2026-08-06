variable "name" {
  description = "Name of the shared Container App Environment"
  type        = string
  default     = "cae-shared-ai"
}

variable "resource_group_name" {
  type    = string
  default = "rg-shared-ai"
}

variable "location" {
  type    = string
  default = "eastus"
}
