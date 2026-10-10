resource "azurerm_network_interface" "workload" {
  name                = "nic-rapid-workload-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_windows_virtual_machine" "workload" {
  name                = "vm-rapid-workload-dev"
  computer_name       = "rapid-work-dev"
  location            = data.azurerm_resource_group.platform.location
  resource_group_name = data.azurerm_resource_group.platform.name
  size                = "Standard_B2s"

  admin_username = var.management_admin_username
  admin_password = var.management_admin_password

  network_interface_ids = [
    azurerm_network_interface.workload.id
  ]

  os_disk {
    name                 = "osdisk-rapid-workload-dev"
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

resource "azurerm_managed_disk" "workload_data" {
  name                 = "disk-rapid-workload-data-dev"
  location             = data.azurerm_resource_group.platform.location
  resource_group_name  = data.azurerm_resource_group.platform.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 64

  tags = local.tags
}
