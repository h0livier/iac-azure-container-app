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
  })
}