resource "azurerm_lb" "application" {
  name                = "ilb-rapid-app-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend-private"
    subnet_id                     = data.azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "application" {
  name            = "pool-rapid-app-dev"
  loadbalancer_id = azurerm_lb.application.id
}

resource "azurerm_lb_probe" "http" {
  name            = "probe-http"
  loadbalancer_id = azurerm_lb.application.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "http" {
  name                           = "rule-http"
  loadbalancer_id                = azurerm_lb.application.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-private"

  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.application.id
  ]

  probe_id              = azurerm_lb_probe.http.id
  disable_outbound_snat = true
}

output "application_ilb_private_ip" {
  description = "Private frontend IP used to access the VMSS application."
  value       = azurerm_lb.application.frontend_ip_configuration[0].private_ip_address
}