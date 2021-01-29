# Configure the Azure provider
terraform {
  # backend "azurerm" {
  # resource_group_name  = "rg-terraform-cmn-sbx"
  # storage_account_name = "stterraformcmnsbx"
  # container_name       = "c-terraform"
  # key                  = "rg-robertdebock-sbx.tfstate"
  # }
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
