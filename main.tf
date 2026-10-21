# ------------------------------------------------------------
# PE-01 Landing Zone — Hub Virtual Network
# Purpose: Deploy the shared hub network using the reusable VNet module.
# ------------------------------------------------------------

# ------------------------------------------------------------
# PE-01 Landing Zone — Network Resource Group
# Purpose: Provide a dedicated scope for landing-zone networking.
# ------------------------------------------------------------

resource "azurerm_resource_group" "network" {
  # Follow the POC resource naming convention.
  name = "rg-network-poc-uaen-01"

  # Use the deployment region configured in the root variables.
  location = var.location

  # Apply the standard organizational tags.
  tags = local.common_tags
}



module "hub" {
  # Reuse the standardized VNet implementation.
  source = "./modules/vnet"

  # Follow the POC Azure naming convention.
  vnet_name = "vnet-hub-poc-uaen-01"

  # Use the resource group managed by this root configuration.
  resource_group_name = azurerm_resource_group.network.name

  # Deploy the hub in UAE North.
  location = var.location

  # Reserve the hub's address space.
  address_space = ["10.0.0.0/22"]

  # Define the hub subnet layout.
  # Preserve existing subnets and add subnets.
  subnets = {
    # Reserved for a future Azure Firewall deployment.
    AzureFirewallSubnet = {
      address_prefixes = ["10.0.0.0/26"]
    }

    # Reserved for a future Azure Bastion deployment.
    AzureBastionSubnet = {
      address_prefixes = ["10.0.0.64/26"]
    }

    # Existing shared hub services.
    snet-hub-shared = {
      address_prefixes = ["10.0.1.0/24"]
    }

    # Terraform state private endpoint.
    snet-pe = {
      address_prefixes                = ["10.0.2.0/26"]
      default_outbound_access_enabled = false
    }

    # Self-hosted Azure DevOps agent.
    snet-agents = {
      address_prefixes                = ["10.0.2.64/26"]
      default_outbound_access_enabled = false
    }
  }

  # Apply the required organizational tags.
  tags = local.common_tags
}

# ------------------------------------------------------------
# PE-01 Landing Zone — Spoke Virtual Network
# Purpose: Host workload subnets in an isolated spoke network.
# ------------------------------------------------------------

module "spoke" {
  # Reuse the same VNet module used by the hub.
  source = "./modules/vnet"

  # Follow the landing-zone naming convention.
  vnet_name = "vnet-spoke-poc-uaen-01"

  # Place the spoke in the existing networking resource group.
  resource_group_name = azurerm_resource_group.network.name

  # Deploy in the same region as the hub for this POC.
  location = var.location

  # Assign the spoke its own non-overlapping address space.
  address_space = ["10.1.0.0/22"]

  # Define the workload subnet layout.
  subnets = {
    snet-web = {
      address_prefixes = ["10.1.0.0/24"]
    }

    snet-app = {
      address_prefixes = ["10.1.1.0/24"]
    }
  }

  # Apply the mandatory organizational tags.
  tags = local.common_tags
}

# ------------------------------------------------------------
# PE-01 Landing Zone — Hub-to-Spoke VNet Peering
# Purpose: Allow the hub VNet to communicate with the spoke.
# ------------------------------------------------------------

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name = "peer-hub-to-spoke"

  # Identify the source VNet: the hub.
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = module.hub.vnet_name

  # Identify the destination VNet: the spoke.
  remote_virtual_network_id = module.spoke.vnet_id

  # Permit forwarded traffic across this peering.
  allow_forwarded_traffic = true

  # Configure gateway transit on the hub side only.
  allow_gateway_transit = true

  # Do not use a remote gateway.
  use_remote_gateways = false
}

# ------------------------------------------------------------
# PE-01 Landing Zone — Spoke-to-Hub VNet Peering
# Purpose: Allow the spoke VNet to communicate with the hub.
# ------------------------------------------------------------

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name = "peer-spoke-to-hub"

  # Identify the source VNet: the spoke.
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = module.spoke.vnet_name

  # Identify the destination VNet: the hub.
  remote_virtual_network_id = module.hub.vnet_id

  # Permit forwarded traffic across this peering.
  allow_forwarded_traffic = true

  # Gateway transit is enabled on the hub side only.
  allow_gateway_transit = false

  # Do not use a remote gateway.
  use_remote_gateways = false
}

# ------------------------------------------------------------
# Phase 2 — NAT Gateway Public IP
# Purpose: Provide a stable outbound public IP for the agent subnet.
# ------------------------------------------------------------

resource "azurerm_public_ip" "nat_agents" {
  name                = "pip-nat-agents-poc-uaen-01"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location

  # NAT Gateway requires a Standard SKU public IP.
  allocation_method = "Static"
  sku               = "Standard"

  # Keep resource ownership consistent with the landing zone.
  tags = local.common_tags
}

# ------------------------------------------------------------
# Phase 2 — Agent Subnet NAT Gateway
# Purpose: Provide explicit outbound connectivity for the agent subnet.
# ------------------------------------------------------------

resource "azurerm_nat_gateway" "agents" {
  name                = "nat-agents-poc-uaen-01"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location

  # Standard NAT Gateway configuration.
  sku_name = "Standard"

  # Keep the initial configuration simple for the POC.
  idle_timeout_in_minutes = 10

  # Apply organizational tags.
  tags = local.common_tags
}

# ------------------------------------------------------------
# Phase 2 — NAT Gateway Public IP Association
# Purpose: Assign the static public IP to the NAT Gateway.
# ------------------------------------------------------------

resource "azurerm_nat_gateway_public_ip_association" "agents" {
  nat_gateway_id       = azurerm_nat_gateway.agents.id
  public_ip_address_id = azurerm_public_ip.nat_agents.id
}

# ------------------------------------------------------------
# Phase 2 — Agent Subnet NAT Gateway Association
# Purpose: Provide outbound NAT for snet-agents.
# ------------------------------------------------------------

resource "azurerm_subnet_nat_gateway_association" "agents" {
  subnet_id      = module.hub.subnet_ids["snet-agents"]
  nat_gateway_id = azurerm_nat_gateway.agents.id
}