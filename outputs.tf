output "public_ip_address" {
  value = data.azurerm_public_ip.publicip.ip_address
}

output "ssh_connect_string" {
  value = "ssh ${var.admin_username}@${data.azurerm_public_ip.publicip.ip_address}"
}

output "hello" {
  value = "wereld"
}