output "environment_id" {
  value = azurerm_container_app_environment.this.id
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "location" {
  value = azurerm_resource_group.this.location
}
