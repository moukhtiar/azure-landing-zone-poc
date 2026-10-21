# ------------------------------------------------------------
# PE-01 — Azure DevOps Self-Hosted Agent
# Resource: Network Interface
# Purpose: Provide private network connectivity for the agent VM.
# ------------------------------------------------------------

resource "azurerm_network_interface" "agent" {
  # Follow the standardized POC naming convention.
  name = "nic-agent-poc-uaen-01"

  # Deploy the NIC in the existing networking resource group.
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location

  # Configure the NIC to use the dedicated agent subnet.
  ip_configuration {
    name = "ipconfig-agent"

    # Reuse the existing hub subnet; do not create another subnet.
    subnet_id = module.hub.subnet_ids["snet-agents"]

    # Allow Azure to allocate a private IPv4 address dynamically.
    private_ip_address_allocation = "Dynamic"
  }

  # Apply the standard organizational tags.
  tags = local.common_tags
}

# ------------------------------------------------------------
# PE-01 — Azure DevOps Self-Hosted Agent
# Resource: Linux Virtual Machine
# Purpose: Host the private Azure DevOps build agent.
# ------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "agent" {
  # Follow the standardized POC naming convention.
  name = "vm-agent-poc-uaen-01"

  # Reuse the existing networking resource group and region.
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location

  # Use the VM size selected for this POC.
  size = "Standard_FX2ms_v2"

  # Configure the administrative account.
  admin_username = "azureadmin"

  # Preserve the VM's existing system-assigned managed identity.
  # Required for passwordless authentication to authorized Azure services.
  identity {
    type = "SystemAssigned"
  }
  # Attach the existing private network interface.
  network_interface_ids = [
    azurerm_network_interface.agent.id
  ]

  # Configure administrator SSH authentication.
  # Supply the public key through a Terraform variable.
  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.agent_admin_ssh_public_key
  }

  # Use the verified Ubuntu Server 24.04 LTS Gen2 image.
  source_image_reference {

    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202610160"
  }

  # Configure the operating system disk.
  os_disk {
    name                 = "osdisk-agent-poc-uaen-01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # Apply the standard organizational tags.
  tags = local.common_tags
}