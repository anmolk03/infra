output "id" {
  description = "Redis Cache ID"
  value       = azurerm_redis_cache.redis.id
}

output "hostname" {
  description = "Redis hostname"
  value       = azurerm_redis_cache.redis.hostname
}

output "ssl_port" {
  description = "Redis SSL port"
  value       = azurerm_redis_cache.redis.ssl_port
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_redis_cache.redis.primary_access_key
  sensitive   = true
}