# Create a resource group
resource "azurerm_resource_group" "default" {
  name     = var.project_name
  location = var.location
  tags = {
    project_name = var.project_name
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "default" {
    name                = var.project_name
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.default.name
}

# Create a subnet
resource "azurerm_subnet" "default" {
  name                 = var.project_name
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP for loadbalancer
resource "azurerm_public_ip" "loadbalancer" {
  name                = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
}

# Create public IPs for the virtual machines.
resource "azurerm_public_ip" "virtual_machine" {
  count               = var.backend_count
  name                = "${var.project_name}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
}

# Create a loadbalancer.
resource "azurerm_lb" "default" {
 name                = var.project_name
 location            = var.location
 resource_group_name = azurerm_resource_group.default.name

 frontend_ip_configuration {
   name                 = var.project_name
   public_ip_address_id = azurerm_public_ip.loadbalancer.id
 }
}

resource "azurerm_availability_set" "default" {
  name                         = var.project_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.default.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

}

# Create a backend address pool.
resource "azurerm_lb_backend_address_pool" "default" {
 resource_group_name = azurerm_resource_group.default.name
 loadbalancer_id     = azurerm_lb.default.id
 name                = var.project_name
}

# Create an http probe
resource "azurerm_lb_probe" "http" {
  resource_group_name = azurerm_resource_group.default.name
  loadbalancer_id     = azurerm_lb.default.id
  name                = "http"
  protocol            = "http"
  port                = 80
  request_path        = "/"
}

# Create a rule for http
resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.default.name
  loadbalancer_id                = azurerm_lb.default.id
  name                           = "http"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.default.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.default.id
  probe_id                       = azurerm_lb_probe.http.id
}

# Create a rule for https
resource "azurerm_lb_rule" "https" {
  resource_group_name            = azurerm_resource_group.default.name
  loadbalancer_id                = azurerm_lb.default.id
  name                           = "https"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  backend_address_pool_id        = azurerm_lb_backend_address_pool.default.id
  frontend_ip_configuration_name = azurerm_lb.default.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.http.id
}

# Create network interface
resource "azurerm_network_interface" "default" {
  count                     = var.backend_count
  name                      = "${var.project_name}-${count.index}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.default.name

  ip_configuration {
    name                          = var.project_name
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "dynamic"
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "default" {
  count                 = var.backend_count
  name                  = "${var.project_name}-${count.index}"
  location              = var.location
  availability_set_id   = azurerm_availability_set.default.id
  resource_group_name   = azurerm_resource_group.default.name
  network_interface_ids = [element(azurerm_network_interface.default.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "${var.project_name}-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.sku[var.location]
    version   = "latest"
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
}
