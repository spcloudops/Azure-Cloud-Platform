resource "azurerm_firewall_policy_rule_collection_group" "outbound" {
  count              = var.enable_firewall ? 1 : 0
  name               = "rcg-outbound"
  firewall_policy_id = azurerm_firewall_policy.platform[0].id
  priority           = 200
  network_rule_collection {
    name     = "Allow-VMSS-Extension-Storage"
    priority = 100
    action   = "Allow"

    rule {
      name = "Allow-IaaS-To-Azure-Storage"

      protocols = ["TCP"]

      source_addresses = [
        "10.2.1.0/24"
      ]

      destination_addresses = [
        "Storage"
      ]

      destination_ports = [
        "80",
        "443"
      ]
    }
  }
  application_rule_collection {
    name     = "Allow-Selected-Websites"
    priority = 200
    action   = "Allow"

    rule {
      name = "Allow-Microsoft-HTTPS"

      source_addresses = [
        "10.2.1.0/24",
        "10.1.1.0/24"
      ]

      destination_fqdns = [
        "www.microsoft.com"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}