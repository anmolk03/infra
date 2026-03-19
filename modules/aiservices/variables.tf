variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "uami_ids" {
  type    = list(string)
  default = []
}

variable "sku" {
  type    = string
  default = "S0"
}

variable "public_network_access" {
  type    = string
  default = "Disabled"
}
variable "tags" {
  type    = map(string)
  default = {}
  description = "Tags to apply to the resource"
}
variable "custom_subdomain_name" {
  type = string
}