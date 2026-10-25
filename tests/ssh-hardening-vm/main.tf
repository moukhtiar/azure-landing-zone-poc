# PE-02 - Disposable SSH hardening test VM
# This configuration references existing networking resources.
# It does not modify the existing agent VM or network security rules.

data "azurerm_resource_group" "network" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "hub" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.network.name
}

data "azurerm_subnet" "agents" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = data.azurerm_resource_group.network.name
}

# Create a dedicated NIC in the existing agent subnet.
resource "azurerm_network_interface" "test" {
  name                = "nic-ssh-hardening-poc-uaen-01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.network.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.agents.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "poc"
    purpose     = "ssh-hardening-test"
    managed-by  = "terraform"
  }
}

# Disposable VM: no public IP and no managed identity.
resource "azurerm_linux_virtual_machine" "test" {
  name                = "vm-ssh-hardening-poc-uaen-01"
  computer_name       = "ssh-hardening-poc"
  resource_group_name = data.azurerm_resource_group.network.name
  location            = var.location
  size                = "Standard_FX2ms_v2"

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.test.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-ssh-hardening-poc-uaen-01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Apply the SSH configuration at first boot.
  custom_data = filebase64(
    "${path.module}/../../cloud-init/agent-ssh-hardening.yaml"
  )

  tags = {
    environment = "poc"
    purpose     = "ssh-hardening-test"
    managed-by  = "terraform"
  }
}
