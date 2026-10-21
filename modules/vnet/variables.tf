# ------------------------------------------------------------
# Reusable Azure Virtual Network Module
# File: modules/vnet/variables.tf
# Purpose: Define and validate the module's required inputs.
# ------------------------------------------------------------

# Azure resource name for this virtual network.
variable "vnet_name" {
  description = "Name of the Azure virtual network."
  type        = string

  validation {
    condition     = length(var.vnet_name) >= 2 && length(var.vnet_name) <= 64
    error_message = "The virtual network name must contain between 2 and 64 characters."
  }
}

# Resource group that owns the virtual network.
variable "resource_group_name" {
  description = "Name of the existing resource group for the virtual network."
  type        = string
}

# Azure region where the virtual network will be deployed.
variable "location" {
  description = "Azure region for the virtual network."
  type        = string
}

# Address space allocated to the virtual network.
variable "address_space" {
  description = "List of CIDR address ranges assigned to the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one virtual network address range must be provided."
  }
}

# Subnets created inside this virtual network.
# Each subnet has a name and one or more address prefixes.
variable "subnets" {
  description = "Map of subnet names to their address prefixes."

  type = map(object({
    address_prefixes                = list(string)
    default_outbound_access_enabled = optional(bool)
  }))

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) :
      length(subnet.address_prefixes) > 0
    ])

    error_message = "Every subnet must contain at least one address prefix."
  }
}

# Common platform tags inherited from the root configuration.
variable "tags" {
  description = "Mandatory organizational tags applied to the virtual network."
  type        = map(string)

  validation {
    condition = alltrue([
      for required_tag in [
        "owner",
        "environment",
        "costcenter",
        "workload",
        "managed-by"
      ] : contains(keys(var.tags), required_tag)
    ])

    error_message = "The tags map must contain owner, environment, costcenter, workload, and managed-by."
  }
}