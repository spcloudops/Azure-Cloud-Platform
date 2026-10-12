locals {
  vmss_bootstrap_command = join(" ", [
    "powershell.exe",
    "-NoProfile",
    "-NonInteractive",
    "-ExecutionPolicy Bypass",
    "-EncodedCommand",
    textencodebase64(
      file("${path.module}/scripts/configure-iis.ps1"),
      "UTF-16LE"
    )
  ])
}

resource "azurerm_windows_virtual_machine_scale_set" "application" {
  name                = "vmss-rapid-app-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name

  sku       = "Standard_B2s"
  instances = 2

  computer_name_prefix = "rapidweb"
  admin_username       = var.management_admin_username
  admin_password       = var.management_admin_password

  upgrade_mode = "Manual"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "nic-rapid-vmss-app"
    primary = true

    ip_configuration {
      name      = "primary"
      primary   = true
      subnet_id = data.azurerm_subnet.app.id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.application.id
      ]
    }
  }

  extension {
    name                       = "configure-iis"
    publisher                  = "Microsoft.Compute"
    type                       = "CustomScriptExtension"
    type_handler_version       = "1.10"
    auto_upgrade_minor_version = true

    force_update_tag = filesha256(
      "${path.module}/scripts/configure-iis.ps1"
    )

    settings = jsonencode({
      commandToExecute = local.vmss_bootstrap_command
    })
  }

  tags = local.tags

  depends_on = [
    azurerm_lb_rule.http,
    azurerm_firewall_policy_rule_collection_group.outbound,
    azurerm_subnet_route_table_association.outbound
  ]
}