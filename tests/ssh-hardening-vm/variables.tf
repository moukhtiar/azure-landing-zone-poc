variable "subscription_id" {
  description = "Azure subscription ID used for the disposable SSH hardening test."
  type        = string
}

variable "location" {
  description = "Azure region for the disposable test VM."
  type        = string
  default     = "uaenorth"
}

variable "resource_group_name" {
  description = "Existing resource group containing the agent subnet."
  type        = string
  default     = "rg-network-poc-uaen-01"
}

variable "vnet_name" {
  description = "Existing hub virtual network."
  type        = string
  default     = "vnet-hub-poc-uaen-01"
}

variable "subnet_name" {
  description = "Existing subnet used for the disposable test VM."
  type        = string
  default     = "snet-agents"
}

variable "admin_username" {
  description = "Local administrator account for the disposable Linux VM."
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the disposable test VM."
  type        = string
  sensitive   = true
}
