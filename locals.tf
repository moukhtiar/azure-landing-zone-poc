locals {

  # Mandatory tags applied to resources managed by this project.

  common_tags = {
    owner       = var.owner
    environment = var.environment
    costcenter  = var.costcenter
    workload    = var.workload
    managed-by  = "terraform"
  }

}
