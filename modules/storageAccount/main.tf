resource "azurerm_storage_account" "storage" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication
  public_network_access_enabled = false
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = true

  network_rules {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]
  }
  //tags = var.tags
}