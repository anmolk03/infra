resource "azurerm_cognitive_account" "doc_intel" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FormRecognizer" # This is the "Document Intelligence" kind
  sku_name            = var.sku_name

  public_network_access_enabled = false
  custom_subdomain_name         = var.name

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Private Endpoint to link it to your VNet
resource "azurerm_private_endpoint" "pe" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.doc_intel.id
    subresource_names              = ["account"]
  }
}