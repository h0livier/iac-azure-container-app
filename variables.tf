variable "resource_group_data" {
  description = "The resource group data for Cosmos DB."
  type = object({
    name     = string
    location = string
  })
}

variable "container_environment" {
  description = "The name of the Container environment."
  type = object({
    name                       = string
    log_analytics_workspace_id = optional(string, null)
  })
}

variable "container_app" {
  description = "The name of the Container app."
  type = object({
    name             = string
    image            = string
    cpu              = optional(number, 0.5)
    memory           = optional(string, "0.5Gi")
    revision_mode    = optional(string, "Single")
    max_replicas     = optional(number, 1)
    min_replicas     = optional(number, 0)
    external_enabled = optional(bool, true)
    target_port      = optional(number, 80)
    env              = optional(list(object({
      name  = string
      value = string
    })), [])
    health_probe = optional(object({
      type             = optional(string, "liveness")
      protocol         = optional(string, "Http")
      port             = optional(number, 80)
      path             = optional(string, "/health")
      initial_delay    = optional(number, 5)
      interval_seconds = optional(number, 10)
      timeout_seconds  = optional(number, 3)
      failure_count    = optional(number, 3)
    }), null)
  })
}