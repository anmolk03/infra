variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication" {
  type    = string
  default = "LRS"
}

variable "tags" {
  type    = map(string)
  default = {}
  description = "Tags to apply to the resource"
}