# 1. Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  numeric = true 
  special = false
}

# 2. Modern Container Group (Private VNet Injection)
resource "azurerm_container_group" "backend" {
  # Added suffix to name for uniqueness
  name                = "employee-backend-aci-${random_string.suffix.result}"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"
  os_type             = "Linux"
  
  # REMOVED: dns_name_label (This fixes the 'DnsNameLabelNotSupportedForInternalIPAddress' error)
  
  ip_address_type     = "Private"

  # UPDATED: Direct subnet reference (This fixes the deprecation and 400 error)
  subnet_ids          = [azurerm_subnet.aci_subnet.id]

  container {
    name   = "backend"
    image  = "mydemoacr2026asdfg.azurecr.io/backend:latest"
    cpu    = 0.5
    memory = 1.0

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      DBHOST           = azurerm_postgresql_flexible_server.db.fqdn
      DBPORT           = "5432"
      DBDIALECT        = "postgres"
      DBNAME           = "employeedb"
      DBUSERNAME       = azurerm_postgresql_flexible_server.db.administrator_login
      DBPASSWORD       = azurerm_postgresql_flexible_server.db.administrator_password
      NODE_ENV         = "production"
      APPLICATION_HOST = "0.0.0.0"
      APPLICATION_PORT = "80"
      WHITELIST_URLS   = "10.0.4.0/24" 
    }
  }

  tags = {
    Environment = "Production"
    Project     = "EmployeeApp"
  }
}
