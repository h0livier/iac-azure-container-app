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

  dynamic "secret" {
    for_each = var.container_app.secrets
    content {
      name  = secret.value.name
      value = secret.value.value
    }
  }

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
          name        = env.value.name
          value       = env.value.value
          secret_name = env.value.secret_name
        }
      }

      dynamic "liveness_probe" {
        for_each = var.container_app.liveness_probe != null ? [var.container_app.liveness_probe] : (
          var.container_app.health_probe != null && var.container_app.health_probe.type == "liveness" ? [var.container_app.health_probe] : []
        )
        content {
          transport = liveness_probe.value.protocol
          port      = liveness_probe.value.port
          path      = contains(["Http", "Https"], liveness_probe.value.protocol) ? liveness_probe.value.path : null

          initial_delay           = liveness_probe.value.initial_delay
          interval_seconds        = liveness_probe.value.interval_seconds
          timeout                 = liveness_probe.value.timeout
          failure_count_threshold = liveness_probe.value.failure_count_threshold
        }
      }

      dynamic "readiness_probe" {
        for_each = var.container_app.readiness_probe != null ? [var.container_app.readiness_probe] : (
          var.container_app.health_probe != null && var.container_app.health_probe.type == "readiness" ? [var.container_app.health_probe] : []
        )
        content {
          transport = readiness_probe.value.protocol
          port      = readiness_probe.value.port
          path      = contains(["Http", "Https"], readiness_probe.value.protocol) ? readiness_probe.value.path : null

          initial_delay           = readiness_probe.value.initial_delay
          interval_seconds        = readiness_probe.value.interval_seconds
          timeout                 = readiness_probe.value.timeout
          failure_count_threshold = readiness_probe.value.failure_count_threshold
          success_count_threshold = readiness_probe.value.success_count_threshold
        }
      }

      dynamic "startup_probe" {
        for_each = var.container_app.startup_probe != null ? [var.container_app.startup_probe] : (
          var.container_app.health_probe != null && var.container_app.health_probe.type == "startup" ? [var.container_app.health_probe] : []
        )
        content {
          transport = startup_probe.value.protocol
          port      = startup_probe.value.port
          path      = contains(["Http", "Https"], startup_probe.value.protocol) ? startup_probe.value.path : null

          initial_delay           = startup_probe.value.initial_delay
          interval_seconds        = startup_probe.value.interval_seconds
          timeout                 = startup_probe.value.timeout
          failure_count_threshold = startup_probe.value.failure_count_threshold
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = var.container_app.http_scale_rules
      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests
      }
    }
  }

  ingress {
    external_enabled        = var.container_app.external_enabled
    target_port             = var.container_app.target_port
    client_certificate_mode = var.container_app.client_certificate_mode

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}