output "loadbalancer_ip_address" {
  value = azurerm_public_ip.loadbalancer.ip_address
}

output "virtual_machine_ip_addresses" {
  value = azurerm_public_ip.virtual_machine.*.ip_address
}
