terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "shared" {
  backend = "local"

  config = {
    path = "../01_shared-infra/terraform.tfstate"
  }
}

module "app" {
  source                       = "../01_shared-infra/modules/azureContainers"
  name                         = var.name
  container_app_environment_id = data.terraform_remote_state.shared.outputs.container_environment_id
  resource_group_name          = data.terraform_remote_state.shared.outputs.container_environment_resource_group
  image                        = var.image
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  target_port                  = var.target_port
  cpu                          = var.cpu
  memory                       = var.memory
}

output "fqdn" {
  value = module.app.fqdn
}
