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
      version = "~> 3.0"
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
  name                = "mydemoacr2026" 
  resource_group_name = "playgroundcleansub0"e
  location            = "centralindia"
  sku                 = "Standard"
  admin_enabled       = true
}
