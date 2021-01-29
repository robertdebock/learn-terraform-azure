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
  default     = "westeurope"
  description = "The location where the resources are applied."
}

variable "tags" {
  type = map
  default = {
    Environment = "Terraform GS"
    Dept        = "Engineering"
  }
}

variable "sku" {
  default = {
    "westeurope" = "16.04-LTS"
    "northeurope"  = "18.04-LTS"
  }
}
