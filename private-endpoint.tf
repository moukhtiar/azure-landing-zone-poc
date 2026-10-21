# Private endpoint for the Terraform state Storage Account Blob service.
resource "azurerm_private_endpoint" "tfstate_blob" {
  name                = "pe-tfstate-blob-poc-uaen-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  subnet_id           = "${module.hub.vnet_id}/subnets/snet-pe"

  # Connect the private endpoint to the Storage Account Blob service.
  private_service_connection {
    name                           = "psc-tfstate-blob-poc-uaen-01"
    private_connection_resource_id = var.tfstate_storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  # Associate the private endpoint with the existing private DNS zone.
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = local.common_tags
}
