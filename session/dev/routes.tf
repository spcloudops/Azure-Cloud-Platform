locals {
  routed_subnets = {
    iaas_app        = data.azurerm_subnet.app.id
    paas_integration = data.azurerm_subnet.app_integration.id
  }
}

resource "azurerm_route_table" "outbound" {
  for_each = local.routed_subnets

  name                = "rt-rapid-${each.key}-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  tags                = local.tags

  route {
    name                   = "Internet-via-Firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.platform.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "outbound" {
  for_each = local.routed_subnets

  subnet_id      = each.value
  route_table_id = azurerm_route_table.outbound[each.key].id

  depends_on = [
    azurerm_firewall_policy_rule_collection_group.outbound
  ]
}