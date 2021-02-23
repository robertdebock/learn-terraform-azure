variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = string
    description = "Password must meet Azure complexity requirements"
}

variable "location" {
  type        = string
  description = "The location where the resources are applied."
}

variable "tags" {
  type = map
}

variable "sku" {
  type = map
  default = {
    westeurope   = "16.04-LTS"
    northeurope  = "18.04-LTS"
  }
}

variable "vm_size" {
  type = map
  default = {
    small  = "Standard_DS1_v2"
    medium = "Standard_DS2_v2"
    large  = "Standard_DS3_v2"
  }
}

variable "size" {
  type    = string
  description = "Please pick a size: small, medium or large."
}