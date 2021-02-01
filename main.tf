resource "azurerm_resource_group" "default" {
 name     = var.project_name
 location = var.location
}

resource "azurerm_network_security_group" "default" {
  name                = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name

  security_rule {
    name                       = "http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "icmp"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_virtual_network" "default" {
 name                = var.project_name
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.default.location
 resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "default" {
 name                 = var.project_name
 resource_group_name  = azurerm_resource_group.default.name
 virtual_network_name = azurerm_virtual_network.default.name
 address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "loadbalancer" {
 name                = var.project_name
 location            = azurerm_resource_group.default.location
 resource_group_name = azurerm_resource_group.default.name
 allocation_method   = "Static"
}

resource "azurerm_public_ip" "virtual_machine" {
  count               = var.backend_count
  name                = "${var.project_name}-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "default" {
 name                = var.project_name
 location            = azurerm_resource_group.default.location
 resource_group_name = azurerm_resource_group.default.name

 frontend_ip_configuration {
   name                 = var.project_name
   public_ip_address_id = azurerm_public_ip.loadbalancer.id
 }
}

resource "azurerm_lb_rule" "ssh" {
  resource_group_name            = azurerm_resource_group.default.name
  loadbalancer_id                = azurerm_lb.default.id
  name                           = "ssh"
  protocol                       = "tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.default.frontend_ip_configuration[0].name
}

resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.default.name
  loadbalancer_id                = azurerm_lb.default.id
  name                           = "http"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.default.frontend_ip_configuration[0].name
}

resource "azurerm_lb_rule" "https" {
  resource_group_name            = azurerm_resource_group.default.name
  loadbalancer_id                = azurerm_lb.default.id
  name                           = "https"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.default.frontend_ip_configuration[0].name
}

resource "azurerm_lb_backend_address_pool" "default" {
 resource_group_name = azurerm_resource_group.default.name
 loadbalancer_id     = azurerm_lb.default.id
 name                = var.project_name
}

resource "azurerm_network_interface" "default" {
 count               = var.backend_count
 name                = "${var.project_name}-${count.index}"
 location            = azurerm_resource_group.default.location
 resource_group_name = azurerm_resource_group.default.name

 ip_configuration {
   name                          = var.project_name
   subnet_id                     = azurerm_subnet.default.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_managed_disk" "default" {
 count                = var.backend_count
 name                 = "${var.project_name}-${count.index}"
 location             = azurerm_resource_group.default.location
 resource_group_name  = azurerm_resource_group.default.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
}

resource "azurerm_availability_set" "avset" {
 name                         = var.project_name
 location                     = azurerm_resource_group.default.location
 resource_group_name          = azurerm_resource_group.default.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
}

resource "azurerm_virtual_machine" "default" {
 count                 = var.backend_count
 name                  = "${var.project_name}-${count.index}"
 location              = azurerm_resource_group.default.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.default.name
 network_interface_ids = [element(azurerm_network_interface.default.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "18.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "${var.project_name}-os-${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 storage_data_disk {
   name              = "${var.project_name}-data-${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "8"
 }

 storage_data_disk {
   name            = element(azurerm_managed_disk.default.*.name, count.index)
   managed_disk_id = element(azurerm_managed_disk.default.*.id, count.index)
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = element(azurerm_managed_disk.default.*.disk_size_gb, count.index)
 }

 os_profile {
   computer_name  = "${var.project_name}-${count.index}"
   admin_username = var.admin_username
   admin_password = var.admin_password
   custom_data    = file("bootstrap.sh")
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "staging"
 }
}
