resource "azurerm_resource_group" "rg" {
  name     = "rg-robertdeboer-sbx"
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
