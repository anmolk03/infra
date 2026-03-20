##sudo ./svc.sh install
##sudo ./svc.sh start

###curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
##wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && sudo apt-get update && sudo apt-get install terraform -y
##sudo apt-get update && sudo apt-get install -y git unzip jq

##Create storage for state via portal

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.70.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "playgroundcleansub0"
    storage_account_name = "tfstatesa123"
    container_name       = "tfstate" 
    key                  = terraform.tfstate# This is the name of the state file it will create
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_container_registry" "acr" {
  name                = "mydemoacr2026asdfg" 
  resource_group_name = "playgroundcleansub0"
  location            = "centralindia"
  sku                 = "Standard"
  admin_enabled       = true
}

########

resource "azurerm_subnet" "aks_subnet" {
  name                 = "subnet-aks"
  resource_group_name  = "playgroundcleansub0"
  virtual_network_name = "agentpool-vnet"  
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aci_subnet" {
  name                 = "subnet-aci"
  resource_group_name  = "playgroundcleansub0"
  virtual_network_name = "agentpool-vnet"
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "aci-delegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "postgres_subnet" {
  name                 = "subnet-postgres"
  resource_group_name  = "playgroundcleansub0"
  virtual_network_name = "agentpool-vnet"  
  address_prefixes     = ["10.0.3.0/24"]

  delegation {
    name = "postgres-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}




# AKS (Private)

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-private-cluster"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"
  dns_prefix          = "aksplayground"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  private_cluster_enabled = true

  network_profile {
    network_plugin = "azure"
  }
}



# PostgreSQL Flexible Server + DB
resource "azurerm_postgresql_flexible_server" "db" {
  name                = "mydbserver"
  resource_group_name = "playgroundcleansub0"
  location            = "centralindia"
  version             = "13"
  administrator_login = "adminuser"
  administrator_password = "ComplexPassword123!"

  sku_name   = "B_Standard_B1ms"  # Burstable tier, works in older provider
  storage_mb = 32768

  backup_retention_days = 7

  tags = {
    environment = "dev"
  }
}

# PostgreSQL Flexible Server Database
resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "employeedb"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.UTF-8"  # Linux-style, valid for PostgreSQL
}


/*
resource "azurerm_postgresql_flexible_server" "db" {
  name                = "employeedbserver2026"
  resource_group_name = "playgroundcleansub0"
  location            = "centralindia"

  administrator_login    = "adminuser"
  administrator_password = "ComplexPassword123!"

  sku_name   = "B_Standard_B1ms"
  version    = "14"
  storage_mb = 32768

  delegated_subnet_id           = azurerm_subnet.postgres_subnet.id
  public_network_access_enabled = false
}

resource "azurerm_postgresql_flexible_database" "db" {
  name      = "employeedb"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
*/


# Key Vault
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "kv-playground-2026"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = false
}


/*

####################################
# NSG for ACI subnet
####################################
resource "azurerm_network_security_group" "aci_nsg" {
  name                = "aci-nsg"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"

  security_rule {
    name                       = "Allow-AKS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.1.0/24" # AKS subnet
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "Deny-All"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
  }
}

####################################
# Attach NSG to ACI subnet
####################################
resource "azurerm_subnet_network_security_group_association" "aci_assoc" {
  subnet_id                 = azurerm_subnet.aci_subnet.id
  network_security_group_id = azurerm_network_security_group.aci_nsg.id
}

# ACI (Backend)
resource "azurerm_container_group" "backend" {
  name                = "backend-aci"
  location            = "centralindia"
  resource_group_name = "playgroundcleansub0"

  os_type         = "Linux"
  ip_address_type = "Private"
  subnet_ids      = [azurerm_subnet.aci_subnet.id]

  container {
    name   = "backend"
    image  = "${azurerm_container_registry.acr.login_server}/backend:latest"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      DBHOST            = azurerm_postgresql_flexible_server.db.fqdn
      DBPORT            = "5432"
      DBDIALECT         = "postgres"
      DBNAME            = "employeedb"
      DBUSERNAME        = "adminuser"
      DBPASSWORD        = "ComplexPassword123!"
      NODE_ENV          = "production"
      APPLICATION_HOST  = "0.0.0.0"
      APPLICATION_PORT  = "80"
      WHITELIST_URLS    = "https://frontend.example.com" # 🔴 your ingress URL
    }
  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }
}
*/
