# ------------------------------------------------------------
# PE-01 Landing Zone — Web Subnet Network Security Group
# Purpose: Control inbound traffic entering the web subnet.
# ------------------------------------------------------------

resource "azurerm_network_security_group" "web" {
  # Identify this NSG using the POC naming convention.
  name = "nsg-web-poc-uaen-01"

  # Keep the NSG in the landing-zone networking resource group.
  resource_group_name = azurerm_resource_group.network.name

  # Deploy the NSG in the configured Azure region.
  location = var.location

  # Apply the standard organizational tags.
  tags = local.common_tags
}

# ------------------------------------------------------------
# PE-01 Landing Zone — Application Subnet Network Security Group
# Purpose: Protect the application subnet with explicit rules.
# ------------------------------------------------------------

resource "azurerm_network_security_group" "app" {
  # Identify this NSG using the POC naming convention.
  name = "nsg-app-poc-uaen-01"

  # Keep the NSG in the landing-zone networking resource group.
  resource_group_name = azurerm_resource_group.network.name

  # Deploy the NSG in the configured Azure region.
  location = var.location

  # Apply the standard organizational tags.
  tags = local.common_tags
}

# ------------------------------------------------------------
# Web NSG — Explicit Inbound Deny
# Purpose: Deny inbound traffic not explicitly permitted.
# ------------------------------------------------------------

resource "azurerm_network_security_rule" "web_deny_all_inbound" {
  name = "Deny-All-Inbound"

  # Priority 4000 places this rule before Azure's default
  # inbound deny rule, which has priority 65500.
  priority = 4000

  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  # Match every source and destination port.
  source_port_range      = "*"
  destination_port_range = "*"

  # Apply the rule to all inbound sources and destinations.
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.web.name
}

# ------------------------------------------------------------
# App NSG — Allow Web-to-App Traffic
# Purpose: Permit TCP 8080 from the web subnet only.
# ------------------------------------------------------------

resource "azurerm_network_security_rule" "app_allow_web_tcp_8080" {
  name = "Allow-Web-To-App-TCP-8080"

  # Evaluate this specific allowance before the deny-all rule.
  priority = 100

  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "8080"

  # Restrict the source to the web subnet.
  source_address_prefix = "10.1.0.0/24"

  # Restrict the destination to the application subnet.
  destination_address_prefix = "10.1.1.0/24"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.app.name
}

# ------------------------------------------------------------
# App NSG — Explicit Inbound Deny
# Purpose: Deny inbound traffic not permitted by earlier rules.
# ------------------------------------------------------------

resource "azurerm_network_security_rule" "app_deny_all_inbound" {
  name = "Deny-All-Inbound"

  # This rule follows the TCP 8080 allowance at priority 100.
  priority = 4000

  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.app.name
}

# ------------------------------------------------------------
# PE-01 Landing Zone — Web Subnet NSG Association
# Purpose: Enforce the web NSG policy on the web subnet.
# ------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "web" {
  # Identify the web subnet created by the reusable spoke module.
  subnet_id = module.spoke.subnet_ids["snet-web"]

  # Attach the web-specific network security group.
  network_security_group_id = azurerm_network_security_group.web.id
}

# ------------------------------------------------------------
# PE-01 Landing Zone — App Subnet NSG Association
# Purpose: Enforce the app NSG policy on the application subnet.
# ------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "app" {
  # Identify the application subnet created by the spoke module.
  subnet_id = module.spoke.subnet_ids["snet-app"]

  # Attach the application-specific network security group.
  network_security_group_id = azurerm_network_security_group.app.id
}

# ------------------------------------------------------------
# PE-01 — Self-hosted Azure DevOps Agent NSG
# Purpose: Protect the dedicated agent subnet.
# ------------------------------------------------------------

resource "azurerm_network_security_group" "agents" {
  name                = "nsg-agents-poc-uaen-01"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location

  # Apply the standard organizational tags.
  tags = local.common_tags
}

# ------------------------------------------------------------
# Agent NSG — Explicit Inbound Deny
# Purpose: Deny unsolicited inbound traffic.
# ------------------------------------------------------------

resource "azurerm_network_security_rule" "agents_deny_all_inbound" {
  name      = "Deny-All-Inbound"
  priority  = 4000
  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.agents.name
}

# ------------------------------------------------------------
# Agent NSG — Allow Required Outbound HTTPS
# Purpose: Permit HTTPS connections initiated by the agent.
# ------------------------------------------------------------

resource "azurerm_network_security_rule" "agents_allow_outbound_https" {
  name      = "Allow-Outbound-HTTPS"
  priority  = 100
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "443"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.agents.name
}

# Deny outbound traffic that is not permitted by higher-priority rules.
resource "azurerm_network_security_rule" "agents_deny_all_outbound" {
  name                       = "Deny-All-Outbound"
  priority                   = 4000
  direction                  = "Outbound"
  access                     = "Deny"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.agents.name
}

# ------------------------------------------------------------
# Agent Subnet — NSG Association
# Purpose: Apply the agent NSG to snet-agents.
# ------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "agents" {
  subnet_id = module.hub.subnet_ids["snet-agents"]

  network_security_group_id = azurerm_network_security_group.agents.id
}