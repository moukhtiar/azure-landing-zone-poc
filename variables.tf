# Azure region for the landing zone.

variable "location" {
  description = "Azure region for the landing zone resources."
  type        = string
  default     = "uaenorth"
}

# Environment identifier used in resource names and tags.

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "poc"

  validation {
    condition     = contains(["dev", "test", "lab", "poc", "prod"], var.environment)
    error_message = "Environment must be dev, test, lab, poc, or prod."
  }
}

# Team or engineer responsible for the infrastructure.

variable "owner" {
  description = "Owner responsible for the landing zone."
  type        = string
}

# Cost allocation identifier.

variable "costcenter" {
  description = "Cost center used for resource allocation."
  type        = string
}

# Workload identifier used for naming and tagging.

variable "workload" {
  description = "Workload identifier for the landing zone."
  type        = string
  default     = "landingzone"
}

# SSH public key used when provisioning the agent VM.
variable "agent_admin_ssh_public_key" {
  description = "SSH public key for the Azure DevOps agent VM administrator."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID used for deployment."
  type        = string
}
variable "tfstate_storage_account_id" {
  description = "Full Azure resource ID of the existing Terraform state Storage Account."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Storage/storageAccounts/[^/]+$", var.tfstate_storage_account_id))
    error_message = "Provide a valid Azure Storage Account resource ID."
  }
}
