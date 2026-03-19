resource "azurerm_redis_cache" "redis" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name
  family   = var.family
  capacity = var.capacity

  access_keys_authentication_enabled = var.access_keys_authentication_enabled
  non_ssl_port_enabled               = var.non_ssl_port_enabled
  minimum_tls_version                = var.minimum_tls_version
  public_network_access_enabled      = var.public_network_access_enabled

  redis_version   = var.redis_version
  tenant_settings = var.tenant_settings
  tags            = var.tags
  zones           = var.zones

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "patch_schedule" {
    for_each = var.patch_schedule
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = patch_schedule.value.start_hour_utc
      maintenance_window = patch_schedule.value.maintenance_window
    }
  }

  redis_configuration {
    # Moved inside redis_configuration for 2025 standards
    active_directory_authentication_enabled = var.active_directory_authentication_enabled
    
    authentication_enabled          = var.redis_configuration.authentication_enabled
    maxmemory_reserved              = var.redis_configuration.maxmemory_reserved
    maxmemory_delta                 = var.redis_configuration.maxmemory_delta
    maxmemory_policy                = var.redis_configuration.maxmemory_policy
    maxfragmentationmemory_reserved = var.redis_configuration.maxfragmentationmemory_reserved
    notify_keyspace_events          = var.redis_configuration.notify_keyspace_events

    # Premium-only persistence (Corrected to standard mapping)
    aof_backup_enabled                     = var.redis_configuration.aof_backup_enabled
    aof_storage_connection_string_0        = var.redis_configuration.aof_storage_connection_string_0
    aof_storage_connection_string_1        = var.redis_configuration.aof_storage_connection_string_1
    rdb_backup_enabled                     = var.redis_configuration.rdb_backup_enabled
    rdb_backup_frequency                   = var.redis_configuration.rdb_backup_frequency
    rdb_backup_max_snapshot_count          = var.redis_configuration.rdb_backup_max_snapshot_count
    rdb_storage_connection_string          = var.redis_configuration.rdb_storage_connection_string
    data_persistence_authentication_method = var.redis_configuration.data_persistence_authentication_method
    storage_account_subscription_id        = var.redis_configuration.storage_account_subscription_id
  }

  # PREMIUM-ONLY (Choose one replica naming convention or keep them equal)
  subnet_id                 = var.subnet_id
  private_static_ip_address = var.private_static_ip_address
  shard_count               = var.shard_count
  replicas_per_primary      = var.replicas_per_primary # Preferred over replicas_per_master

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
  }
}