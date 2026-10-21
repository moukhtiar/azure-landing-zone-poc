# ------------------------------------------------------------
# PE-01 Landing Zone — Terraform Outputs
# Purpose: Expose key resource identifiers for verification
#          and future Terraform configurations.
# ------------------------------------------------------------

# ------------------------------------------------------------
# Network Resource Group
# ------------------------------------------------------------

output "network_resource_group_name" {
  description = "Name of the landing-zone networking resource group."
  value       = azurerm_resource_group.network.name
}

# ------------------------------------------------------------
# Hub Virtual Network
# ------------------------------------------------------------

output "hub_vnet_name" {
  description = "Name of the shared hub virtual network."
  value       = module.hub.vnet_name
}

output "hub_vnet_id" {
  description = "Azure resource ID of the hub virtual network."
  value       = module.hub.vnet_id
}

output "hub_address_space" {
  description = "Address space assigned to the hub virtual network."
  value       = module.hub.address_space
}

# ------------------------------------------------------------
# Spoke Virtual Network
# ------------------------------------------------------------

output "spoke_vnet_name" {
  description = "Name of the workload spoke virtual network."
  value       = module.spoke.vnet_name
}

output "spoke_vnet_id" {
  description = "Azure resource ID of the spoke virtual network."
  value       = module.spoke.vnet_id
}

output "spoke_address_space" {
  description = "Address space assigned to the spoke virtual network."
  value       = module.spoke.address_space
}

# ------------------------------------------------------------
# Spoke Subnets
# ------------------------------------------------------------

output "spoke_subnet_ids" {
  description = "Names and Azure resource IDs of the spoke subnets."
  value       = module.spoke.subnet_ids
}

# ------------------------------------------------------------
# Network Security Groups
# ------------------------------------------------------------

output "web_nsg_id" {
  description = "Azure resource ID of the web subnet NSG."
  value       = azurerm_network_security_group.web.id
}

output "app_nsg_id" {
  description = "Azure resource ID of the application subnet NSG."
  value       = azurerm_network_security_group.app.id
}