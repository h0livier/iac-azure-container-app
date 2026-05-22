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