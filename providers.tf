provider "azurerm" {
  features {}
}

variable "checkly_api_key" {}

provider "checkly" {
  api_key = var.checkly_api_key
}
