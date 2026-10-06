resource "azurerm_virtual_network_peering" "hub_to_paas" {
  name                      = "peer-hub-to-paas"
  resource_group_name       = data.azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.platform["hub"].name
  remote_virtual_network_id = azurerm_virtual_network.platform["paas"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "paas_to_hub" {
  name                      = "peer-paas-to-hub"
  resource_group_name       = data.azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.platform["paas"].name
  remote_virtual_network_id = azurerm_virtual_network.platform["hub"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network_peering.hub_to_paas]
}

resource "azurerm_virtual_network_peering" "hub_to_iaas" {
  name                      = "peer-hub-to-iaas"
  resource_group_name       = data.azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.platform["hub"].name
  remote_virtual_network_id = azurerm_virtual_network.platform["iaas"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network_peering.paas_to_hub]
}

resource "azurerm_virtual_network_peering" "iaas_to_hub" {
  name                      = "peer-iaas-to-hub"
  resource_group_name       = data.azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.platform["iaas"].name
  remote_virtual_network_id = azurerm_virtual_network.platform["hub"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network_peering.hub_to_iaas]
}