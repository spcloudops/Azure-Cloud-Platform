locals {
  paas_web_app_name = "app-rapid-paas-dev-sathish1az2025"
}

resource "azurerm_service_plan" "paas" {
  count = var.enable_paas_app ? 1 : 0

  name                = "asp-rapid-paas-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name

  os_type      = "Windows"
  sku_name     = "B1"
  worker_count = 1

  tags = local.tags
}

resource "azurerm_windows_web_app" "paas" {
  count = var.enable_paas_app ? 1 : 0

  name                      = local.paas_web_app_name
  location                  = data.azurerm_resource_group.platform.location
  resource_group_name       = data.azurerm_resource_group.platform.name
  service_plan_id           = azurerm_service_plan.paas[0].id
  virtual_network_subnet_id = data.azurerm_subnet.app_integration.id

  https_only                    = true
  public_network_access_enabled = true

  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = true
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"

    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
  }

  tags = local.tags
}

output "paas_application_url" {
  description = "HTTPS address of the PaaS application when enabled."
  value = var.enable_paas_app ? (
    "https://${azurerm_windows_web_app.paas[0].default_hostname}"
  ) : null
}