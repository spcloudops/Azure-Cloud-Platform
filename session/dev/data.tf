data "azurerm_resource_group" "platform" {
  name = "rg-rapid-platform-dev"
}

data "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = "vnet-rapid-hub-dev"
  resource_group_name  = data.azurerm_resource_group.platform.name
}

data "azurerm_subnet" "firewall_management" {
  name                 = "AzureFirewallManagementSubnet"
  virtual_network_name = "vnet-rapid-hub-dev"
  resource_group_name  = data.azurerm_resource_group.platform.name
}
data "azurerm_subnet" "app" {
  name                 = "snet-app"
  virtual_network_name = "vnet-rapid-iaas-dev"
  resource_group_name  = data.azurerm_resource_group.platform.name
}

data "azurerm_subnet" "app_integration" {
  name                 = "snet-app-integration"
  virtual_network_name = "vnet-rapid-paas-dev"
  resource_group_name  = data.azurerm_resource_group.platform.name
}