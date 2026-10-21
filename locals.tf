locals {

  # Azure region abbreviations used in resource names.

  # Keep these mappings consistent across the project.

  region_abbreviations = {
    uaenorth   = "uaen"
    uaecentral = "uaec"
  }

  # Resolve the short region identifier from the selected Azure region.

  region_short = lookup(
    local.region_abbreviations,
    var.location,
    null
  )

  # Mandatory tags applied to resources managed by this project.

  common_tags = {
    owner       = var.owner
    environment = var.environment
    costcenter  = var.costcenter
    workload    = var.workload
    managed-by  = "terraform"
  }

  # Standardized resource naming components.

  naming = {
    environment = var.environment
    region      = local.region_short
    sequence    = var.sequence
  }
}
