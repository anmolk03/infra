data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku
  purge_protection_enabled    = var.purge_protection
  public_network_access_enabled = false

  # Enable Azure RBAC authorization
  //enable_rbac_authorization = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  //tags = var.tags
}