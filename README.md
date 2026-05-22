# iac-azure-container-app

## Description

Terraform module to deploy an Azure Container Apps environment and a Container App.

Resources managed by this module:
- `azurerm_container_app_environment`
- `azurerm_container_app`

## Usage

```hcl
module "container_app" {
  source = "./iac-azure-container-app"

  resource_group_data = {
    name     = "rg-app-prod-weu"
    location = "westeurope"
  }

  container_environment = {
    name                       = "cae-app-prod-weu"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-logs/providers/Microsoft.OperationalInsights/workspaces/law-prod-weu"
  }

  container_app = {
    name             = "my-container-app"
    image            = "nginx:latest"
    cpu              = 0.5
    memory           = "0.5Gi"
    revision_mode    = "Single"
    min_replicas     = 0
    max_replicas     = 1
    external_enabled = true
    target_port      = 80
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.71.0 |

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| container_app | object({ name = string, image = string, cpu = optional(number, 0.5), memory = optional(string, "0.5Gi"), revision_mode = optional(string, "Single"), max_replicas = optional(number, 1), min_replicas = optional(number, 0), external_enabled = optional(bool, true), target_port = optional(number, 80) }) | N/A | The name of the Container app. |
| container_environment | object({ name = string, log_analytics_workspace_id = optional(string, null) }) | N/A | The name of the Container environment. |
| resource_group_data | object({ name = string, location = string }) | N/A | The resource group data for Cosmos DB. |

## Outputs

| Name | Description |
|------|-------------|
| name | The Container app name |
