resource "azurerm_resource_group" "rg" {
  name     = "rg-robertdebock-sbx"
  location = "westeurope"
  tags     = {
    costcenter   = "infra"
    solution     = "education"
    owner        = "Robert de Bock"
    environment  = "sbx"
    creationdate = "23/12/2020"
    creator      = "Robert de Bock"
  }
}
