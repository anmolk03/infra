resource "azurerm_container_group" "backend" {
  name                = "employee-backend-aci"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"
  os_type             = "Linux"
  dns_name_label      = "backend-aci-${random_string.suffix.result}" # optional for internal dns
  ip_address_type     = "Private"  # private IP only
  subnet_ids          = ["/subscriptions/ce1fe2d6-685f-4758-a44e-d005c9d82354/resourceGroups/playgroundcleansub0/providers/Microsoft.Network/virtualNetworks/agentpool-vnet/subnets/aci_subnet"]

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
      DBPASSWORD       = azurerm_postgresql_flexible_server.db.administrator_login_password
      NODE_ENV         = "production"
      APPLICATION_HOST = "0.0.0.0"
      APPLICATION_PORT = "80"
      # Only frontend subnet allowed
      WHITELIST_URLS   = "10.0.4.0/24"  # Replace with your frontend AKS subnet CIDR
    }
  }

  tags = {
    Environment = "Production"
    Project     = "EmployeeApp"
  }

  network_profile_id = azurerm_network_profile.backend_aci_profile.id
}

# Optional: network profile for ACI in your VNet
resource "azurerm_network_profile" "backend_aci_profile" {
  name                = "backend-aci-np"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"

  container_network_interface {
    name                      = "backend-aci-nic"
    subnet_id                 = "/subscriptions/ce1fe2d6-685f-4758-a44e-d005c9d82354/resourceGroups/playgroundcleansub0/providers/Microsoft.Network/virtualNetworks/agentpool-vnet/subnets/aci_subnet"
    ip_configuration_name     = "internal"
    private_ip_address_allocation = "Dynamic"
  }
}

# Generate random suffix for unique DNS label
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  number  = true
  special = false
}
