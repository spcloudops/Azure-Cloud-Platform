data "azurerm_resource_group" "platform" {
  name = "rg-rapid-platform-dev"
}

output "resource_group_name" {
  value = data.azurerm_resource_group.platform.name
}