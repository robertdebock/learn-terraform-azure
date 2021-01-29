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
  default     = "west europe"
  description = "The location where the resources are applied."
}

variable "prefix" {
  type        = string
  default     = "my"
  description = "Some characters used to prefix resources."
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
    westus2 = "16.04-LTS"
    eastus  = "18.04-LTS"
  }
}
