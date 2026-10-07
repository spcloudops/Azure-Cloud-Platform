resource "azurerm_firewall_policy_rule_collection_group" "outbound" {
  name               = "rcg-outbound"
  firewall_policy_id = azurerm_firewall_policy.platform.id
  priority           = 200

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