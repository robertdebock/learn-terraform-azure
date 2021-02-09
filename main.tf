# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-robertdebock-sbx"
  location = "westeurope"
  tags     = {
    costcenter   = "infra"
    solution     = "terraform opleiding"
    owner        = "Robert de Bock"
    environment  = "sbx"
    creationdate = "9/02/2021"
    creator      = "Robert de Bock"
  }
}
