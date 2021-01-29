resource "local_file" "ssh_config" {
  content  = templatefile("./templates/ssh_config.tpl",
  {
    ip       = azurerm_public_ip.publicip.ip_address,
    username = var.admin_username
  } )
  filename = "./ssh_config"
}
