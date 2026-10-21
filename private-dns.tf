# ------------------------------------------------------------
# PE-01 — Private DNS Zone for Azure Storage Blob
# Purpose: Resolve Storage Blob endpoints to private IP addresses.
# ------------------------------------------------------------

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags
}

# ------------------------------------------------------------
# PE-01 — Hub VNet Link
# Purpose: Enable private DNS resolution from the hub VNet.
# ------------------------------------------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "hub_blob" {
  name                  = "link-hub-blob-poc-uaen-01"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.hub.vnet_id

  registration_enabled = false

  tags = local.common_tags
}

# ------------------------------------------------------------
# PE-01 — Spoke VNet Link
# Purpose: Enable private DNS resolution from the spoke VNet.
# ------------------------------------------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_blob" {
  name                  = "link-spoke-blob-poc-uaen-01"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.spoke.vnet_id

  registration_enabled = false

  tags = local.common_tags
}