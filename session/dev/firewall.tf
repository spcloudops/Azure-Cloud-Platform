resource "azurerm_public_ip" "firewall" {
  name                = "pip-rapid-firewall-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  count               = var.enable_firewall ? 1 : 0
}

resource "azurerm_public_ip" "firewall_management" {
  name                = "pip-rapid-firewall-management-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  count               = var.enable_firewall ? 1 : 0
}

resource "azurerm_firewall_policy" "platform" {
  name                     = "afwp-rapid-platform-dev"
  location                 = data.azurerm_resource_group.platform.location
  resource_group_name      = data.azurerm_resource_group.platform.name
  sku                      = "Basic"
  threat_intelligence_mode = "Alert"
  tags                     = local.tags
  count                    = var.enable_firewall ? 1 : 0
}

resource "azurerm_firewall" "platform" {
  name                = "afw-rapid-platform-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"
  firewall_policy_id  = azurerm_firewall_policy.platform[0].id
  tags                = local.tags
  count               = var.enable_firewall ? 1 : 0
  ip_configuration {
    name                 = "data"
    subnet_id            = data.azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }

  management_ip_configuration {
    name                 = "management"
    subnet_id            = data.azurerm_subnet.firewall_management.id
    public_ip_address_id = azurerm_public_ip.firewall_management[0].id
  }
}