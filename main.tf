resource "azurerm_resource_group" "rg" {
  name     = "rg-robertdebock-sbx"
  location = "westeurope"
  tags     = {
    costcenter   = "infrastructuur"
    solution     = "terraform opleiding"
    owner        = "Robert de Bock"
    environment  = "sbx"
    creationdate = "15/06/2021"
    creator      = "Robert de Bock"
  }
}
