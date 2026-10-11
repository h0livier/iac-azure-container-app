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
    name                    = string
    image                   = string
    cpu                     = optional(number, 0.5)
    memory                  = optional(string, "0.5Gi")
    revision_mode           = optional(string, "Single")
    max_replicas            = optional(number, 1)
    min_replicas            = optional(number, 0)
    external_enabled        = optional(bool, true)
    target_port             = optional(number, 80)
    client_certificate_mode = optional(string, null)
    secrets = optional(list(object({
      name  = string
      value = string
    })), [])
    env = optional(list(object({
      name        = string
      value       = optional(string, null)
      secret_name = optional(string, null)
    })), [])

    liveness_probe = optional(object({
      protocol                = optional(string, "Tcp")
      port                    = optional(number, 80)
      path                    = optional(string, null)
      initial_delay           = optional(number, null)
      interval_seconds        = optional(number, null)
      timeout                 = optional(number, null)
      failure_count_threshold = optional(number, null)
      success_count_threshold = optional(number, null)
    }), null)

    readiness_probe = optional(object({
      protocol                = optional(string, "Tcp")
      port                    = optional(number, 80)
      path                    = optional(string, null)
      initial_delay           = optional(number, null)
      interval_seconds        = optional(number, null)
      timeout                 = optional(number, null)
      failure_count_threshold = optional(number, null)
      success_count_threshold = optional(number, null)
    }), null)

    startup_probe = optional(object({
      protocol                = optional(string, "Tcp")
      port                    = optional(number, 80)
      path                    = optional(string, null)
      initial_delay           = optional(number, null)
      interval_seconds        = optional(number, null)
      timeout                 = optional(number, null)
      failure_count_threshold = optional(number, null)
      success_count_threshold = optional(number, null)
    }), null)

    http_scale_rules = optional(list(object({
      name                = string
      concurrent_requests = string
    })), [])

    # Deprecated: use liveness_probe/readiness_probe/startup_probe.
    health_probe = optional(object({
      type                    = optional(string, "liveness")
      protocol                = optional(string, "Tcp")
      port                    = optional(number, 80)
      path                    = optional(string, null)
      initial_delay           = optional(number, null)
      interval_seconds        = optional(number, null)
      timeout                 = optional(number, null)
      failure_count_threshold = optional(number, null)
      success_count_threshold = optional(number, null)
    }), null)
  })
}