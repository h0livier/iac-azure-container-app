# iac-azure-container-app

## Description

Terraform module to deploy an Azure Container Apps environment and a Container App. This module is optimized for small, low-cost containerized applications including Blazor Server applications.

Resources managed by this module:
- `azurerm_container_app_environment`
- `azurerm_container_app`

## Key Features

- **Cost-Optimized**: Default configuration (0.5 vCPU, 0.5Gi memory) suitable for small applications
- **Auto-Scaling to Zero**: Configure `min_replicas = 0` to scale down when not in use
- **Health Probes**: Built-in support for liveness, readiness, and startup probes
- **Environment Variables**: Native support for container environment configuration
- **Blazor Server Ready**: Configured with sensible defaults for Blazor Server applications

## Usage

### Basic Usage

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

### Blazor Server Application with Health Probes

```hcl
module "blazor_app" {
  source = "./iac-azure-container-app"

  resource_group_data = {
    name     = "rg-blazor-prod-weu"
    location = "westeurope"
  }

  container_environment = {
    name                       = "cae-blazor-prod-weu"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-logs/providers/Microsoft.OperationalInsights/workspaces/law-prod-weu"
  }

  container_app = {
    name             = "my-blazor-app"
    image            = "myregistry.azurecr.io/my-blazor-app:latest"
    cpu              = 0.5
    memory           = "1Gi"
    revision_mode    = "Single"
    min_replicas     = 1
    max_replicas     = 2
    external_enabled = true
    target_port      = 80
    
    env = [
      {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      },
      {
        name  = "ASPNETCORE_URLS"
        value = "http://+:80"
      }
    ]

    # Liveness probe: Restarts unhealthy containers
    health_probe = {
      type             = "liveness"
      protocol         = "Http"
      port             = 80
      path             = "/health/live"
      initial_delay    = 10
      interval_seconds = 30
      timeout_seconds  = 3
      failure_count    = 3
    }
  }
}
```

### Development/Low-Cost Configuration (Scale to Zero)

```hcl
module "container_app_dev" {
  source = "./iac-azure-container-app"

  resource_group_data = {
    name     = "rg-app-dev-weu"
    location = "westeurope"
  }

  container_environment = {
    name = "cae-app-dev-weu"
  }

  container_app = {
    name         = "my-app-dev"
    image        = "myregistry.azurecr.io/my-app:dev"
    min_replicas = 0      # Scales to zero when idle
    max_replicas = 1      # Maximum 1 replica to control costs
    target_port  = 8080
  }
}
```

### Complete Example with All Features

```hcl
module "container_app_full" {
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
    name             = "my-app"
    image            = "myregistry.azurecr.io/my-app:latest"
    cpu              = 0.5
    memory           = "1Gi"
    revision_mode    = "Single"
    min_replicas     = 1
    max_replicas     = 3
    external_enabled = true
    target_port      = 80

    env = [
      {
        name  = "LOG_LEVEL"
        value = "Information"
      },
      {
        name  = "API_KEY"
        value = "secret-value"
      }
    ]

    health_probe = {
      type             = "readiness"
      protocol         = "Http"
      port             = 80
      path             = "/health/ready"
      initial_delay    = 5
      interval_seconds = 10
      timeout_seconds  = 3
      failure_count    = 2
    }
  }
}
```

## Health Probes for Blazor Server

Blazor Server applications benefit from health probes to ensure traffic is only routed to healthy instances:

| Probe Type  | Purpose | Recommended Path | Use Case |
|------------|---------|------------------|----------|
| **liveness** | Detects and restarts stuck containers | `/health/live` | Container has deadlocked but is still running |
| **readiness** | Ensures requests only route to ready containers | `/health/ready` | Application is starting up or temporarily unavailable |
| **startup** | Allows time for slow-starting applications | `/health/live` | Application requires time to initialize |

For Blazor Server, implement an ASP.NET Core health check endpoint:

```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddCheck("live", () => HealthCheckResult.Healthy("Live check"), tags: new[] { "live" })
    .AddCheck("ready", () => HealthCheckResult.Healthy("Ready check"), tags: new[] { "ready" });

var app = builder.Build();

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = healthCheck => healthCheck.Tags.Contains("live")
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = healthCheck => healthCheck.Tags.Contains("ready")
});

app.Run();
```

## Cost Optimization

### Strategies for Minimum Cost

1. **Use Default Compute**: 0.5 vCPU and 0.5Gi memory are sufficient for most small applications
2. **Scale to Zero**: Set `min_replicas = 0` for development/test environments
3. **Single Replica**: Use `max_replicas = 1` to prevent unexpected scaling
4. **Optional Monitoring**: Log Analytics workspace is optional (`log_analytics_workspace_id = null`)

### Estimated Costs (as of 2026)

- **0.5 vCPU, 0.5Gi**: ~$0.005/hour per replica when running
- **0.5 vCPU, 0.5Gi with min_replicas=0**: Only pay when container is actually running
- **Log Analytics**: ~$2-10/month depending on data retention (optional)

### Cost Optimization Example

```hcl
# Dev environment: Scale to zero, minimal monitoring
container_app = {
  name         = "dev-app"
  image        = "myapp:dev"
  min_replicas = 0      # No charges when idle
  max_replicas = 1      # Max 1 running instance
}

# Production: Always running but minimal resources
container_app = {
  name         = "prod-app"
  image        = "myapp:latest"
  min_replicas = 1      # Always available
  max_replicas = 1      # No auto-scaling surprises
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
| `resource_group_data` | object | N/A | The resource group configuration with `name` and `location` |
| `container_environment` | object | N/A | Container environment configuration. Supports optional `log_analytics_workspace_id` for monitoring |
| `container_app` | object | N/A | Container app configuration |

### container_app Object Details

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | string | N/A | The name of the container app |
| `image` | string | N/A | The container image URI (e.g., `nginx:latest` or `myregistry.azurecr.io/myapp:v1.0.0`) |
| `cpu` | number | 0.5 | CPU cores allocated (0.25, 0.5, 0.75, or 1.0) |
| `memory` | string | "0.5Gi" | Memory allocation (0.5Gi, 1Gi, 1.5Gi, 2Gi, etc.) |
| `revision_mode` | string | "Single" | Revision mode: "Single" or "Multiple" |
| `min_replicas` | number | 0 | Minimum number of replicas (0 to scale to zero) |
| `max_replicas` | number | 1 | Maximum number of replicas |
| `external_enabled` | bool | true | Whether the app is externally accessible |
| `target_port` | number | 80 | Container port to expose |
| `env` | list(object) | [] | Environment variables as list of `{name: string, value: string}` |
| `health_probe` | object | null | Optional health probe configuration |

### health_probe Object Details (Optional)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `type` | string | "liveness" | Probe type: "liveness", "readiness", or "startup" |
| `protocol` | string | "Http" | Probe protocol: "Http", "Https", or "Tcp" |
| `port` | number | 80 | Container port for probe |
| `path` | string | "/health" | HTTP path for probe (used only for Http/Https) |
| `initial_delay` | number | 5 | Delay in seconds before first probe (Blazor: 10-15 recommended) |
| `interval_seconds` | number | 10 | Interval between probes in seconds |
| `timeout_seconds` | number | 3 | Timeout for each probe in seconds |
| `failure_count` | number | 3 | Consecutive failures before taking action |

## Outputs

| Name | Description |
|------|-------------|
| `name` | The Container app name |

## Examples in Repository

See the `examples/` directory for complete working examples:
- `examples/basic/` - Simple nginx deployment
- `examples/blazor-server/` - Blazor Server application with health checks
- `examples/high-availability/` - Multi-replica configuration with monitoring
