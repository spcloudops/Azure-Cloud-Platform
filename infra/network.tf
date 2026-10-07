locals {
  tags = {
    Environment = "Dev"
    Project     = "Azure-Rapid-Platform"
    ManagedBy   = "Terraform"
  }

  vnets = {
    hub = {
      name = "vnet-rapid-hub-dev"
      cidr = "10.0.0.0/16"
    }
    paas = {
      name = "vnet-rapid-paas-dev"
      cidr = "10.1.0.0/16"
    }
    iaas = {
      name = "vnet-rapid-iaas-dev"
      cidr = "10.2.0.0/16"
    }
  }

  subnets = {
    firewall = {
      vnet = "hub"
      name = "AzureFirewallSubnet"
      cidr = "10.0.0.0/26"
    }
    firewall_management = {
      vnet = "hub"
      name = "AzureFirewallManagementSubnet"
      cidr = "10.0.0.64/26"
    }
    bastion = {
      vnet = "hub"
      name = "AzureBastionSubnet"
      cidr = "10.0.1.0/26"
    }
    hub_management = {
        vnet = "hub"
        name = "snet-hub-management"
        cidr = "10.0.3.0/24"
    }
    app_gateway = {
      vnet = "hub"
      name = "snet-appgw"
      cidr = "10.0.2.0/24"
    }
    app_integration = {
      vnet = "paas"
      name = "snet-app-integration"
      cidr = "10.1.1.0/24"
    }
    private_endpoints = {
      vnet = "paas"
      name = "snet-private-endpoints"
      cidr = "10.1.2.0/24"
    }
    app = {
      vnet = "iaas"
      name = "snet-app"
      cidr = "10.2.1.0/24"
    }
  }
}

resource "azurerm_virtual_network" "platform" {
  for_each = local.vnets

  name                = each.value.name
  address_space       = [each.value.cidr]
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  tags                = local.tags
}

resource "azurerm_subnet" "platform" {
  for_each = local.subnets

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform[each.value.vnet].name
  address_prefixes     = [each.value.cidr]

  dynamic "delegation" {
    for_each = each.key == "app_integration" ? [1] : []

    content {
      name = "app-service"

      service_delegation {
        name = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action"
        ]
      }
    }
  }
}