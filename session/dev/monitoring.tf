resource "azurerm_log_analytics_workspace" "session" {
  name                = "law-rapid-session-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                           = "diag-rapid-firewall-dev"
  target_resource_id             = azurerm_firewall.platform.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.session.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AZFWApplicationRule"
  }

  enabled_log {
    category = "AZFWNetworkRule"
  }
}