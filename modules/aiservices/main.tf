resource "azurerm_ai_services" "ai_services" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  sku_name              = var.sku
  public_network_access = var.public_network_access
  custom_subdomain_name = var.custom_subdomain_name

  identity {
    type = "SystemAssigned"
  }
  //tags = var.tags
}