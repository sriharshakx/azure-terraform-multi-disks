variable "vmname" {}
variable "nicname" {}
variable "diskname" {}

resource "azurerm_virtual_machine" "main" {
  name                  = var.vmname
  location              = "East US"
  resource_group_name   = "OpenShift"
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = var.diskname
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}


resource "azurerm_network_interface" "main" {
  name                = var.nicname
  location            = "East US"
  resource_group_name = "OpenShift"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "/subscriptions/522fb493-ffab-4a5c-b72d-fe645a4d1e41/resourceGroups/OpenShift/providers/Microsoft.Network/virtualNetworks/OpenShift-vnet/subnets/default"
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_managed_disk" "example" {
  count                 = 2
  name                 = "acctestmd-${var.vmname}-${count.index}"
  location             = "East US"
  resource_group_name  = "OpenShift"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "disk${count.index}"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  count               = 2
  managed_disk_id     = element(azurerm_managed_disk.example.*.id, count.index)
  virtual_machine_id  = azurerm_virtual_machine.main.id
  lun                 = count.index+10
  caching             = "ReadWrite"
}