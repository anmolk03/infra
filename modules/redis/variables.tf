variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }

variable "sku_name" {
  type    = string
  default = "Standard"
}

variable "family" {
  type    = string
  default = "C"
}

variable "capacity" {
  type    = number
  default = 0
}

variable "access_keys_authentication_enabled" {
  type    = bool
  default = false
}

variable "active_directory_authentication_enabled" {
  type    = bool
  default = true
}

variable "non_ssl_port_enabled" {
  type    = bool
  default = false
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "redis_version" {
  type    = number
  default = 6
}

variable "tenant_settings" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "zones" {
  type    = list(string)
  default = null
}

variable "identity_type" {
  type    = string
  default = null
}

variable "identity_ids" {
  type    = list(string)
  default = null
}

variable "patch_schedule" {
  type = list(object({
    day_of_week        = string
    start_hour_utc     = optional(number)
    maintenance_window = optional(string)
  }))
  default = []
}

variable "redis_configuration" {
  type = object({
    authentication_enabled                 = optional(bool, true)
    active_directory_authentication_enabled = optional(bool, false)
    maxmemory_reserved                     = optional(number)
    maxmemory_delta                        = optional(number)
    maxmemory_policy                       = optional(string)
    maxfragmentationmemory_reserved        = optional(number)
    notify_keyspace_events                 = optional(string)
    
    # Premium Persistence Settings
    aof_backup_enabled                     = optional(bool, false)
    aof_storage_connection_string_0        = optional(string)
    aof_storage_connection_string_1        = optional(string)
    rdb_backup_enabled                     = optional(bool, false)
    rdb_backup_frequency                   = optional(number)
    rdb_backup_max_snapshot_count          = optional(number)
    rdb_storage_connection_string          = optional(string)
    data_persistence_authentication_method = optional(string)
    storage_account_subscription_id        = optional(string)
  })
  default = {} # Default to empty object instead of null
}

# PREMIUM-ONLY
variable "subnet_id" {
  type    = string
  default = null
}
variable "private_static_ip_address" {
  type    = string
  default = null
}
variable "shard_count" {
  type    = number
  default = null
}
variable "replicas_per_primary" {
  type        = number
  description = "Number of replicas. Only available for Premium SKU."
  default     = null
}

# TIMEOUTS – COMMON
variable "timeouts" {
  type = object({
    create = optional(string, "3h")
    update = optional(string, "3h")
    read   = optional(string, "5m")
    delete = optional(string, "3h")
  })
  default = {}
}
