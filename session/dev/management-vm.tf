resource "azurerm_public_ip" "management" {
  count               = var.enable_session_compute ? 1 : 0
  name                = "pip-rapid-management-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_network_interface" "management" {
  count               = var.enable_session_compute ? 1 : 0
  name                = "nic-rapid-management-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.hub_management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.management[0].id
  }

  tags = local.tags
}

resource "azurerm_windows_virtual_machine" "management" {
  count               = var.enable_session_compute ? 1 : 0
  name                = "vm-rapid-management-dev"
  computer_name       = "rapid-mgmt-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  size                = "Standard_B2s"

  admin_username = var.management_admin_username
  admin_password = var.management_admin_password

  network_interface_ids = [
    azurerm_network_interface.management[0].id
  ]

  os_disk {
    name                 = "osdisk-rapid-management-dev"
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

  boot_diagnostics {}

  tags = local.tags
}