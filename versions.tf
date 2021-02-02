# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
    checkly = {
      source = "checkly/checkly"
      version = "0.8.1-rc2"
    }
  }
}
