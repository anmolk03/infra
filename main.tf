terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.28.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "xyz"
}

module "storage" {
  source   = "./modules/storageAccount"
  name     = "storageaftest001"
  location = "japaneast"
  resource_group_name = "playgroundcleansub0"
  account_tier        = "Standard"
  account_replication = "LRS"
}
