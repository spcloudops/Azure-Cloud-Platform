moved {
  from = azurerm_public_ip.firewall
  to   = azurerm_public_ip.firewall[0]
}

moved {
  from = azurerm_public_ip.firewall_management
  to   = azurerm_public_ip.firewall_management[0]
}

moved {
  from = azurerm_firewall_policy.platform
  to   = azurerm_firewall_policy.platform[0]
}

moved {
  from = azurerm_firewall.platform
  to   = azurerm_firewall.platform[0]
}

moved {
  from = azurerm_firewall_policy_rule_collection_group.outbound
  to   = azurerm_firewall_policy_rule_collection_group.outbound[0]
}

moved {
  from = azurerm_monitor_diagnostic_setting.firewall
  to   = azurerm_monitor_diagnostic_setting.firewall[0]
}