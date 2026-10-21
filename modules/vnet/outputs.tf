# ------------------------------------------------------------
# Reusable Azure Virtual Network Module
# File: modules/vnet/outputs.tf
# Purpose: Expose useful VNet attributes to the root module.
# ------------------------------------------------------------

# Export the Azure resource ID for peering and other dependencies.
output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

# Export the VNet name for references and documentation.
output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

# Export the configured address space.
output "address_space" {
  description = "Address ranges assigned to the virtual network."
  value       = azurerm_virtual_network.this.address_space
}

# Export subnet IDs so other resources can reference individual subnets.
output "subnet_ids" {
  description = "Map of subnet names to their Azure resource IDs."
  value = {
    for name, subnet in azurerm_subnet.this :
    name => subnet.id
  }
}