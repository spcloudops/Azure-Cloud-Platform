locals {
  admin_public_ip_cidr = "175.33.209.204/32"
}

resource "azurerm_network_security_group" "hub_management" {
  name                = "nsg-rapid-hub-management-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  tags                = local.tags

  security_rule {
    name                       = "Allow-RDP-From-Admin-IP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = local.admin_public_ip_cidr
    destination_address_prefix = local.subnets["hub_management"].cidr
  }

  security_rule {
    name                       = "Deny-All-Other-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-rapid-app-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  tags                = local.tags

  security_rule {
    name                       = "Allow-HTTP-From-AppGateway"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = local.subnets["app_gateway"].cidr
    destination_address_prefix = local.subnets["app"].cidr
  }

  security_rule {
    name                       = "Allow-HTTP-LoadBalancer-Probe"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = local.subnets["app"].cidr
  }

  security_rule {
    name                       = "Allow-RDP-From-Hub-Management"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = local.subnets["hub_management"].cidr
    destination_address_prefix = local.subnets["app"].cidr
  }

  security_rule {
    name                       = "Allow-HTTP-From-Hub-Management"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = local.subnets["hub_management"].cidr
    destination_address_prefix = local.subnets["app"].cidr
  }

  security_rule {
    name                       = "Deny-All-Other-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "hub_management" {
  subnet_id                 = azurerm_subnet.platform["hub_management"].id
  network_security_group_id = azurerm_network_security_group.hub_management.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.platform["app"].id
  network_security_group_id = azurerm_network_security_group.app.id
}