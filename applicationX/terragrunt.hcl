terraform {
  source = "../modules"
}

inputs = {
  admin_username = "plankton"
  admin_password = "Password1234!"
  prefix         = "app-x-"
  tags           = {
    environment = "production"
    application = "X"
  }
}
