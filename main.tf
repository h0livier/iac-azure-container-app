resource "azurerm_container_app_environment" "this" {
  name                       = var.container_environment.name
  location                   = var.resource_group_data.location
  resource_group_name        = var.resource_group_data.name
  log_analytics_workspace_id = var.container_environment.log_analytics_workspace_id
}

resource "azurerm_container_app" "this" {
  name                         = var.container_app.name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_data.name
  revision_mode                = var.container_app.revision_mode

  template {
    min_replicas = var.container_app.min_replicas
    max_replicas = var.container_app.max_replicas

    container {
      name   = var.container_app.name
      image  = var.container_app.image
      cpu    = var.container_app.cpu
      memory = var.container_app.memory

      dynamic "env" {
        for_each = var.container_app.env
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      dynamic "liveness_probe" {
        for_each = var.container_app.health_probe != null && var.container_app.health_probe.type == "liveness" ? [var.container_app.health_probe] : []
        content {
          transport = liveness_probe.value.protocol
          port      = liveness_probe.value.port
          path      = contains(["Http", "Https"], liveness_probe.value.protocol) ? liveness_probe.value.path : null
          
          initial_delay      = liveness_probe.value.initial_delay
          interval_seconds   = liveness_probe.value.interval_seconds
          timeout_seconds    = liveness_probe.value.timeout_seconds
          failure_count_threshold = liveness_probe.value.failure_count
        }
      }

      dynamic "readiness_probe" {
        for_each = var.container_app.health_probe != null && var.container_app.health_probe.type == "readiness" ? [var.container_app.health_probe] : []
        content {
          transport = readiness_probe.value.protocol
          port      = readiness_probe.value.port
          path      = contains(["Http", "Https"], readiness_probe.value.protocol) ? readiness_probe.value.path : null
          
          initial_delay      = readiness_probe.value.initial_delay
          interval_seconds   = readiness_probe.value.interval_seconds
          timeout_seconds    = readiness_probe.value.timeout_seconds
          failure_count_threshold = readiness_probe.value.failure_count
        }
      }

      dynamic "startup_probe" {
        for_each = var.container_app.health_probe != null && var.container_app.health_probe.type == "startup" ? [var.container_app.health_probe] : []
        content {
          transport = startup_probe.value.protocol
          port      = startup_probe.value.port
          path      = contains(["Http", "Https"], startup_probe.value.protocol) ? startup_probe.value.path : null
          
          initial_delay      = startup_probe.value.initial_delay
          interval_seconds   = startup_probe.value.interval_seconds
          timeout_seconds    = startup_probe.value.timeout_seconds
          failure_count_threshold = startup_probe.value.failure_count
        }
      }
    }
  }

  ingress {
    external_enabled = var.container_app.external_enabled
    target_port      = var.container_app.target_port

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}