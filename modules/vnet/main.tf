# ------------------------------------------------------------
# Reusable Azure Virtual Network Module
# File: modules/vnet/main.tf
# Purpose: Create one VNet and its subnets.
# ------------------------------------------------------------

# Create the virtual network using the inputs supplied by the root module.
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space

  # Apply the mandatory organizational tags.
  tags = var.tags
}

# Create each subnet defined in the module's subnets map.
# for_each allows the same module to create different subnet layouts.
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  # Use the subnet-specific setting when supplied.
  # Otherwise, preserve the provider's existing default behavior.
  default_outbound_access_enabled = try(
    each.value.default_outbound_access_enabled,
    null
  )
}