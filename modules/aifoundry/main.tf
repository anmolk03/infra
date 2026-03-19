resource "azurerm_ai_foundry" "ai_foundry" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  storage_account_id    = var.storage_id
  key_vault_id          = var.key_vault_id
  public_network_access = var.public_network_access

  identity {
    type = "SystemAssigned"
  }
  //tags = var.tags
}
