variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
//variable "uami_principal_id" { type = string }

variable "sku" {
  type    = string
  default = "standard"
}

variable "purge_protection" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
  description = "Tags to apply to the resource"
}