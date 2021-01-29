terraform {
  source = "../modules"
}

inputs = {
  admin_username = "plankton"
  admin_password = "Password1234!"
  location       = "northeurope"
  prefix         = "app-y-"
  tags           = {
    environment = "development"
    application = "Y"
  }
}
