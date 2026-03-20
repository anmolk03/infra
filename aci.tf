# 1. Generate random suffix for unique DNS label
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  numeric = true # 'number' is deprecated in newer versions, use 'numeric'
  special = false
}

# 2. Corrected Network Profile
resource "azurerm_network_profile" "backend_aci_profile" {
  name                = "backend-aci-np"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"

  container_network_interface {
    name = "backend-aci-nic"

    # THIS BLOCK IS MANDATORY
    ip_configuration {
      name      = "internal"
      subnet_id = "/subscriptions/ce1fe2d6-685f-4758-a44e-d005c9d82354/resourceGroups/playgroundcleansub0/providers/Microsoft.Network/virtualNetworks/agentpool-vnet/subnets/subnet-aci"
    }
  }
}

# 3. Corrected Container Group
resource "azurerm_container_group" "backend" {
  name                = "employee-backend-aci"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"
  os_type             = "Linux"
  
  # Optional: dns_name_label is usually for Public IPs. 
  # For Private IPs in a VNet, it may be ignored, but keeping it doesn't hurt.
  dns_name_label      = "backend-aci-${random_string.suffix.result}" 
  
  ip_address_type     = "Private"

  # REMOVED: subnet_ids (This causes conflicts when using network_profile_id)
  network_profile_id  = azurerm_network_profile.backend_aci_profile.id

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
      
      # NOTE: Ensure this matches the attribute name in your postgres resource
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
