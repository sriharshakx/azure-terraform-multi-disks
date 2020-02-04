provider "azurerm" {
  subscription_id = "522fb493-ffab-4a5c-b72d-fe645a4d1e41"
}

module "vm1" {
  source  = "./vms"
  vmname  = "sample-vm-1"
}